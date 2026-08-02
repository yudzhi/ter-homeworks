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
    ssh-keys           = null # переопределяется через locals
  }
}

# --------------------------------------------
# ПРАВИЛА ГРУППЫ БЕЗОПАСНОСТИ С BASTION
# --------------------------------------------

variable "security_group_name" {
  description = "Имя группы безопасности"
  type        = string
  default     = "example_dynamic"
}

variable "security_group_ingress_rules" {
  description = "Правила входящего трафика для группы безопасности"
  type = list(object({
    protocol       = string
    description    = string
    v4_cidr_blocks = list(string)
    port           = optional(number)
    from_port      = optional(number)
    to_port        = optional(number)
  }))
  default = [
    {
      protocol       = "TCP"
      description    = "SSH доступ (с любого IP для bastion)"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 22
    },
    {
      protocol       = "TCP"
      description    = "HTTP доступ"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 80
    },
    {
      protocol       = "TCP"
      description    = "HTTPS доступ"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 443
    },
    {
      protocol       = "TCP"
      description    = "Внутренний SSH (из подсети для доступа через bastion)"
      v4_cidr_blocks = ["10.0.1.0/24"]
      port           = 22
    }
  ]
}

variable "security_group_egress_rules" {
  description = "Правила исходящего трафика для группы безопасности"
  type = list(object({
    protocol       = string
    description    = string
    v4_cidr_blocks = list(string)
    port           = optional(number)
    from_port      = optional(number)
    to_port        = optional(number)
  }))
  default = [
    {
      protocol       = "TCP"
      description    = "Разрешить весь исходящий трафик"
      v4_cidr_blocks = ["0.0.0.0/0"]
      from_port      = 0
      to_port        = 65535
    }
  ]
}