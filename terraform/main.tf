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

# Dockerイメージのビルド
resource "docker_image" "flask_app" {
  name = "flask-app:latest"
  build {
    context    = "${path.module}/../app"
    dockerfile = "Dockerfile"
  }
}

# Dockerコンテナの起動
resource "docker_container" "flask_app" {
  name  = "flask-app"
  image = docker_image.flask_app.image_id

  ports {
    internal = 8000
    external = 12080
  }

  env = [
    "ENVIRONMENT=development",
    "API_PORT=8000",
  ]
}

# 出力
output "container_id" {
  value = docker_container.flask_app.id
}

output "container_name" {
  value = docker_container.flask_app.name
}
