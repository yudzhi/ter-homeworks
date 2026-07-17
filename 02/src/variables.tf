###cloud vars


variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

# yandex_compute_image vars
variable "vm_web_image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Family of the OS image for the VM (ubuntu-2004-lts, ubuntu-2204-lts)"
}

# yandex_compute_instance vars
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

###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = null # переопределяется в personal.auto.tfvars
  description = "ssh-keygen -t ed25519"
}
