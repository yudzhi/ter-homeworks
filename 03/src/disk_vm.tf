# ============================================
# СОЗДАНИЕ ВИРТУАЛЬНЫХ ДИСКОВ
# ============================================


resource "yandex_compute_disk" "storage" {
  count       = var.storage_disks.count
  name        = "${var.storage_disks.name_prefix}-${count.index + 1}"
  type        = var.storage_disks.type
  size        = var.storage_disks.size
  zone        = var.vm_common_params.zone
  description = "Дополнительный диск для storage ВМ #${count.index + 1}"
}

# --------------------------------------------
# Создание одиночной ВМ "storage"
# (БЕЗ использования count и for_each в самом ресурсе,
#  но с dynamic + for_each для подключения дисков)
# --------------------------------------------
data "yandex_compute_image" "ubuntu_storage" {
  family = var.vm_common_params.image_family
}

resource "yandex_compute_instance" "storage" {
  name        = var.storage_vm.storage_name
  platform_id = var.vm_common_params.platform_id
  zone        = var.vm_common_params.zone

  resources {
    cores         = var.storage_vm.cpu
    memory        = var.storage_vm.ram
    core_fraction = var.vm_common_params.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_storage.image_id
      size     = var.storage_vm.disk_size
      type     = var.storage_vm.boot_disk_type
    }
  }

  scheduling_policy {
    preemptible = var.vm_common_params.preemptible
  }

  # --------------------------------------------
  # Подключение дополнительных дисков через dynamic + for_each
  # --------------------------------------------

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.storage[*]
    content {
      disk_id = secondary_disk.value.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
    nat                = var.enable_nat_for_vms
  }

  #   metadata = local.vm_metadata
  metadata = merge(local.vm_metadata, {
    hostname = "storage"
  })

  depends_on = [
    yandex_compute_disk.storage # Явно ждём создания дисков
  ]
}


