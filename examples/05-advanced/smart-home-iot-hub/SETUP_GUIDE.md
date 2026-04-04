# 🏠 Smart Home IoT Hub - セットアップガイド

このドキュメントでは、スマートホーム IoT ハブの環境構築と起動手順を説明します。

## 前提条件

- Docker Desktop (最新バージョン)
  - Windows 10/11, Mac, Linux で動作確認済み
  - WSL 2 バックエンド推奨（Windows）
- Git
- ターミナル / PowerShell

## ステップ 1: リポジトリのクローン

```bash
cd /your/workspace
git clone https://github.com/hirotoitpost/VibeCoding.git
cd VibeCoding/examples/05-advanced/smart-home-iot-hub
```

## ステップ 2: 環境変数設定

```bash
# .env.example をコピーして .env を作成
cp .env.example .env

# .env を必要に応じて編集
# （ほとんどの場合、デフォルト値で OK）
```

Windows PowerShell ユーザーの場合:
```powershell
Copy-Item .env.example .env
```

## ステップ 3: Docker イメージのビルド

```bash
docker-compose build
```

初回実行時は 5-10 分程度かかります。

## ステップ 4: コンテナ起動

```bash
docker-compose up -d
```

### 起動状態の確認

```bash
docker-compose ps
```

出力例:
```
NAME                        COMMAND                  SERVICE         STATUS
smart-home-mqtt             "/docker-entrypoint…"   mqtt            Up 2 minutes (healthy)
smart-home-simulator        "python -m simulato…"   simulator       Up 2 minutes
smart-home-api              "npm start"              api             Up 2 minutes (healthy)
smart-home-frontend         "npm run dev -- --h…"   frontend        Up 2 minutes
```

すべてのコンテナが `Up` 状態であることを確認してください。

## ステップ 5: ダッシュボードへアクセス

### ブラウザで開く

```
http://localhost:3000
```

画面表示:
- **ヘッダー**: 🏠 Smart Home IoT Hub
- **登録セクション**: デバイス登録フォーム
- **ダッシュボード**: デバイス一覧（最初は空）

## ステップ 6: デバイス動作確認

### ステップ 3 の後 60～90 秒待機

Python シミュレーターが起動し、仮想デバイスからのデータが MQTT ブローカーに送信されます。

### ダッシュボードで確認できること

- 🌡️ **温度**: リアルタイムで更新（15-30°C 範囲）
- 💧 **湿度**: リアルタイムで更新（30-80%）  
- 💡 **ライト**: ON/OFF 状態
- ❄️ **AC**: ON/OFF 状態

## 停止・クリーンアップ

### コンテナ停止

```bash
docker-compose stop
```

### コンテナ削除

```bash
docker-compose down
```

### 全データ削除（SQLite + MQTT ログ）

```bash
docker-compose down -v
```

## トラブルシューティング

### ❌ コンテナが起動しない

```bash
# ログ確認
docker-compose logs mqtt
docker-compose logs simulator
docker-compose logs api
docker-compose logs frontend

# ポート競合確認（Windows PowerShell）
Get-NetTCPConnection -LocalPort 1883  # MQTT ポート
Get-NetTCPConnection -LocalPort 5000  # API ポート
Get-NetTCPConnection -LocalPort 3000  # Frontend ポート

# Mac/Linux
lsof -i :1883
lsof -i :5000
lsof -i :3000
```

**解決策**: 競合しているポートを別の番号に変更（docker-compose.yml を編集）

### ❌ "Connection refused" MQTT エラー

```
症状: simulator が MQTT に接続できない
原因: mqtt コンテナが起動していない
```

**確認**:
```bash
docker-compose logs mqtt
docker-compose restart mqtt
```

### ❌ ダッシュボードが空白（デバイスが表示されない）

```
症状: 画面は読み込まれるが、デバイスが見えない
原因: API サーバーが応答していない
```

**確認**:
```bash
# API ヘルスチェック
curl http://localhost:5000/health

# ローカルデバイス一覧
curl http://localhost:5000/api/devices
```

**解決策**: API ログを確認して再起動
```bash
docker-compose logs api
docker-compose restart api
```

### ❌ ダッシュボードが真っ白

```
症状: React が読み込まれていない
原因: Vite 開発サーバーが起動していない
```

**確認**:
```bash
docker-compose logs frontend
```

**解決策**: フロントエンドを再起動
```bash
docker-compose restart frontend
```

ブラウザキャッシュをクリア (Ctrl+Shift+Delete) してリロード

## API エンドポイント

### デバイス管理

```bash
# 全デバイス取得
curl http://localhost:5000/api/devices

# デバイス登録
curl -X POST http://localhost:5000/api/devices \
  -H "Content-Type: application/json" \
  -d '{
    "name": "キッチンセンサー",
    "type": "temperature_sensor",
    "location": "kitchen",
    "mqtt_topic": "home/sensors/kitchen/temperature"
  }'

# デバイス詳細
curl http://localhost:5000/api/devices/{device_id}

# デバイス削除
curl -X DELETE http://localhost:5000/api/devices/{device_id}
```

### デバイスデータ

```bash
# データ記録
curl -X POST http://localhost:5000/api/devices/{device_id}/data \
  -H "Content-Type: application/json" \
  -d '{"value": 23.5, "unit": "°C"}'

# データ取得
curl http://localhost:5000/api/devices/{device_id}/data?limit=10
```

## パフォーマン스モニタリング

### リソース使用状況

```bash
docker stats
```

### ログリアルタイム監視

```bash
# 全コンテナ
docker-compose logs -f

# 特定コンテナのみ
docker-compose logs -f api
```

## 本番環境への展開

⚠️ **注意**: 本ガイドはデモ用です。本番環境では以下の対策が必須です：

1. **MQTT 認証**: `mosquitto.conf` に username/password 設定
2. **SSL/TLS**: 暗号化通信の有効化
3. **環境変数**: `.env` ファイルを `.gitignore` に追加
4. **バックアップ**: SQLite データベースの定期バックアップ
5. **ログレベル**: `LOG_LEVEL=WARNING` に変更

## 開発モード

### コード変更時の自動リロード

フロントエンドは Vite のホットリロード、バックエンド/シミュレーターは Docker 再起動で反応します。

```bash
# 変更をリアルタイムで反映（開発）
docker-compose down
docker-compose up -d
```

### Python 環境（ローカル開発用）

```bash
# Python 仮想環境
python -m venv .venv
source .venv/bin/activate  # Mac/Linux
.venv\Scripts\activate      # Windows

# 依存関係インストール
pip install -r requirements.txt

# シミュレーター単体実行
python -m simulator.main
```

## よくある質問（FAQ）

**Q) ダッシュボードで古いデータが表示されている**
> A) キャッシュをクリア (Ctrl+Shift+Delete) またはプライベートウィンドウで開く

**Q) デバイスを登録したが、データが更新されない**
> A) MQTT トピックが重複していないか確認。シミュレーターは定められたトピックのみアクティブです

**Q) Windows で "Device or resource busy" エラーが出る**
> A) WSL 2 が有効になっているか確認。`wsl --list --verbose` で Linux の version 2 を確認

**Q) Mac の Docker Desktop で メモリ不足エラー**
> A) Docker Desktop の メモリ割り当てを 4GB 以上に増加 (Preferences → Resources)

---

**最終更新**: 2026年4月  
**サポート**: [GitHub Issues](https://github.com/hirotoitpost/VibeCoding/issues)
