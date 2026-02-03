# セットアップ


Dockerを使用してInfrastructure as Code (IaC)を学習するためのセットアップ


## ディレクトリ構成

```
├─ app/
│  ├─ main.py
│  └─ requirements.txt
```

## ファイル


```app/main.py
# -*- coding: utf-8 -*-
import os

from flask import Flask, jsonify
import mysql.connector
from mysql.connector import Error


app = Flask(__name__)


def get_db_config():
    return {
        'host': os.getenv('DB_HOST', 'localhost'),
        'port': int(os.getenv('DB_PORT', 3306)),
        'user': os.getenv('DB_USER', 'root'),
        'password': os.getenv('DB_PASSWORD', ''),
        'database': os.getenv('DB_NAME', 'app')
    }


@app.route('/health')
def health():
    """
    APIが可動していることを確認するAPI
    """
    return jsonify({
        'status': 'ok',
        'environment': os.getenv('ENVIRONMENT', 'unknown'),
    })


@app.route('/db-check')
def db_check():
    """
    DB接続を確認するAPI
    """
    config = get_db_config()
    try:
        connection = mysql.connector.connect(**config)
        if connection.is_connected():
            cursor = connection.cursor()
            cursor.execute("SELECT 1")
            result = cursor.fetchone()
            cursor.close()
            connection.close()
            if result and result[0] == 1:
                return jsonify({'db_status': 'connected'})
    except Error as e:
        return jsonify({'db_status': 'error', 'message': str(e)}), 500

    return jsonify({'db_status': 'disconnected'}), 500


@app.route('/')
def index():
    return jsonify({
        'message': 'Welcome to the Flask MySQL App',
        'endpoints': {
            '/health': 'Check application health',
            '/db-check': 'Check database connectivity'
        }
    })


if __name__ == '__main__':
    port = int(os.getenv('API_PORT', 5000))
    app.run(host='0.0.0.0', port=port)

```

```app/requirements.txt
flask==3.0.0
mysql-connector-python==8.2.0
```


## pythonの動作確認

flaskアプリケーションを起動させる

```bash
$ cd app && API_PORT=12345 python main.py
 * Serving Flask app 'main'
 * Debug mode: off
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:12345
 * Running on http://192.168.10.120:12345
Press CTRL+C to quit
```

別ターミナルでAPIにアクセスできることを確認する

```bash
$ curl http://localhost:12345/health
{"environment":"unknown","status":"ok"}
$ curl http://localhost:12345/db-check
{"db_status":"error","message":"2003 (HY000): Can't connect to MySQL server on 'localhost:3306' (61)"}
```

- 環境変数を設定していないため、 `unknown` と表示される
- DB接続情報を設定していないため、DB接続エラーとなる
