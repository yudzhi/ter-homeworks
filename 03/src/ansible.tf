# ============================================
# ANSIBLE INVENTORY ГЕНЕРАЦИЯ
# ============================================

# --------------------------------------------
# ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ ДЛЯ INVENTORY
# --------------------------------------------

locals {

  # --------------------------------------------
  # Выбор внутреннего или внешнего IP для Ansible
  # --------------------------------------------

  # Все ВМ в одном map для удобства
  all_vms = merge(
    # vm - list element
    { for vm in yandex_compute_instance.web : vm.name => vm },
    # map - перебираем ключи и значения
    { for name, vm in yandex_compute_instance.db : vm.name => vm },
    # storage: объект - превращаем в список и перебираем
    { for vm in [yandex_compute_instance.storage] : vm.name => vm }
  )

  # Вспомогательная функция для выбора IP
  # Использует coalesce() - возвращает первое НЕ ПУСТОЕ значение
  # Если внешний IP есть → используем его, иначе → внутренний IP
  # Функция для получения ansible_host для любой ВМ
  get_ansible_host = {
    for name, vm in local.all_vms :
    name => coalesce(
      vm.network_interface.0.nat_ip_address,
      vm.network_interface.0.ip_address
    )
  }

  # Собираем все ВМ в группы для inventory
  # Целевые группы: webservers, databases, storage
  # Поля: name, nat_ip, fqdn
  # UPD: добавлена группа bastion
  # UPD: добавлены поля internal_ip, ansible_host

  # Группа веб-серверов (из count-vm.tf)
  web_servers = [
    for instance in yandex_compute_instance.web : {
      name         = instance.name
      ansible_host = local.get_ansible_host[instance.name]
      nat_ip       = instance.network_interface.0.nat_ip_address
      internal_ip  = instance.network_interface.0.ip_address
      fqdn         = instance.fqdn
    }
  ]

  # Группа баз данных (из for_each-vm.tf)
  database_servers = [
    for instance in yandex_compute_instance.db : {
      name         = instance.name
      ansible_host = local.get_ansible_host[instance.name]
      nat_ip       = instance.network_interface.0.nat_ip_address
      internal_ip  = instance.network_interface.0.ip_address
      fqdn         = instance.fqdn
    }
  ]

  # Группа storage (из disk_vm.tf)
  storage_servers = [
    for instance in [yandex_compute_instance.storage] : {
      name         = instance.name
      ansible_host = local.get_ansible_host[instance.name]
      nat_ip       = instance.network_interface.0.nat_ip_address
      internal_ip  = instance.network_interface.0.ip_address
      fqdn         = instance.fqdn
    }
  ]

  # Группа Bastion-сервер
  bastion_servers = [
    for instance in yandex_compute_instance.bastion : {
      name        = instance.name
      nat_ip      = instance.network_interface.0.nat_ip_address
      internal_ip = instance.network_interface.0.ip_address
      fqdn        = instance.fqdn
      # Для bastion используем внешний IP (он всегда есть)
      ansible_host = instance.network_interface.0.nat_ip_address
    }
  ]

  # --------------------------------------------
  # Все ID для триггеров
  # --------------------------------------------

  all_vm_ids = concat(
    [for vm in yandex_compute_instance.web : vm.id],
    [for vm in yandex_compute_instance.db : vm.id],
    [yandex_compute_instance.storage.id],
    [yandex_compute_instance.bastion[0].id]
  )

  # Генерация inventory из шаблона
  # Сохранено в переменную для реализации обновления
  inventory_content = templatefile("${path.module}/hosts.tftpl", {
    webservers = local.web_servers
    databases  = local.database_servers
    storage    = local.storage_servers
    bastion    = local.bastion_servers
  })
}


# --------------------------------------------
# Создание inventory-файла
# --------------------------------------------

resource "local_file" "ansible_inventory" {
  content  = local.inventory_content
  filename = "${abspath(path.module)}/inventory.ini"

  depends_on = [
    yandex_compute_instance.web,
    yandex_compute_instance.db,
    yandex_compute_instance.storage,
    yandex_compute_instance.bastion
  ]

}

# --------------------------------------------  
# Пересоздаём файл при изменении любой ВМ
# local_file не поддерживает triggers
# terraform_data для триггеров
# --------------------------------------------

resource "terraform_data" "inventory_trigger" {
  # Триггеры для пересоздания при изменении ВМ
  triggers_replace = {
    web_instances     = join(",", [for vm in yandex_compute_instance.web : vm.id])
    db_instances      = join(",", [for vm in yandex_compute_instance.db : vm.id])
    storage_instance  = yandex_compute_instance.storage.id
    template_checksum = filemd5("${path.module}/hosts.tftpl")
    inventory_content = local.inventory_content
  }

  # Пересоздаём inventory-файл при срабатывании триггеров
  provisioner "local-exec" {
    command = <<-EOT
      cat > ${abspath(path.module)}/inventory.ini << 'INVENTORY'
${local.inventory_content}
INVENTORY
      echo "Inventory updated at $(date)" >> ${abspath(path.module)}/inventory-update.log
    EOT
  }
}

resource "null_resource" "ansible_provision" {
  count = var.run_ansible ? 1 : 0

  depends_on = [
    yandex_compute_instance.web,
    yandex_compute_instance.db,
    yandex_compute_instance.storage,
    yandex_compute_instance.bastion,
    local_file.ansible_inventory
  ]

  triggers = {
    all_vm_ids     = join(",", local.all_vm_ids)
    inventory_hash = md5(local.inventory_content)
    playbook_hash  = filemd5("${path.module}/playbook.yml")
  }

  # Добавление приватного ключа в ssh-agent
  provisioner "local-exec" {
    command    = "eval $(ssh-agent) && cat ~/.ssh/id_ed25519 | ssh-add -"
    on_failure = continue
  }

  # убираем sleep 60 (это делает pre_tasks в Ansible)
  # provisioner "local-exec" {
  #   command = "sleep 60"
  #   on_failure = continue
  # }

  # Запуск Ansible playbook с передачей секретов
  provisioner "local-exec" {
    command = <<-EOT
      echo "Запуск Ansible playbook..."
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible-playbook \
        -i ${abspath(path.module)}/inventory.ini \
        ${abspath(path.module)}/playbook.yml \
        --extra-vars '{
          "secrets": ${jsonencode({
    for vm in yandex_compute_instance.web :
    vm.name => "secret_for_${vm.name}"
})}
        }'
      
      if [ $? -eq 0 ]; then
        echo "Ansible playbook выполнен успешно"
      else
        echo "Ошибка при выполнении Ansible playbook"
        exit 1
      fi
    EOT
on_failure = continue
environment = {
  ANSIBLE_HOST_KEY_CHECKING = "False"
}
}
}


