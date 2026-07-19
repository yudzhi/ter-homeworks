###VM web variables

### yandex_compute_image vars
variable "vm_web_image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Family of the OS image for the VM (ubuntu-2004-lts, ubuntu-2204-lts)"
}

### yandex_compute_instance vars
variable "vm_web_name" {
  type        = string
  default     = "netology-develop-platform-web"
  description = "Name of the web VM instance"
}

variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v3"
  description = "https://yandex.cloud/ru/docs/compute/concepts/vm-platforms"
}

variable "vm_web_cores" {
  type        = number
  default     = 2
  description = "https://yandex.cloud/ru/docs/compute/concepts/performance-levels"
}

variable "vm_web_memory" {
  type        = number
  default     = 1
  description = "https://yandex.cloud/ru/docs/compute/concepts/performance-levels#available-configurations"
}

variable "vm_web_core_fraction" {
  type        = number
  default     = 20
  description = "https://yandex.cloud/ru/docs/compute/concepts/performance-levels"
}

variable "vm_web_preemptible" {
  type        = bool
  default     = true
  description = "https://yandex.cloud/ru/docs/compute/concepts/preemptible-vm"
}

variable "vm_web_nat" {
  type        = bool
  default     = true
  description = "https://yandex.cloud/ru/docs/vpc/concepts/address#public-addresses"
}

variable "vm_web_serial_port_enable" {
  type        = number
  default     = 1
  description = "https://yandex.cloud/ru/docs/compute/operations/serial-console/"
}

# Availability zone for the web VM
variable "vm_web_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://yandex.cloud/ru/docs/overview/concepts/geo-scope"
}

###VM db variables

### yandex_compute_image vars
# Family of the OS image for the DB VM (ubuntu-2004-lts, ubuntu-2204-lts)
variable "vm_db_image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Family of the OS image for the VM (ubuntu-2004-lts, ubuntu-2204-lts)"
}

### yandex_compute_instance vars
# Name of the database VM instance
variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
  description = "Name of the web VM instance"
}

# Platform ID for the DB VM (standard-v4a, standard-v3)
variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v3"
  description = "https://yandex.cloud/ru/docs/compute/concepts/vm-platforms"
}

# Number of CPU cores for the DB VM
variable "vm_db_cores" {
  type        = number
  default     = 2
  description = "https://yandex.cloud/ru/docs/compute/concepts/performance-levels"
}

# RAM in GB for the DB VM
variable "vm_db_memory" {
  type        = number
  default     = 2
  description = "https://yandex.cloud/ru/docs/compute/concepts/performance-levels#available-configurations"
}

# Core fraction (guaranteed vCPU percentage): 20, 50, 100
variable "vm_db_core_fraction" {
  type        = number
  default     = 20
  description = "https://yandex.cloud/ru/docs/compute/concepts/performance-levels"
}

# Whether the DB VM should be preemptible (cheaper but can be terminated anytime)
variable "vm_db_preemptible" {
  type        = bool
  default     = true
  description = "https://yandex.cloud/ru/docs/compute/concepts/preemptible-vm"
}

# Whether to assign a public IP address to the DB VM via NAT
variable "vm_db_nat" {
  type        = bool
  default     = true
  description = "https://yandex.cloud/ru/docs/vpc/concepts/address#public-addresses"
}

# Enable serial port access for DB VM (1 - enabled, 0 - disabled)
variable "vm_db_serial_port_enable" {
  type        = number
  default     = 1
  description = "https://yandex.cloud/ru/docs/compute/operations/serial-console/"
}

# Availability zone for the database VM
variable "vm_db_zone" {
  type        = string
  default     = "ru-central1-b"
  description = "https://yandex.cloud/ru/docs/overview/concepts/geo-scope"
}