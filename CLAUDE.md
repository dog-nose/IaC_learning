# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

IaC学習用リポジトリ。Terraformを使ってローカルDockerコンテナ群（Flask API + MySQL + Bastion）をオーケストレーションする。3環境（development, staging, qa）を同一Dockerホスト上で同時稼働させる。

## Build & Deploy Commands

```bash
# Terraformの初期化（初回のみ）
cd terraform && terraform init

# インフラの構築・更新
cd terraform && terraform plan
cd terraform && terraform apply

# インフラの破棄
cd terraform && terraform destroy
```

## Testing / Verification

```bash
# 各環境のFlask APIの確認
curl http://localhost:12080/health   # development
curl http://localhost:12081/health   # staging
curl http://localhost:12082/health   # qa

# DB接続確認
curl http://localhost:12080/db-check
curl http://localhost:12081/db-check
curl http://localhost:12082/db-check

# Bastionコンテナから全環境への疎通確認
docker exec -it bastion bash
ping 172.20.0.10   # development flask-app
ping 172.20.1.10   # staging flask-app
ping 172.20.2.10   # qa flask-app
ping 172.20.0.20   # development db
ping 172.20.1.20   # staging db
ping 172.20.2.20   # qa db

# 各環境のDBへのログイン例
mysql -h development-db -u development_user -pdevelopment_password development_db
mysql -h staging-db -u staging_user -pstaging_password staging_db
mysql -h qa-db -u qa_user -pqa_password qa_db
```

## Architecture

モジュール化された3環境構成。環境固有リソースは `terraform/modules/environment/` で定義し、ルートの `main.tf` から3回呼び出す。bastionは全環境に跨がるためルートに定義。

### 環境一覧

| 環境 | サブネット | Flask IP | MySQL IP | 外部ポート |
|---|---|---|---|---|
| development | 172.20.0.0/24 | 172.20.0.10 | 172.20.0.20 | 12080 |
| staging | 172.20.1.0/24 | 172.20.1.10 | 172.20.1.20 | 12081 |
| qa | 172.20.2.0/24 | 172.20.2.10 | 172.20.2.20 | 12082 |

### コンテナ構成（7コンテナ）

- **{env}-flask-app** — Python Flask API。ポート8000→ホストポートにマッピング
- **{env}-db** — MySQL 8.4。ポート公開なし（内部ネットワークのみ）
- **bastion** (172.20.{0,1,2}.11) — Alpine Linuxベースのデバッグ用コンテナ。全3ネットワークに接続

## Key Files

- `terraform/main.tf` — ルート定義（provider、module呼び出し×3、bastion）
- `terraform/outputs.tf` — ルート出力（各環境のFlask URL）
- `terraform/modules/environment/main.tf` — 環境モジュール（network, flask, mysql）
- `terraform/modules/environment/variables.tf` — モジュール入力変数
- `terraform/modules/environment/outputs.tf` — モジュール出力
- `app/main.py` — Flask APIアプリケーション（`/`, `/health`, `/db-check` エンドポイント）
- `app/Dockerfile` — Flask APIイメージ定義（python:3.11-slim、非rootユーザー実行）
- `bastion/Dockerfile` — Bastionイメージ定義（alpine:3.20、ネットワークツール群）

## Conventions

- ドキュメント・コミットメッセージは日本語
- DB接続情報はモジュール変数として管理し、環境変数としてコンテナに注入
- `.tfstate` ファイルはgit管理外
- 環境名はコンテナ名・ネットワーク名・DB名等のプレフィックスとして使用
