# ============================================
# СЕРВЕРЫ БАЗ ДАННЫХ (создаются через for_each)
# Использует переменные из vm-variables.tf
# ============================================
data "yandex_compute_image" "ubuntu_db" {
  family = var.vm_common_params.image_family
}

resource "yandex_compute_instance" "db" {
  for_each = local.each_vm_map

  name        = "db-${each.key}"
  platform_id = var.vm_common_params.platform_id
  zone        = var.vm_common_params.zone

  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = var.vm_common_params.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_db.image_id
      size     = each.value.disk_volume
      type     = each.value.boot_disk_type
    }
  }

  scheduling_policy {
    preemptible = var.vm_common_params.preemptible
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
    nat                = var.enable_nat_for_vms # (each.value, "enable_nat", true)
  }

  # metadata = local.vm_metadata
  metadata = merge(local.vm_metadata, {
    hostname = "db-${each.key}"
  })
}