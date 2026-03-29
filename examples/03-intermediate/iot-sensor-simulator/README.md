# IoT センサーシミュレーター

> **ID**: 011 | **フェーズ**: 3.2.B | **難易度**: ⭐⭐⭐

リアルタイム温度・湿度センサーのシミュレーターおよびダッシュボード。  
MQTT ブローカーで データ配信し、SQLite またはInfluxDB に保存・可視化。

## 📋 概要

### 機能
- **センサーシミュレーション**: 温度（15-35℃）・湿度（30-90%）の疑似データ生成
- **MQTT パブリッシュ**: リアルタイムデータを MQTT ブローカーに配信
- **データベース保存**: 時系列データを SQLite/InfluxDB に記録
- **ダッシュボード**: Flask + Chart.js で リアルタイム表示
- **アラーム機能**: 閾値超過時にアラート表示

### 技術スタック
| コンポーネント | 技術 | 説明 |
|-------------|------|------|
| **言語** | Python 3.8+ | - |
| **MQTT ブローカー** | Eclipse Mosquitto | Docker Compose |
| **データベース** | SQLite (推奨) | InfluxDB も対応予定 |
| **可視化** | Flask + Chart.js | リアルタイムダッシュボード |
| **テスト** | pytest + pytest-asyncio | Unit + Integration テスト |
| **実行環境** | Docker Compose | ローカル開発対応 |

## 🚀 クイックスタート

### 前提条件
- Python 3.8+
- Docker & Docker Compose
- pip パッケージマネージャー

### セットアップ

```bash
# 1. 環境変数設定
cp .env.example .env

# 2. Python パッケージ インストール
pip install -r requirements.txt

# 3. Docker コンテナ起動
docker-compose up -d

# 4. センサーシミュレーター起動
python -m src.main

# 5. ダッシュボード表示
# ブラウザで http://localhost:5000 を開く
```

## 📚 ドキュメント

| ドキュメント | 内容 |
|-----------|------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | 全体設計・モジュール・データフロー |
| [MQTT_PROTOCOL.md](MQTT_PROTOCOL.md) | MQTT トピック・メッセージフォーマット |
| [API_DOCUMENTATION.md](API_DOCUMENTATION.md) | REST API リファレンス |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | よくある質問・解決策 |

## 🛠️ プロジェクト構造

```
iot-sensor-simulator/
├── README.md ......................... このファイル
├── requirements.txt ................. Python 依存パッケージ
├── .env.example ..................... 環境変数テンプレート
├── docker-compose.yml ............... コンテナ設定
│
├── src/
│   ├── __init__.py
│   ├── main.py ....................... エントリーポイント
│   ├── sensor_simulator.py .......... センサーシミュレーション
│   ├── mqtt_client.py ............... MQTT クライアント（Publisher）
│   ├── mqtt_subscriber.py ........... MQTT サブスクライバー
│   ├── database.py .................. SQLite/InfluxDB 操作
│   ├── alarm_manager.py ............ アラーム管理・ロジック
│   └── config.py ................... 設定管理
│
├── web/
│   ├── app.py ....................... Flask アプリケーション
│   ├── models.py ................... SQLAlchemy モデル
│   ├── routes.py ................... API エンドポイント
│   ├── static/
│   │   ├── style.css
│   │   ├── chart.js
│   │   └── dashboard.js
│   └── templates/
│       ├── base.html
│       ├── dashboard.html
│       └── settings.html
│
├── tests/
│   ├── __init__.py
│   ├── test_sensor_simulator.py .... ユニットテスト
│   ├── test_mqtt_client.py ......... MQTT テスト
│   ├── test_database.py ............ DB テスト
│   └── test_integration.py ......... 統合テスト
│
└── TROUBLESHOOTING.md .............. トラブルシューティング
```

## 📊 API エンドポイント

### ダッシュボード
```
GET  /                    ダッシュボードページ
GET  /api/sensors         センサー一覧
GET  /api/readings        直近100件の計測値
GET  /api/readings/latest 最新計測値
```

### 管理
```
POST   /api/alarms         アラーム設定作成
GET    /api/alarms         アラーム設定一覧
PUT    /api/alarms/:id     アラーム設定更新
DELETE /api/alarms/:id     アラーム設定削除
```

## 🔌 MQTT トピック構造

```
sensor/temp/room1          温度 (℃)
sensor/humidity/room1      湿度 (%)
sensor/alarm/high-temp     高温アラーム
sensor/status              センサーステータス
```

## 🧪 テスト実行

```bash
# すべてのテスト実行
pytest

# カバレッジ確認
pytest --cov=src --cov-report=html

# 特定テストのみ
pytest tests/test_sensor_simulator.py -v
```

## 📝 使用例

### センサーシミュレーター起動
```python
from src.sensor_simulator import SensorSimulator

simulator = SensorSimulator()
simulator.start(interval=5)  # 5秒ごとにデータ生成
```

### MQTT パブリッシュ
```python
from src.mqtt_client import MQTTPublisher

publisher = MQTTPublisher("localhost", 1883)
publisher.publish_temperature("room1", 25.5)
```

### データベース保存
```python
from src.database import Database

db = Database("sensor_data.db")
db.save_reading(sensor_id="room1", temp=25.5, humidity=60.0)
```

## 🔍 ダッシュボード機能

### リアルタイムグラフ
- 温度・湿度の時系列グラフ（Chart.js）
- 自動更新（5秒間隔）

### アラーム表示
- 閾値超過時に色付け（赤）
- 通知パネルに表示

### 統計情報
- 本日最高・最低気温
- 24時間平均湿度
- センサーステータス

## 🐛 トラブルシューティング

### MQTT 接続エラー
```bash
# Mosquitto ブローカーが起動しているか確認
docker-compose ps

# ログ確認
docker-compose logs mosquitto
```

### データベースロック
```bash
# SQLite ロック解除
rm sensor_data.db
docker-compose restart
```

詳細は [TROUBLESHOOTING.md](TROUBLESHOOTING.md) を参照。

## 📖 学習ポイント

### Vibe Coding 体験
✅ **AI が得意な領域**:
- センサーシミュレーション ロジック実装
- MQTT クライアント実装
- Flask Web UI 開発
- テストコード生成

⚠️ **AI の判断が必要な領域**:
- MQTT トピック設計（ビジネス要件と関連）
- アラームロジック（ルール定義）
- データベーススキーマ（パフォーマンス考慮）

❌ **AI が対応困難な領域**:
- Docker・環境セットアップ
- 実デバイス（ハードウェア）インテグレーション
- MQTT ブローカー詳細設定

## 📞 参考資料

- [Mosquitto Documentation](https://mosquitto.org/)
- [paho-mqtt ドキュメント](https://github.com/eclipse/paho.mqtt.python)
- [Flask 公式ドキュメント](https://flask.palletsprojects.com/)
- [Chart.js 公式ドキュメント](https://www.chartjs.org/)

## 📅 ステータス

| フェーズ | ステータス | 予定 |
|---------|----------|------|
| スケーフォルド | ✅ 完了 | - |
| センサーシミュレーター | 🔄 実装中 | Session 9 |
| MQTT 統合 | ⏳ 予定 | Session 9 |
| Web ダッシュボード | ⏳ 予定 | Session 10 |
| テスト・検証 | ⏳ 予定 | Session 10-11 |

---

**最終更新**: 2026年3月29日（Session 9 開始）  
**管理**: ID 011 - IoT センサーシミュレーター
