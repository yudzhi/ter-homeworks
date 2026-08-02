# ============================================
# ВЕБ-СЕРВЕРЫ (создаются через count)
# Использует переменные из vms_platform.tf
# ============================================
data "yandex_compute_image" "ubuntu_web" {
  family = var.vm_common_params.image_family
}

resource "yandex_compute_instance" "web" {
  count       = var.web_servers.count
  name        = "${var.web_servers.name_prefix}-${count.index + 1}"
  platform_id = var.vm_common_params.platform_id
  zone        = var.vm_common_params.zone

  resources {
    cores         = var.web_servers.cpu
    memory        = var.web_servers.ram
    core_fraction = var.vm_common_params.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_web.image_id
      size     = var.web_servers.disk_size
      type     = var.web_servers.boot_disk_type
    }
  }

  scheduling_policy {
    preemptible = var.vm_common_params.preemptible
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
    nat                = var.enable_nat_for_vms
  }

  #   metadata = local.vm_metadata
  metadata = merge(local.vm_metadata, {
    hostname = "${var.web_servers.name_prefix}-${count.index + 1}"
  })

  depends_on = [
    yandex_compute_instance.db
  ]
}
