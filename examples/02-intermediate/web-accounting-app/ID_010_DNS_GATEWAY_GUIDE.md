# ID 010: Docker DNS + API Gateway 統合 - テスト・検証ガイド

## 📋 実装概要

Web 家計簿アプリケーション（Phase 3.2.A）に DNS + API Gateway インフラを統合しました。

**目的**: 本番環境に近い Docker ネットワーク設計を学習し、複数サービス間の通信を最適化

### 新規コンポーネント

| サービス | ロール | ポート | イメージ |
|---------|--------|--------|---------|
| **dnsmasq** | ローカル DNS | 53 (UDP) | jpillora/dnsmasq:latest |
| **gateway** | API Gateway | 80 (TCP) | nginx:alpine |
| **server** | バックエンド | (内部のみ) | node:18-alpine |
| **client** | フロントエンド | (内部のみ) | node:18-alpine |

---

## 🚀 アーキテクチャ

### 以前（Pattern B - ローカル開発）
```
ホストマシン
  └→ Browser (localhost:5173)
      └→ API (localhost:5000)
```

### 新規構成（ID 010 - DNS + Gateway）
```
ホストマシン
  └→ Browser (localhost:80 または web-accounting-app.local)
      └→ Nginx Gateway
          ├→ /api/* → Backend Server (5000)
          └→ /* → Client (5173)
```

### Docker ネットワーク内通信
```
Client コンテナ
  └→ http://web-accounting-app.local/api
      └→ Nginx Gateway
          └→ Backend Server (server:5000)
```

---

## ✅ 検証結果

### 1. コンテナ起動確認
```powershell
✅ web-accounting-server    Healthy
✅ web-accounting-dns       Up
✅ web-accounting-gateway   Up  
✅ web-accounting-client    Up
```

### 2. ヘルスチェック
```bash
$ curl http://localhost:80/health
→ "healthy" ✅
```

### 3. API ゲートウェイ ルーティング
```bash
$ curl http://localhost:80/api/transactions
→ {"success":true,"count":11,"data":[...]} ✅
```

### 4. クライアント環境変数
```bash
$ docker-compose exec client env | grep API
→ VITE_API_URL=http://web-accounting-app.local/api ✅
```

---

## 📋 アクセス方法

### パターン A: localhost ポート指定（開発用）
```
ブラウザ: http://localhost/
API:      http://localhost/api/*
```

### パターン B: ドメイン名（本番風・推奨される）
```
ブラウザ: http://web-accounting-app.local/
API:      http://web-accounting-app.local/api/*

※ ホストマシンの hosts ファイルに以下を追加:
  127.0.0.1 web-accounting-app.local
```

### パターン C: 直接ポート指定（開発・デバッグ）
```
サーバー直接: http://localhost:5000/api/*
クライアント直接: http://localhost:5173/
```

---

## 🔧 技術的詳細

### Nginx 設定 (`nginx/nginx.conf`)
- **ヘルスチェック**: `/health` エンドポイント
- **API ルーティング**: `/api/*` → backend_server (5000)
- **フロントエンド**: `/` → frontend_dev (5173)
- **Vite HMR対応**: WebSocket ホットリロード対応

### DNS 設定 (`nginx/dnsmasq.conf`)
- `*.local` ドメインを `127.0.0.1` に解決
- コンテナ間で `web-accounting-app.local` name resolution

### Docker Compose 構成
- **depends_on**: Server の healthcheck 待機
- **restart**: `unless-stopped` ポリシー
- **networks**: `accounting-network` (bridge)

---

## 📊 比較表 - 環境設定

| 項目 | Pattern A (ID 009) | Pattern B (ID 010) |
|------|-------------------|-------------------|
| **API URL** | localhost:5000 | web-accounting-app.local/api |
| **Gateway** | ❌ なし | ✅ Nginx |
| **DNS** | ❌ なし | ✅ dnsmasq |
| **ポート公開** | server:5000, client:5173 | gateway:80 のみ |
| **本番準備度** | ⭐⭐ 中 | ⭐⭐⭐⭐ 高 |
| **学習価値** | Dockerの基本 | ネットワーク設計 |

---

## 🔍 トラブルシューティング

### ブラウザで web-accounting-app.local にアクセスできない
**原因**: ホストマシンの DNS が dnsmasq を参照していない

