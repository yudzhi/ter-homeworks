terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.5.0"
    }
  }
  required_version = "~>1.12.0" /*Многострочный комментарий.
 Требуемая версия terraform */
}

/* Задание 1  
provider "docker" {} /**/

/* Задание 2 УДАЛИТЬ --> */
# # Подключаемся к удаленному Docker-демону через SSH
provider "docker" {
  host     = "ssh://${var.docker_ssh_user}@${var.docker_ssh_host}:${var.docker_ssh_port}"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}
/**/

#однострочный комментарий

# Задание 1
/*
resource "random_password" "random_string" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}
*/

# Задание 2 
# Генерируем пароль для root 
resource "random_password" "mysql_root_password" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

# Генерируем пароль для пользователя wordpress
resource "random_password" "mysql_wordpress_password" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

# Задание 1 
/*
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  #name  = "example_${random_password.random_string.result}"
  name = "hello_world"

  ports {
    internal = 80
    external = 9090
  }
}
*/

# Задание 2
/**/
# Скачиваем образ MySQL
resource "docker_image" "mysql" {
  name         = var.mysql_image
  keep_locally = true
}

# Запускаем контейнер MySQL
resource "docker_container" "mysql" {
  image = docker_image.mysql.image_id
  name  = var.mysql_container_name

  ports {
      internal = var.mysql_port
      external = var.mysql_external_port
      ip       = "127.0.0.1"
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${coalesce(var.mysql_root_password, random_password.mysql_root_password.result)}",
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${coalesce(var.mysql_password, random_password.mysql_wordpress_password.result)}",
    "MYSQL_ROOT_HOST=%"
  ]

  restart = "unless-stopped"
}

# Выводим пароли для информации (но в логах они будут скрыты из-за sensitive)
output "mysql_root_password" {
  value     = coalesce(var.mysql_root_password, random_password.mysql_root_password.result)
  sensitive = true
}

output "mysql_wordpress_password" {
  value     = coalesce(var.mysql_password, random_password.mysql_wordpress_password.result)
  sensitive = true
}

output "mysql_container_name" {
  value = var.mysql_container_name
}

output "mysql_connection_string" {
  value = "mysql://${var.mysql_user}:${coalesce(var.mysql_password, random_password.mysql_wordpress_password.result)}@${var.docker_ssh_host}:${var.mysql_external_port}/${var.mysql_database}"
  sensitive = true
}
