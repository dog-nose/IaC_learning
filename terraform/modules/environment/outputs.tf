output "network_name" {
  description = "Dockerネットワーク名"
  value       = docker_network.this.name
}

output "flask_container_name" {
  description = "Flask APIコンテナ名"
  value       = docker_container.flask_app.name
}

output "flask_url" {
  description = "Flask APIのURL"
  value       = "http://localhost:${var.external_port}"
}
