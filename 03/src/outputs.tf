# ============================================
# ВЫВОД СПИСКА ВСЕХ ВМ
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
