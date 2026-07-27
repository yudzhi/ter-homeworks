# ============================================
# ПЕРЕМЕННЫЕ ДЛЯ ВИРТУАЛЬНЫХ МАШИН
# ============================================

# --------------------------------------------
# Общие параметры для всех ВМ
# --------------------------------------------

variable "vm_common_params" {
  description = "Общие параметры для всех ВМ: платформа, зона, образ, тип диска"
  type = object({
    platform_id         = string   # Платформа (standard-v2, standard-v3, etc)
    zone                = string   # Зона доступности
    core_fraction       = number   # Гарантированная доля vCPU (5, 20, 50, 100)
    image_family        = string   # Семейство образов
    preemptible         = bool     # Прерываемая ли ВМ
    ssh_public_key_path = string # Путь к публичному SSH-ключу
  })
  default = {
    platform_id       = "standard-v3"
    zone              = "ru-central1-a"
    core_fraction     = 20
    image_family      = "ubuntu-2204-lts"
    preemptible       = true
    ssh_public_key_path = "~/.ssh/id_ed25519.pub"
  }
}

# --------------------------------------------
# Параметры веб-серверов (используют count)
# --------------------------------------------

variable "web_servers" {
  description = "Параметры для группы веб-серверов, создаваемых через count"
  type = object({
    count               = number   # Количество экземпляров
    name_prefix         = string   # Префикс для имени (будет web-1, web-2, ...)
    cpu                 = number   # Количество vCPU
    ram                 = number   # Объём RAM в ГБ
    boot_disk_type      = string   # Тип диска (network-hdd, network-ssd)
    disk_size           = number   # Размер загрузочного диска в ГБ
    enable_nat          = bool     # Назначать ли публичный IP
    depends_on_resource = string   # От какого ресурса зависит (для явной зависимости)
 
  })
  default = {
    count               = 2
    name_prefix         = "web"
    cpu                 = 2
    ram                 = 1
    boot_disk_type      = "network-hdd"
    disk_size           = 20
    enable_nat          = true
    depends_on_resource = "yandex_compute_instance.db"
  }
}

# --------------------------------------------
# Параметры серверов баз данных (используют for_each)
# --------------------------------------------

variable "each_vm" {
  description = "Конфигурация серверов баз данных: main (master) и replica (slave)"
  type = list(object({
    vm_name         = string   # Имя ВМ (будет использовано как ключ в for_each)
    cpu             = number   # Количество vCPU
    ram             = number   # Объём RAM в ГБ
    disk_volume     = number   # Размер загрузочного диска в ГБ
    boot_disk_type  = string   # Тип диска (network-hdd, network-ssd)
    enable_nat      = optional(bool, true)  # Назначать ли публичный IP (опционально)
  }))
  default = [
    {
      vm_name         = "main"
      cpu             = 2
      ram             = 4
      disk_volume     = 30
      boot_disk_type  = "network-hdd"
      enable_nat      = true
    },
    {
      vm_name         = "replica"
      cpu             = 4
      ram             = 8
      disk_volume     = 50
      boot_disk_type  = "network-hdd"
      enable_nat      = true
    }
  ]
}

# --------------------------------------------
# (Опционально) Готовые наборы параметров для разных типов ВМ
# --------------------------------------------

# Пример: предустановленные конфигурации для разных сценариев
locals {
  # Конфигурация для "минимального" веб-сервера
  web_minimal = {
    cpu    = 1
    ram = 1
    disk   = 10
  }
  
  # Конфигурация для "стандартного" веб-сервера
  web_standard = {
    cpu    = 2
    ram = 2
    disk   = 20
  }
  
  # Конфигурация для "мощного" веб-сервера
  web_powerful = {
    cpu    = 4
    ram = 8
    disk   = 50
  }
  
  # Конфигурация для "минимальной" БД
  db_minimal = {
    cpu    = 1
    ram = 2
    disk   = 20
  }
  
  # Конфигурация для "стандартной" БД
  db_standard = {
    cpu    = 2
    ram = 4
    disk   = 30
  }
  
  # Конфигурация для "мощной" БД
  db_powerful = {
    cpu    = 8
    ram = 16
    disk   = 100
  }
}