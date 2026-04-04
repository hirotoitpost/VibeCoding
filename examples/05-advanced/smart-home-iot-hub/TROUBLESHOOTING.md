# 🐛 トラブルシューティング - Smart Home IoT Hub

このドキュメントでは、よくある問題と解決方法を説明します。

## 問題 1: Docker コンテナが起動しない

### 症状
```
docker-compose up -d
# エラーメッセージ: Error response from daemon
```

### 原因

1. **Docker Desktop が起動していない**
   - Windows/Mac ばイタスクバーで確認

2. **ポート競合**
   - 他のアプリケーションが同じポート (1883, 5000, 3000) を使用中

3. **ディスク容量不足**
   - Docker イメージビルドに 2-3 GB 必要

### 解決方法

**ステップ 1: Docker デーモン状態確認**
```powershell
# Windows PowerShell
docker version
```

**ステップ 2: ポート競合確認**
```powershell
# Windows: ポート 1883 使用状況確認
Get-NetTCPConnection -LocalPort 1883 -ErrorAction SilentlyContinue

# 競合している場合、docker-compose.yml でポート変更
# ports:
#   - "9883:1883"  ← ホスト側を 9883 に変更
```

**ステップ 3: ディスク空容量確認**
```powershell
# Windows
Get-Volume

# Linux/Mac
df -h
```

---

## 問題 2: "Connection refused" (MQTT 接続エラー)

### 症状
```
[ERROR] ✗ Connection refused (port 1883)
```

### 原因

1. **Mosquitto (MQTT ブローカー) が起動していない**
2. **コンテナ間のネットワーク設定エラー**
3. **Mosquitto.conf に問題**

### 解決方法

**ステップ 1: MQTT コンテナログ確認**
```bash
docker-compose logs mqtt
```

**ステップ 2: MQTT コンテナ再起動**
```bash
docker-compose restart mqtt
sleep 5
docker-compose logs mqtt
```

**ステップ 3: ネットワーク確認**
```bash
# コンテナ IP アドレス確認
docker network inspect smart-home-iot-hub_smart-home-network

# MQTT コンテナ内から接続テスト
docker exec -it smart-home-mqtt sh
mosquitto_pub -h 127.0.0.1 -t test -m "hello"
exit
```

**ステップ 4: 全コンテナ再起動**
```bash
docker-compose down
docker-compose up -d
```

---

## 問題 3: API が 404 エラーを返す

### 症状
```
curl http://localhost:5000/api/devices
# curl: (7) Failed to connect to localhost port 5000
```

### 原因

1. **Express サーバーが起動していない**
2. **npm install に失敗**
3. **ポート 5000 が他プロセスで使用中**

### 解決方法

**ステップ 1: API コンテナログ確認**
```bash
docker-compose logs api
```

**ステップ 2: npm install エラー確認**
```bash
# ビルドプロセスで npm エラーが出ている場合
docker-compose down
docker image rm smart-home-iot-hub-api  # イメージ削除
docker-compose build --no-cache api     # 再ビルド
docker-compose up -d
```

**ステップ 3: ポート 5000 の状態確認**
```bash
# Windows
Get-NetTCPConnection -LocalPort 5000 -ErrorAction SilentlyContinue

# 別のプロセスが使用中の場合、ポート変更:
# docker-compose.yml の修正:
# api:
#   ports:
#     - "8000:5000"  ← ホスト側を 8000 に変更
```

**ステップ 4: ヘルスチェック実行**
```bash
curl http://localhost:5000/health
# 期待される応答: {"status":"healthy",...}
```

---

## 問題 4: ダッシュボードが読み込まれない（真っ白）

### 症状
```
http://localhost:3000 にアクセス → 真っ白な画面
コンソール: TypeError: Failed to fetch
```

### 原因

1. **React/Vite が起動していない**
2. **API URL が正しく設定されていない**
3. **ブラウザキャッシュ問題**

### 解決方法

**ステップ 1: Frontend ログ確認**
```bash
docker-compose logs frontend
```

**ステップ 2: Vite 開発サーバー再起動**
```bash
docker-compose restart frontend
sleep 3
```

**ステップ 3: ブラウザキャッシュクリア**
- **Chrome**: Ctrl+Shift+Delete → キャッシュ削除
- **Firefox**: Ctrl+Shift+Delete → キャッシュクリア
- **Safari**: Cmd+Option+E → キャッシュクリア

**ステップ 4: 別ブラウザでテスト**
```
Firefox, Chrome, Safari で試す
→特定ブラウザのキャッシュ問題の可能性
```

**ステップ 5: ネットワーク確認**
```bash
# ブラウザ開発者ツール (F12) → Network タブ
# http://localhost:3000/api/devices へのリクエスト確認
# 404 の場合 → API が起動していない
# 接続エラー → API アドレスが正しくない
```

---

## 問題 5: データベース接続エラー

### 症状
```
[DB] Connection error: SQLITE_CANTOPEN
```

### 原因

1. **data ディレクトリが存在しない / 権限がない**
2. **DB_PATH が正しく設定されていない**
3. **SQLite ファイルが破損**

### 解決方法

**ステップ 1: DB_PATH 確認**
```bash
# .env で確認
grep DB_PATH .env
# 出力: DB_PATH=/app/data/smart_home.db
```

**ステップ 2: Docker 内部ディレクトリ確認**
```bash
docker exec -it smart-home-api ls -la /app/data/
```

