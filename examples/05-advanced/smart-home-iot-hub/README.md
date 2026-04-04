# 🏠 スマートホーム IoT ハブ

複数の IoT デバイス（シミュレーション）を制御する集中管理システム。

## 概要

このプロジェクトでは、以下の技術を統合してマイクロサービスアーキテクチャを学びます：

- **MQTT ブローカー** (Mosquitto): IoT デバイスの通信基盤
- **デバイスシミュレーター** (Python): 温度・湿度・スイッチをシミュレート
- **REST API バックエンド** (Express): デバイス管理と制御
- **React ダッシュボード**: リアルタイムデータ表示と制御
- **Docker Compose**: マルチコンテナオーケストレーション

## 📋 主な機能

- ✅ デバイス登録・管理
- ✅ リアルタイムデータ取得（MQTT）
- ✅ リモート制御（ON/OFF）
- ✅ スケジュール設定
- ✅ ログ記録
- ✅ Docker シングルコマンド起動

## 🛠️ 技術スタック

| コンポーネント | 技術 | ポート |
|-------------|------|-------|
| MQTT ブローカー | Mosquitto | 1883 |
| デバイスシミュレーター | Python + paho-mqtt | - |
| バックエンド API | Node.js + Express | 5000 |
| フロントエンド | React + Vite | 3000 |
| データベース | SQLite | - |

## 📦 セットアップ

### 前提条件

- Docker Desktop インストール済み
- Git インストール済み

### ローカル実行（Docker Compose）

```bash
cd smart-home-iot-hub
docker-compose up -d
```

アクセス:
- **ダッシュボード**: http://localhost:3000
- **API**: http://localhost:5000
- **MQTT ブローカー**: localhost:1883

### 停止

```bash
docker-compose down
```

## 📂 ディレクトリ構成

```
smart-home-iot-hub/
├── mqtt/                    # Mosquitto 設定
│   └── mosquitto.conf
├── simulator/               # Python MQTT デバイスシミュレーター
│   ├── __init__.py
│   ├── device_simulator.py  # シミュレーターロジック
│   ├── mqtt_client.py       # MQTT クライアント
│   ├── config.py            # 設定・定数
│   └── main.py              # エントリーポイント
├── backend/                 # Express REST API
│   ├── server.js            # メインサーバー
│   ├── package.json
│   ├── routes/              # API ルート
│   ├── middleware/          # ミドルウェア
│   └── test/                # テストファイル
├── frontend/                # React ダッシュボード
│   ├── package.json
│   ├── vite.config.js
│   ├── index.html
│   ├── src/
│   │   ├── App.jsx          # メインアプリ
│   │   ├── Dashboard.jsx    # ダッシュボード
│   │   ├── DeviceControl.jsx # デバイス制御
│   │   └── App.css
│   └── index.html
├── tests/                   # テストファイル
│   ├── test_simulator.py
│   └── test_backend.js
├── docker-compose.yml       # マルチコンテナ定義
├── Dockerfile.mqtt          # MQTT ブローカー
├── Dockerfile.simulator     # デバイスシミュレーター
├── Dockerfile.backend       # Express バックエンド
├── Dockerfile.frontend      # React フロントエンド
├── requirements.txt         # Python 依存関係
└── README.md               # このファイル
```

## 🔄 アーキテクチャ

```
┌─────────────────────────────────────────────────────────────┐
│  React Dashboard (port 3000)                               │
│  - デバイス一覧表示                                         │
│  - リアルタイム データ監視                                   │
│  - リモートコントロール                                      │
└────────────────┬────────────────────────────────────────────┘
                 │ HTTP REST API
┌────────────────▼────────────────────────────────────────────┐
│  Express API Server (port 5000)                            │
│  - デバイス管理                                             │
│  - スケジュール制御                                         │
│  - ログ管理                                                 │
└────────────────┬────────────────────────────────────────────┘
                 │ MQTT Communication
┌────────────────▼────────────────────────────────────────────┐
│  Mosquitto MQTT Broker (port 1883)                         │
│  - All-to-all pub/sub messaging                            │
└────────────────┬────────────────────────────────────────────┘
                 │ MQTT (Subscribe)
┌────────────────▼────────────────────────────────────────────┐
│  Python Device Simulator                                  │
│  - 温度 / 湿度センサー データ生成                            │
│  - スイッチ状態シミュレーション                              │
│  - アクチュエーター制御受信                                   │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 使用方法

### 1. デバイス登録

```bash
curl -X POST http://localhost:5000/api/devices \
  -H "Content-Type: application/json" \
  -d '{
    "name": "リビング温度センサー",
    "type": "temperature_sensor",
    "location": "living_room",
    "mqtt_topic": "home/sensors/living_room/temperature"
  }'
```

### 2. デバイス一覧取得

```bash
curl http://localhost:5000/api/devices
```

### 3. リアルタイムデータ取得

ダッシュボード（http://localhost:3000）から確認

### 4. デバイス制御

ダッシュボードから ON/OFF ボタンでデバイスを制御

## 📊 テスト

```bash
# バックエンド テスト
cd backend && npm test

# シミュレーター テスト
cd ../simulator && python -m pytest tests/
```

## 📚 学習ポイント

- ✅ MQTT プロトコルとブローカー管理
- ✅ マイクロサービスアーキテクチャ
- ✅ リアルタイム データ処理
- ✅ Docker マルチコンテナ オーケストレーション
- ✅ 非同期 JavaScript (async/await)
- ✅ React Hooks とステート管理

## 🔒 セキュリティ

- ⚠️ このプロジェクトはデモンストレーション用です
- ⚠️ 本番環境では以下の対策が必須：
  - MQTT 認証（username/password）
  - TLS/SSL 暗号化
  - API 認証（JWT трока等）
  - 入力値バリデーション（既に実装済み）

## 🐛 トラブルシューティング

### MQTT ブローカーに接続できない

```
症状: Connection refused (port 1883)
原因: Mosquitto コンテナが起動していない
解決:
$ docker-compose logs mqtt
$ docker-compose restart mqtt
```

### React が起動しない

```
症状: Vite port 3000 connection error
原因: ポート 3000 が他プロセスで使用されている
解決:
$ netstat -ano | findstr :3000  (Windows)
$ lsof -i :3000  (Mac/Linux)
```

### API 通信エラー

```
症状: CORS error or 404
原因: バックエンド起動遅延
解決:
$ docker-compose logs api
```

詳細は TROUBLESHOOTING.md を参照

## 📝 ライセンス

MIT License - See LICENSE file

## 👨‍💻 開発

**プロジェクト**: VibeCoding Learning Project  
**ID**: 013  
**フェーズ**: 3.3 (Advanced)  
**制作日**: 2026年4月  

---

**最終更新**: 2026年4月 (初版)
