# ============================================
# ПЕРЕМЕННЫЕ ДЛЯ ВИРТУАЛЬНЫХ МАШИН
# ============================================

# --------------------------------------------
# Общие параметры для всех ВМ
# --------------------------------------------

variable "vm_common_params" {
  description = "Общие параметры для всех ВМ: платформа, зона, образ, тип диска"
  type = object({
    platform_id         = string # Платформа (standard-v2, standard-v3, etc)
    zone                = string # Зона доступности
    core_fraction       = number # Гарантированная доля vCPU (5, 20, 50, 100)
    image_family        = string # Семейство образов
    preemptible         = bool   # Прерываемая ли ВМ
    ssh_public_key_path = string # Путь к публичному SSH-ключу
  })
  default = {
    platform_id         = "standard-v3"
    zone                = "ru-central1-a"
    core_fraction       = 20
    image_family        = "ubuntu-2204-lts"
    preemptible         = true
    ssh_public_key_path = "~/.ssh/id_ed25519.pub"
  }
}

# --------------------------------------------
# Параметры веб-серверов (используют count)
# --------------------------------------------

variable "web_servers" {
  description = "Параметры для группы веб-серверов, создаваемых через count"
  type = object({
    count               = number # Количество экземпляров
    name_prefix         = string # Префикс для имени (будет web-1, web-2, ...)
    cpu                 = number # Количество vCPU
    ram                 = number # Объём RAM в ГБ
    boot_disk_type      = string # Тип диска (network-hdd, network-ssd)
    disk_size           = number # Размер загрузочного диска в ГБ
    enable_nat          = bool   # Назначать ли публичный IP
    depends_on_resource = string # От какого ресурса зависит (для явной зависимости)

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
    vm_name        = string               # Имя ВМ (будет использовано как ключ в for_each)
    cpu            = number               # Количество vCPU
    ram            = number               # Объём RAM в ГБ
    disk_volume    = number               # Размер загрузочного диска в ГБ
    boot_disk_type = string               # Тип диска (network-hdd, network-ssd)
    enable_nat     = optional(bool, true) # Назначать ли публичный IP (опционально)
  }))
  default = [
    {
      vm_name        = "main"
      cpu            = 2
      ram            = 4
      disk_volume    = 30
      boot_disk_type = "network-hdd"
      enable_nat     = true
    },
    {
      vm_name        = "replica"
      cpu            = 4
      ram            = 8
      disk_volume    = 50
      boot_disk_type = "network-hdd"
      enable_nat     = true
    }
  ]
}

# --------------------------------------------
# Переменные для виртуальных дисков
# --------------------------------------------

variable "storage_disks" {
  description = "Параметры для создания виртуальных дисков"
  type = object({
    count       = number # Количество дисков
    size        = number # Размер диска в ГБ
    type        = string # Тип диска (network-hdd, network-ssd)
    name_prefix = string # Префикс имени диска
  })
  default = {
    count       = 3
    size        = 1
    type        = "network-hdd"
    name_prefix = "storage-disk"
  }
}

# --------------------------------------------
# Параметры storage ВМ
# --------------------------------------------

variable "storage_vm" {
  description = "Параметры для storage ВМ"
  type = object({
    cpu            = number
    ram            = number
    boot_disk_type = string
    disk_size      = number
    enable_nat     = bool
  })
  default = {
    cpu            = 2
    ram            = 2
    boot_disk_type = "network-hdd"
    disk_size      = 20
    enable_nat     = true
  }
}
