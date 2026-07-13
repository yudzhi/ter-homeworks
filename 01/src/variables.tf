# variables.tf - объявление всех переменных

# Переменные для подключения к Docker
variable "docker_ssh_user" {
  description = "Имя пользователя для SSH подключения к ВМ"
  type        = string
  default     = "ubuntu" #   или yc-user
}

variable "docker_ssh_host" {
  description = "Публичный IP адрес ВМ"
  type        = string
  default     = "127.0.0.1"  # временное значение, нужно переопределить
}

variable "docker_ssh_port" {
  description = "SSH порт для подключения"
  type        = number
  default     = 22
}

# Переменные для MySQL контейнера
variable "mysql_image" {
  description = "Образ MySQL"
  type        = string
  default     = "mysql:8"
}

variable "mysql_container_name" {
  description = "Имя контейнера MySQL"
  type        = string
  default     = "mysql-wordpress"
}

variable "mysql_port" {
  description = "Внутренний порт MySQL"
  type        = number
  default     = 3306
}

variable "mysql_external_port" {
  description = "Внешний порт MySQL"
  type        = number
  default     = 3306
}

variable "mysql_database" {
  description = "Имя базы данных"
  type        = string
  default     = "wordpress"
}

variable "mysql_user" {
  description = "Имя пользователя MySQL"
  type        = string
  default     = "wordpress"
}

# Переменные для паролей (генерируются random)
variable "mysql_root_password" {
  description = "Пароль root для MySQL"
  type        = string
  sensitive   = true
}

variable "mysql_password" {
  description = "Пароль пользователя для MySQL"
  type        = string
  sensitive   = true
}

/*
# Переменные для Yandex Cloud (пока не использую)
variable "yandex_token" {
  description = "OAuth токен для Yandex Cloud"
  type        = string
  sensitive   = true
}

variable "yandex_cloud_id" {
  description = "Cloud ID в Yandex Cloud"
  type        = string
  default     = "cloud-12345"
}

variable "yandex_folder_id" {
  description = "Folder ID в Yandex Cloud"
  type        = string
  default     = "folder-67890"
}
*/