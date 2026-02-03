terraform {
  required_version = ">= 1.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}


provider "docker" {
  # ローカルDockerに接続
}

locals {
  environment      = "development"
  db_root_password = "root"
  db_name          = "development_db"
  db_user          = "development_user"
  db_password      = "development_password"
}

# ネットワーク
resource "docker_network" "this" {
  name = "${local.environment}_network"
}

# Dockerイメージのビルド
resource "docker_image" "flask_app" {
  name = "flask-app:latest"
  build {
    context    = "${path.module}/../app"
    dockerfile = "Dockerfile"
  }
}

resource "docker_image" "mysql" {
  name = "mysql:8.4"
}

# Dockerコンテナの起動
resource "docker_container" "flask_app" {
  name  = "flask-app"
  image = docker_image.flask_app.image_id

  networks_advanced {
    name = docker_network.this.name
  }

  ports {
    internal = 8000
    external = 12080
  }

  env = [
    "ENVIRONMENT=${local.environment}",
    "API_PORT=8000",
    "DB_HOST=db",
    "DB_PORT=3306",
    "DB_NAME=${local.db_name}",
    "DB_USER=${local.db_user}",
    "DB_PASSWORD=${local.db_password}",
  ]
}

resource "docker_container" "mysql" {
  name  = "db"
  image = docker_image.mysql.image_id

  networks_advanced {
    name = docker_network.this.name
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${local.db_root_password}",
    "MYSQL_DATABASE=${local.db_name}",
    "MYSQL_USER=${local.db_user}",
    "MYSQL_PASSWORD=${local.db_password}",
  ]
}

# 出力
output "container_id" {
  value = docker_container.flask_app.id
}

output "container_name" {
  value = docker_container.flask_app.name
}
