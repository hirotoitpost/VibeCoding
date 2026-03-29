"""
Flask Web Application - ダッシュボード

REST API + ダッシュボード
"""

import logging
import json
from datetime import datetime, timedelta
from flask import Flask, render_template, jsonify, request
from flask_cors import CORS

from src.config import get_config
from src.database import Database

# ログ設定
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - [%(name)s] - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# Flask アプリ作成
app = Flask(__name__)
CORS(app)

# 設定
config = get_config()
app.config.update(
    SECRET_KEY=config.flask.secret_key,
    JSON_SORT_KEYS=False,
)

# データベース初期化
db = Database(
    database_url=config.database.url,
    echo=config.database.echo,
)

logger.info(f"Flask App initialized: {config.flask.env}")


# ============================================================
# API エンドポイント
# ============================================================

@app.route("/", methods=["GET"])
def index():
    """ダッシュボードページ"""
    return render_template("dashboard.html")


@app.route("/api/health", methods=["GET"])
def health():
    """ヘルスチェック"""
    return jsonify({
        "status": "ok",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0",
    })


@app.route("/api/sensors", methods=["GET"])
def get_sensors():
    """
    全センサー情報
    
    Returns:
        {
            "sensors": [
                {"room": "room1", "last_reading": {...}},
                ...
            ]
        }
    """
    try:
        # 最新の計測値を取得
        readings = db.get_latest_readings(limit=1000)
        
        # ルーム別に最新値をマッピング
        sensors_map = {}
        for reading in readings:
            if reading.room not in sensors_map:
                sensors_map[reading.room] = reading.to_dict()
        
        sensors = list(sensors_map.values())
        
        return jsonify({
            "status": "ok",
            "count": len(sensors),
            "sensors": sensors,
        })
    except Exception as e:
        logger.error(f"Error getting sensors: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500


@app.route("/api/readings", methods=["GET"])
def get_readings():
    """
    計測値一覧（ページネーション対応）
    
    Query Parameters:
        - room: ルーム名（オプション）
        - limit: 取得件数（デフォルト: 100）
        - hours: 過去何時間分（デフォルト: 24）
    
    Returns:
        {"status": "ok", "readings": [...]}
    """
    try:
        limit = request.args.get("limit", 100, type=int)
        hours = request.args.get("hours", 24, type=int)
        room = request.args.get("room", None)
        
        if room:
            readings = db.get_readings_by_room(
                room=room,
                limit=limit,
                hours=hours,
            )
        else:
            readings = db.get_latest_readings(limit=limit)
        
        return jsonify({
            "status": "ok",
            "count": len(readings),
            "readings": [r.to_dict() for r in readings],
        })
    except Exception as e:
        logger.error(f"Error getting readings: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500


@app.route("/api/readings/latest", methods=["GET"])
def get_latest_readings():
    """最新計測値"""
    try:
        readings = db.get_latest_readings(limit=10)
        return jsonify({
            "status": "ok",
            "readings": [r.to_dict() for r in readings],
        })
    except Exception as e:
        logger.error(f"Error: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500


@app.route("/api/statistics", methods=["GET"])
def get_statistics():
    """
    統計情報
    
    Query Parameters:
        - room: ルーム名
        - hours: 対象期間（時間）
    """
    try:
        room = request.args.get("room", None)
        hours = request.args.get("hours", 24, type=int)
        
        if not room:
            return jsonify({
                "status": "error",
                "message": "room パラメータが必須です"
            }), 400
        
        stats = db.get_statistics(room=room, hours=hours)
        
        return jsonify({
            "status": "ok",
            "statistics": stats,
        })
    except Exception as e:
        logger.error(f"Error: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500


@app.route("/api/alarms", methods=["GET"])
def get_alarms():
    """
    最近のアラーム
    
    Query Parameters:
        - limit: 取得件数
        - hours: 対象期間
    """
    try:
        limit = request.args.get("limit", 50, type=int)
        hours = request.args.get("hours", 24, type=int)
        
        alarms = db.get_recent_alarms(limit=limit, hours=hours)
        
        return jsonify({
            "status": "ok",
            "count": len(alarms),
            "alarms": [a.to_dict() for a in alarms],
        })
    except Exception as e:
        logger.error(f"Error: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500


# ============================================================
# エラーハンドリング
# ============================================================

@app.errorhandler(404)
def not_found(error):
    """404 エラー"""
    return jsonify({"status": "error", "message": "Not found"}), 404


@app.errorhandler(500)
def internal_error(error):
    """500 エラー"""
    logger.error(f"Internal error: {error}")
    return jsonify({"status": "error", "message": "Internal server error"}), 500


# ============================================================
# デバッグ実行
# ============================================================

if __name__ == "__main__":
    app.run(
        host=config.flask.host,
        port=config.flask.port,
        debug=config.flask.debug,
    )
