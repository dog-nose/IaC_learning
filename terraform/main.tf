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

# =============================================================================
# 環境モジュール呼び出し
# =============================================================================

module "dev" {
  source = "./modules/environment"

  environment     = "development"
  subnet          = "172.20.0.0/24"
  gateway         = "172.20.0.1"
  flask_ip        = "172.20.0.10"
  mysql_ip        = "172.20.0.20"
  external_port   = 12080
  db_name         = "development_db"
  db_user         = "development_user"
  db_password     = "development_password"
  app_source_path = "${path.module}/../app"
}

module "staging" {
  source = "./modules/environment"

  environment     = "staging"
  subnet          = "172.20.1.0/24"
  gateway         = "172.20.1.1"
  flask_ip        = "172.20.1.10"
  mysql_ip        = "172.20.1.20"
  external_port   = 12081
  db_name         = "staging_db"
  db_user         = "staging_user"
  db_password     = "staging_password"
  app_source_path = "${path.module}/../app"
}

module "qa" {
  source = "./modules/environment"

  environment     = "qa"
  subnet          = "172.20.2.0/24"
  gateway         = "172.20.2.1"
  flask_ip        = "172.20.2.10"
  mysql_ip        = "172.20.2.20"
  external_port   = 12082
  db_name         = "qa_db"
  db_user         = "qa_user"
  db_password     = "qa_password"
  app_source_path = "${path.module}/../app"
}

# =============================================================================
# 共通bastion（全環境のネットワークに接続）
# =============================================================================

resource "docker_image" "bastion" {
  name = "bastion:latest"
  build {
    context    = "${path.module}/../bastion"
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "bastion" {
  name  = "bastion"
  image = docker_image.bastion.image_id

  networks_advanced {
    name         = module.dev.network_name
    ipv4_address = "172.20.0.11"
  }

  networks_advanced {
    name         = module.staging.network_name
    ipv4_address = "172.20.1.11"
  }

  networks_advanced {
    name         = module.qa.network_name
    ipv4_address = "172.20.2.11"
  }
}