**解決策**:
1. **Option A**: hosts ファイルに手動追加
   ```
   C:\Windows\System32\drivers\etc\hosts に以下を追加:
   127.0.0.1 web-accounting-app.local
   ```

2. **Option B**: localhost でアクセス
   ```
   http://localhost/ でブラウザ起動
   ```

### API が通信できない
**確認項目**:
```bash
# ゲートウェイログ
docker-compose logs gateway

# クライアント環境変数
docker-compose exec client env | grep API

# API 直接テスト
curl http://localhost:80/api/transactions
```

### コンテナが起動しない
```bash
# 詳細ログを確認
docker-compose logs [service-name]

# 強制クリーンアップと再起動
docker-compose down --volumes
docker-compose up -d
```

### Vite ブラウザ自動開き エラー（xdg-open）
**エラー例**:
```
error: cannot open display
error: no protocol specified
```

**原因**: Vite が Docker コンテナ内でブラウザを起動しようとするが、表示環境がない

**解決方法**: `vite.config.js` で自動ブラウザ開き機能を無効化
```javascript
export default defineConfig({
  plugins: [react()],
  server: {
    open: false,  // ← これを追加
    host: '0.0.0.0',  // クライアントから接続可能に
  },
})
```

**参照**: [web-accounting-app/client/vite.config.js](client/vite.config.js#L15)

---

### API 接続問題（クライアント環境変数）
**エラー例**:
```
GET http://server:5000/api/... net::ERR_NAME_NOT_RESOLVED
```

**原因**: ブラウザ（クライアント側）が Docker internal hostname `server:5000` を解決できない

**解決方法**: 環境に応じて `VITE_API_URL` を設定

| 環境 | VITE_API_URL | 説明 |
|-----|-------------|------|
| **Docker Compose（Pattern B - Gateway）** | `http://web-accounting-app.local/api` | Nginx Gateway + dnsmasq 経由 |
| **Docker Compose（Pattern A - 直接）** | `http://localhost:5000` | ブラウザホスト上の localhost |
| **localhost（開発時）** | `http://localhost:5000` | Node.js 開発サーバー直接接続 |

**実装例**:
```yaml
# docker-compose.yml
services:
  client:
    environment:
      - VITE_API_URL=http://web-accounting-app.local/api  # ← パターンBの場合

# または Pattern A の場合:
      - VITE_API_URL=http://localhost:5000  # ← ホストからの直接接続
```

**参照**: [docker-compose.yml#L63](docker-compose.yml#L63)

---

## 📖 本番環境への応用

### 実装例
```yaml
# 本番環境: Let's Encrypt SSL + 実ドメイン
server {
    listen 443 ssl http2;
    server_name web-accounting-app.example.com;
    
    ssl_certificate /etc/letsencrypt/live/web-accounting-app.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/web-accounting-app.example.com/privkey.pem;
    
    location /api/ {
        proxy_pass http://backend_server;
        proxy_set_header X-Forwarded-Proto https;
    }
}
```

### Azure App Service への展開
```bicep
# Nginx をコンテナとして Azure Container Instances で実行
# Traffic Manager で複数リージョンをロードバランシング
```

---

## ✨ 学習ポイント

✅ **Docker ネットワーク**: bridge ネットワーク、service name による container-to-container通信  
✅ **Nginx**: リバースプロキシ、ルーティング、ヘルスチェック  
✅ **DNS**: dnsmasq による *.local ドメイン解決  
✅ **本番キーテクノロジー**: API Gateway, マイクロサービス通信  
✅ **Vite HMR**: WebSocket ホットリロード対応設定  

---

## 📝 コミット情報

**ID**: 010  
**タイトル**: Web 家計簿 - DNS + API Gateway 統合  
**実装内容**:
- Nginx API Gateway 構成 (nginx/nginx.conf)
- dnsmasq DNS サービス (nginx/dnsmasq.conf)
- Docker Compose 更新 (追加: gateway, dnsmasq)
- Client VITE_API_URL 更新

**検証済み項目**:
- ✅ 4 コンテナ全起動
- ✅ API Gateway ヘルスチェック
- ✅ API ルーティング動作
- ✅ すべてのデータベースレコード取得可能

---

**Next**: Phase 3.3 - テスト戦略・統合テストの拡張
