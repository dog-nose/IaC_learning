terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# ネットワーク
resource "docker_network" "this" {
  name = "${var.environment}_network"
  ipam_config {
    subnet  = var.subnet
    gateway = var.gateway
  }
}

# Dockerイメージ
resource "docker_image" "flask_app" {
  name = "flask-app-${var.environment}:latest"
  build {
    context    = var.app_source_path
    dockerfile = "Dockerfile"
  }
}

resource "docker_image" "mysql" {
  name = "mysql:8.4"
}

# Flask APIコンテナ
resource "docker_container" "flask_app" {
  name  = "${var.environment}-flask-app"
  image = docker_image.flask_app.image_id

  labels {
    label = "environment"
    value = var.environment
  }

  networks_advanced {
    name         = docker_network.this.name
    ipv4_address = var.flask_ip
  }

  ports {
    internal = 8000
    external = var.external_port
  }

  env = [
    "ENVIRONMENT=${var.environment}",
    "API_PORT=8000",
    "DB_HOST=${var.environment}-db",
    "DB_PORT=3306",
    "DB_NAME=${var.db_name}",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_password}",
  ]
}

# MySQLコンテナ
resource "docker_container" "mysql" {
  name  = "${var.environment}-db"
  image = docker_image.mysql.image_id

  labels {
    label = "environment"
    value = var.environment
  }

  networks_advanced {
    name         = docker_network.this.name
    ipv4_address = var.mysql_ip
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${var.db_root_password}",
    "MYSQL_DATABASE=${var.db_name}",
    "MYSQL_USER=${var.db_user}",
    "MYSQL_PASSWORD=${var.db_password}",
  ]
}
