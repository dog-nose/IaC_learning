FROM python:3.11-slim

WORKDIR /app

# 依存関係の解決
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# アプリケーションの配置
COPY main.py .

# アプリケーション実行ユーザの作成
RUN useradd -m appuser
USER appuser

# デフォルトポート
EXPOSE 5000

# アプリケーションの起動
CMD ["python", "main.py"]
