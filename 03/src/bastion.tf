# ============================================
# BASTION-СЕРВЕР
# Используется для доступа к ВМ без внешних IP
# ============================================


# --------------------------------------------
# СОЗДАНИЕ BASTION-СЕРВЕРА
# --------------------------------------------

data "yandex_compute_image" "ubuntu_bastion" {
  family = var.vm_common_params.image_family
}

resource "yandex_compute_instance" "bastion" {
  count = var.bastion.enable ? 1 : 0

  name        = var.bastion.name
  platform_id = var.vm_common_params.platform_id
  zone        = var.vm_common_params.zone

  resources {
    cores         = var.bastion.cpu
    memory        = var.bastion.ram
    core_fraction = var.vm_common_params.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_bastion.image_id
      size     = var.bastion.disk_size
      type     = var.bastion.boot_disk_type
    }
  }

  scheduling_policy {
    preemptible = var.vm_common_params.preemptible
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
    nat                = var.enable_nat_for_bastion
  }

  metadata = merge(local.vm_metadata, {
    hostname = var.bastion.name
  })
}

