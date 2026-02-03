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
