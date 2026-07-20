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

variable "subnet_cidr_a" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "CIDR block for subnet in zone A"
}

variable "subnet_cidr_b" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
  description = "CIDR block for subnet in zone B"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

### Переменные для именования (общие для всех ВМ)

variable "project_name" {
  type        = string
  default     = "netology"
  description = "Project name prefix for all resources"
}

variable "environment" {
  type        = string
  default     = "develop"
  description = "Environment: dev, staging, prod"
}

variable "platform_type" {
  type        = string
  default     = "platform"
  description = "Platform type for resource naming"
}

###ssh vars

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