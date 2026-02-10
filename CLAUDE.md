# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

IaC学習用リポジトリ。Terraformを使ってローカルDockerコンテナ群（Flask API + MySQL + Bastion）をオーケストレーションする。

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
# Flask APIの確認
curl http://localhost:12080/
curl http://localhost:12080/health
curl http://localhost:12080/db-check

# Bastionコンテナからの内部ネットワーク確認
docker exec -it bastion bash
ping 172.20.0.10        # flask-app
ping 172.20.0.20        # db
telnet db 3306
mysql -h db -u development_user -pdevelopment_password development_db
```

## Architecture

3コンテナ構成、すべてTerraform (`terraform/main.tf`) で管理:

- **flask-app** (172.20.0.10) — Python Flask API。ポート8000→ホスト12080にマッピング
- **db** (172.20.0.20) — MySQL 8.4。ポート公開なし（内部ネットワークのみ）
- **bastion** (172.20.0.11) — Alpine Linuxベースのデバッグ用コンテナ。ping/telnet/curl/mysql-client等を搭載

全コンテナは `development_network` (172.20.0.0/16) で接続される。

## Key Files

- `terraform/main.tf` — 全インフラ定義（ネットワーク、イメージビルド、コンテナ起動）
- `app/main.py` — Flask APIアプリケーション（`/`, `/health`, `/db-check` エンドポイント）
- `app/Dockerfile` — Flask APIイメージ定義（python:3.11-slim、非rootユーザー実行）
- `bastion/Dockerfile` — Bastionイメージ定義（alpine:3.20、ネットワークツール群）

## Conventions

- ドキュメント・コミットメッセージは日本語
- DB接続情報はTerraformの `locals` ブロックで管理し、環境変数としてコンテナに注入
- `.tfstate` ファイルはgit管理外
