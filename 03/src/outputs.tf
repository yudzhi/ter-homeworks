# --------------------------------------------
# Вывод информации об инвентаре
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
  value       = length(local.web_servers)
}

output "database_servers_count" {
  description = "Количество серверов БД"
  value       = length(local.database_servers)
}

# --------------------------------------------
# Вывод информации о дисках
# --------------------------------------------

output "storage_disks_info" {
  description = "Информация о созданных дополнительных дисках"
  value = {
    for idx, disk in yandex_compute_disk.storage :
    disk.name => {
      id   = disk.id
      size = disk.size
      type = disk.type
    }
  }
}

output "storage_vm_ip" {
  description = "IP-адрес storage ВМ"
  value       = yandex_compute_instance.storage.network_interface.0.nat_ip_address
}

output "storage_vm_name" {
  description = "Имя storage ВМ"
  value       = yandex_compute_instance.storage.name
}

output "storage_disks_attached" {
  description = "ID подключённых к storage ВМ дисков"
  value = [
    for disk in yandex_compute_instance.storage.secondary_disk :
    disk.disk_id
  ]
}

# ============================================
# Вывод списка всех ВМ
# Сбор информации из всех ресурсов ВМ
# ============================================

output "all_vms" {
  description = "Список всех виртуальных машин с их параметрами"
  value = concat(
    # Веб-серверы (из count)
    [for vm in yandex_compute_instance.web : {
      name = vm.name
      id   = vm.id
      fqdn = vm.fqdn
    }],

    # Базы данных (из for_each)
    [for vm in yandex_compute_instance.db : {
      name = vm.name
      id   = vm.id
      fqdn = vm.fqdn
    }],

    # Storage ВМ (одиночная)
    [for vm in [yandex_compute_instance.storage] : {
      name = vm.name
      id   = vm.id
      fqdn = vm.fqdn
    }]
  )
}

# --------------------------------------------
# Выводы для BASTION
# --------------------------------------------

output "bastion_ip" {
  description = "Внешний IP-адрес bastion-сервера"
  value       = try(yandex_compute_instance.bastion[0].network_interface.0.nat_ip_address, "no_bastion")
}

output "bastion_internal_ip" {
  description = "Внутренний IP-адрес bastion-сервера"
  value       = try(yandex_compute_instance.bastion[0].network_interface.0.ip_address, "no_bastion")
}

# --------------------------------------------
# Выводы группы безопасности
# --------------------------------------------

output "security_group_rules" {
  description = "Текущие правила группы безопасности"
  value = {
    ingress_rules_count = length(local.ingress_rules)
    ssh_mode            = var.enable_nat_for_vms ? "direct (public IP)" : "via bastion (private IP)"
    bastion_enabled     = var.bastion.enable
    rules               = local.ingress_rules
  }
}