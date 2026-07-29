# ============================================
# ANSIBLE INVENTORY ГЕНЕРАЦИЯ
# ============================================

# --------------------------------------------
# ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ ДЛЯ INVENTORY
# --------------------------------------------

locals {
  # Собираем все ВМ в группы для inventory
  # Целевые группы: webservers, databases, storage
  # Поля: name, nat_ip, fqdn

  # Группа веб-серверов (из count-vm.tf)
  webservers = [
    for instance in yandex_compute_instance.web : {
      name   = instance.name
      nat_ip = instance.network_interface.0.nat_ip_address
      fqdn   = instance.fqdn
    }
  ]

  # Группа баз данных (из for_each-vm.tf)
  databases = [
    for instance in yandex_compute_instance.db : {
      name   = instance.name
      nat_ip = instance.network_interface.0.nat_ip_address
      fqdn   = instance.fqdn
    }
  ]

  # Группа storage (из disk_vm.tf)
  storage = [
    for instance in [yandex_compute_instance.storage] : {
      name   = instance.name
      nat_ip = instance.network_interface.0.nat_ip_address
      fqdn   = instance.fqdn
    }
  ]
}

# --------------------------------------------
# ГЕНЕРАЦИЯ INVENTORY ИЗ ШАБЛОНА
# --------------------------------------------

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/hosts.tftpl", {
    webservers = local.webservers
    databases  = local.databases
    storage    = local.storage
  })

  filename = "${abspath(path.module)}/inventory.ini"
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
  }

  # Пересоздаём inventory-файл при срабатывании триггеров
  provisioner "local-exec" {
    command = "echo 'Inventory updated at $(date)' > ${abspath(path.module)}/inventory-update.log"
  }
}


# --------------------------------------------
# ВЫВОД ИНФОРМАЦИИ
# --------------------------------------------

output "inventory_file_path" {
  description = "Путь к созданному inventory-файлу"
  value       = local_file.ansible_inventory.filename
}

output "inventory_content" {
  description = "Содержимое inventory-файла"
  value       = local_file.ansible_inventory.content
}

output "web_servers_count" {
  description = "Количество веб-серверов"
  value       = length(local.webservers)
}

output "database_servers_count" {
  description = "Количество серверов БД"
  value       = length(local.databases)
}