**ステップ 3: DB ファイルが破損している場合**
```bash
# データを削除して再初期化
docker-compose down -v
docker-compose up -d
```

**ステップ 4: ボリュームパーミッション確認**
```bash
docker exec -it smart-home-api chmod 755 /app/data
```

---

## 問題 6: Python シミュレーターがデータを送信していない

### 症状
```
ダッシュボードにデータが表示されない
simulator ログ: Published to home/sensors/... (正常に見えるが実際にはデータなし)
```

### 原因

1. **MQTT ブローカーと通信できていない**
2. **トピックスペルミス**
3. **シミュレーターが停止している**

### 解決方法

**ステップ 1: Simulator ログ確認**
```bash
docker-compose logs simulator
```

**ステップ 2: MQTT pub/sub テスト**
```bash
# ターミナル A: Subscribe
docker exec -it smart-home-mqtt mosquitto_sub -t home/sensors/#

# ターミナル B: Publish テスト
docker exec -it smart-home-mqtt mosquitto_pub -t home/sensors/test -m "test"
# ターミナル A に "test" が表示されれば MQTT は正常
```

**ステップ 3: Simulator 再起動**
```bash
docker-compose restart simulator
sleep 5
docker-compose logs simulator
```

**ステップ 4: MQTT トピック確認**
```bash
# simulator/config.py でトピック確認
cat simulator/config.py | grep TOPIC
```

---

## 問題 7: "Cannot find module" エラー

### 症状
```
Error: Cannot find module 'express'
or
ModuleNotFoundError: No module named 'paho'
```

### 原因

1. **npm install / pip install が完全に実行されていない**
2. **package.json / requirements.txt に問題**
3. **Docker キャッシュの古い情報**

### 解決方法

**ステップ 1: キャッシュクリア＆再ビルド**
```bash
docker-compose down
docker image prune -a  # 全イメージ削除
docker-compose build --no-cache
docker-compose up -d
```

**ステップ 2: package.json 確認 (Node.js)**
```bash
cat backend/package.json | grep dependencies
```

**ステップ 3: requirements.txt 確認 (Python)**
```bash
cat requirements.txt
```

---

## 問題 8: メモリ / CPU 過多使用

### 症状
```
docker stats で CPU/メモリが 80% 以上
マシンがハング状態に
```

### 原因

1. **無限ループ / メモリリーク**
2. **ログが巨大化**
3. **Docker リソース制限がない**

### 解決方法

**ステップ 1: リソース監視**
```bash
docker stats --no-stream
```

**ステップ 2: 各コンテナの CPU/メモリ制限設定**
```yaml
# docker-compose.yml に追記:
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          memory: 256M
```

**ステップ 3: ログサイズ制限**
```yaml
services:
  api:
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "3"
```

**ステップ 4: 不要なコンテナ停止**
```bash
docker-compose down  # 全停止
docker system prune  # クリーンアップ
```

---

## 問題 9: Windows WSL2 関連エラー

### 症状
```
"Device or resource busy" 
or
"Error creating mount point"
```

### 原因

1. **WSL 2 が起動していない**
2. **Hyper-V が無効**
3. **ファイルシステムの互換性問題**

### 解決方法

**ステップ 1: WSL 2 バージョン確認**
```powershell
wsl --list --verbose
# NAME      STATE           VERSION
# Ubuntu    Running         2  ← バージョン 2 確認
```

**ステップ 2: WSL 2 にアップグレード**
```powershell
wsl --set-default-version 2
```

**ステップ 3: Hyper-V 確認**
```powershell
Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
# State : Enabled ← 確認
```

**ステップ 4: Docker Desktop 設定**
- Settings → General：WSL 2 ベース エンジン を確認 (Enabled)
- Settings → Resources：Ubuntu-XX を選択&チェック

---

## 問題 10: Git / コミット関連エラー

### 症状
```
fatal: not a git repository
or
Permission denied (publickey)
```

### 原因

1. **Git リポジトリ内にいない**
2. **SSH キー設定なし**
3. **ブランチが混在**

### 解決方法

**ステップ 1: Git ステータス確認**
```bash
git status
# On branch feature/013_smart_home_iot_hub ← 正常な状態
```

**ステップ 2: ブランチ確認**
```bash
git branch
# * feature/013_smart_home_iot_hub ← で始まる行が現在のブランチ
```

**ステップ 3: リモート接続確認**
```bash
git remote -v
# origin  https://github.com/hirotoitpost/VibeCoding.git (fetch)
```

---

## クイックデバッグ チェックリスト

デバッグ時に確認すべき項目：

- [ ] Docker Desktop が起動している
- [ ] `docker-compose ps` でコンテナ状態確認
- [ ] `docker-compose logs` で各コンテナログ確認
- [ ] `curl http://localhost:5000/health` で API 確認  
- [ ] ブラウザ開発者ツール (F12) で Network タブ確認
- [ ] ファイアウォール / ウイルス対策ソフトがポート阻止していないか確認
- [ ] ディスク容量十分か確認 (`df -h` or `Get-Volume`)

---

## さらなるサポート

問題が解決しない場合:

1. **GitHub Issues**: [VibeCoding Issues](https://github.com/hirotoitpost/VibeCoding/issues)
2. **ログ全文コピー**:
   ```bash
   docker-compose logs > debug.log 2>&1
   ```
   このログファイルを Issue に添付

3. **環境情報**:
   ```bash
   docker version
   docker-compose version
   git --version
   ```

---

**最終更新**: 2026年4月  
**バージョン**: 1.0
