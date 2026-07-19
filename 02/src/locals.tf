locals {
  # Собираем все уникальные зоны, в которых будут созданы ВМ
  unique_zones = toset(distinct([var.vm_web_zone, var.vm_db_zone]))
  
  # Создаём map с CIDR блоками для каждой зоны
  zone_cidr_map = {
    "ru-central1-a" = var.subnet_cidr_a
    "ru-central1-b" = var.subnet_cidr_b
  }
  
  # Создаём map с именами подсетей для каждой зоны
  subnet_names = {
    for zone in local.unique_zones : 
    zone => "${var.vpc_name}-${replace(zone, "-", "_")}"
  }
  
  # Определяем, какой CIDR использовать для каждой зоны
  subnet_cidrs = {
    for zone in local.unique_zones : 
    zone => local.zone_cidr_map[zone]
  }
  
}