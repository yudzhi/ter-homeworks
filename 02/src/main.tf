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
  route_table_id = yandex_vpc_route_table.nat_route_table.id
}

### Первая ВМ - web
data "yandex_compute_image" "ubuntu_web" {
  family = var.vm_web_image_family
}

resource "yandex_compute_instance" "platform_web" {
  name        = local.vm_web_name
  platform_id = var.vm_web_platform_id
  zone        = var.vm_web_zone

  resources {
    cores         = var.vms_resources["web"].cores
    memory        = var.vms_resources["web"].memory
    core_fraction = var.vms_resources["web"].core_fraction
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

  metadata = local.vm_metadata

}

### Вторая ВМ - db

data "yandex_compute_image" "ubuntu_db" {
  family = var.vm_db_image_family
}

resource "yandex_compute_instance" "platform_db" {
  name        = local.vm_db_name
  platform_id = var.vm_db_platform_id
  zone        = var.vm_db_zone

  resources {
    cores         = var.vms_resources["db"].cores
    memory        = var.vms_resources["db"].memory
    core_fraction = var.vms_resources["db"].core_fraction
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

  metadata = local.vm_metadata

}

### ===============================
### Настройка NAT-шлюза
### ===============================

# 1. Data-источник для получения информации о сети
data "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

# 2. Ресурс самого NAT-шлюза
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {} # Пустой блок, обозначающий тип шлюза
}

# 3. Ресурс таблицы маршрутизации
resource "yandex_vpc_route_table" "nat_route_table" {
  name       = "nat-route-table"
  network_id = data.yandex_vpc_network.develop.id

  static_route {
    destination_prefix = "0.0.0.0/0" # Весь трафик в интернет
    gateway_id         = yandex_vpc_gateway.nat_gateway.id # Идёт через наш шлюз
  }
}