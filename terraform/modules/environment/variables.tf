variable "environment" {
  description = "環境名（例: development, staging, qa）"
  type        = string
}

variable "subnet" {
  description = "ネットワークのサブネット（例: 172.20.0.0/24）"
  type        = string
}

variable "gateway" {
  description = "ネットワークのゲートウェイ（例: 172.20.0.1）"
  type        = string
}

variable "flask_ip" {
  description = "Flask APIコンテナのIPアドレス"
  type        = string
}

variable "mysql_ip" {
  description = "MySQLコンテナのIPアドレス"
  type        = string
}

variable "external_port" {
  description = "Flask APIの外部ポート"
  type        = number
}

variable "db_root_password" {
  description = "MySQLのrootパスワード"
  type        = string
  default     = "root"
}

variable "db_name" {
  description = "データベース名"
  type        = string
}

variable "db_user" {
  description = "データベースユーザー名"
  type        = string
}

variable "db_password" {
  description = "データベースパスワード"
  type        = string
}

variable "app_source_path" {
  description = "Flaskアプリのソースパス"
  type        = string
}
