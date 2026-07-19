resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

/*
resource "yandex_vpc_subnet" "develop" {
  name           = "${var.vpc_name}-sub"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}
*/

# Динамическое создание подсетей только для уникальных зон
resource "yandex_vpc_subnet" "develop" {
  for_each = local.unique_zones
  
  name           = local.subnet_names[each.key]
  zone           = each.key
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = local.subnet_cidrs[each.key]
  
}

### Первая ВМ - web
data "yandex_compute_image" "ubuntu_web" {
  family = var.vm_web_image_family
}

resource "yandex_compute_instance" "platform_web" {
  name        = var.vm_web_name
  platform_id = var.vm_web_platform_id
  zone = var.vm_web_zone

  resources {
    cores         = var.vm_web_cores
    memory        = var.vm_web_memory
    core_fraction = var.vm_web_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_web.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop[var.vm_web_zone].id
    nat       = var.vm_web_nat
  }

  metadata = {
    serial-port-enable = var.vm_web_serial_port_enable
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}

### Вторая ВМ - db

data "yandex_compute_image" "ubuntu_db" {
  family = var.vm_db_image_family
}

resource "yandex_compute_instance" "platform_db" {
  name        = var.vm_db_name
  platform_id = var.vm_db_platform_id
  zone = var.vm_db_zone
    
  resources {
    cores         = var.vm_db_cores
    memory        = var.vm_db_memory
    core_fraction = var.vm_db_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_db.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_db_preemptible
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.develop[var.vm_db_zone].id
    nat       = var.vm_db_nat
  }

  metadata = {
    serial-port-enable = var.vm_db_serial_port_enable
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}