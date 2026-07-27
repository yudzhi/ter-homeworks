###cloud vars

/* С 1 июня 2026 года сервис аутентификации не принимает новые OAuth‑токены
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}
*/

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
  description = "VPC network&subnet name"
}
### ==========================================
### SSH VARIABLE
### ==========================================

variable "vms_ssh_root_key" {
  type        = string
  default     = null # переопределяется в personal.auto.tfvars
  description = "ssh-keygen -t ed25519"
}

### ==========================================
### MAP VARIABLE FOR METADATA
### ==========================================

variable "metadata" {
  description = "Common metadata for all VM instances"
  type = object({
    serial-port-enable = number
    ssh-keys           = string
  })
  default = {
    serial-port-enable = 1
    ssh-keys           = null  # переопределяется через locals
  }
}
