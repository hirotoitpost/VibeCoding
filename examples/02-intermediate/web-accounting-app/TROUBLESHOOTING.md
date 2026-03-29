# トラブルシューティングガイド

ID 008: Web 家計簿アプリ で発生する可能性のある問題と解決策

---

## 📋 目次

1. [環境セットアップの問題](#環境セットアップの問題)
2. [バックエンド関連](#バックエンド関連)
3. [フロントエンド関連](#フロントエンド関連)
4. [API 連携](#api-連携)
5. [Docker 関連](#docker-関連)

---

## 環境セットアップの問題

### ❌ npm install で エラー

**症状**:
```
npm ERR! code ERESOLVE
npm ERR! ERESOLVE unable to resolve dependency tree
```

**原因**: Node.js バージョンの不一致、パッケージキャッシュの問題

**解決**:
```bash
# Node.js バージョン確認（18+ 推奨）
node --version

# キャッシュクリア
npm cache clean --force

# 全ての node_modules 削除
rm -rf node_modules package-lock.json

# 再度インストール
npm install
```

---

### ❌ git clone 後、ディレクトリが空

**症状**:
```
examples/02-intermediate/web-accounting-app/
  (ファイルなし)
```

**原因**: submodule チェックアウト忘れ

**解決**:
```bash
git submodule update --init --recursive
```

---

## バックエンド関連

### ❌ SQLITE_CANTOPEN: unable to open database file

**症状**:
```
Error: SQLITE_CANTOPEN: unable to open database file database.db
```

**原因**: 
- database.db ファイルパーミッション問題
- ディレクトリに書き込み権限なし

**解決**:
```bash
# データベース削除（再作成される）
rm server/database.db

# サーバー再起動
npm run dev

# または、ディレクトリ権限確認
chmod 755 server/
```

---

### ❌ EADDRINUSE: Port 5000 already in use

**症状**:
```
Error: listen EADDRINUSE: address already in use :::5000
```

**原因**: ポート 5000 が別プロセスで使用中

**解決**:

**Linux/Mac:**
```bash
# 使用中のプロセス確認
lsof -i :5000

# プロセス強制終了（PID は上記結果から）
kill -9 <PID>

# または、別ポート指定
SERVER_PORT=5001 npm run dev
```

**Windows:**
```bash
# 使用中のプロセス確認
netstat -ano | findstr :5000

# プロセス強制終了
taskkill /PID <PID> /F

# または、別ポート指定
set SERVER_PORT=5001 && npm run dev
```

---

### ❌ Cannot find module 'express'

**症状**:
```
Error: Cannot find module 'express'
```

**原因**: npm install が実行されていない

**解決**:
```bash
cd server
npm install
npm start
```

---

### ❌ Database lock error

**症状**:
```
Error: SQLITE_BUSY: database is locked
```

**原因**: 複数プロセスが同時にデータベースアクセス

**解決**:
```bash
# サーバー再起動
npm run dev

# 問題が続く場合、WAL モード有効化（db.js）
PRAGMA journal_mode=WAL;
```

---

## フロントエンド関連

### ❌ Port 5173 already in use

**症状**:
```
error Port 5173 is in use by Vite dev server
```

**原因**: ポート 5173 が別プロセスで使用中

**解決**:
```bash
# Linux/Mac: プロセス確認
lsof -i :5173

# プロセス強制終了
kill -9 <PID>

# または、別ポート指定
npm run dev -- --port 5174
```

---

### ❌ Blank page / Nothing renders

**症状**:
- ブラウザで真っ白なページ
- コンソールにエラーなし

**原因**:
- キャッシュ問題
- React アプリケーションマウント失敗

**解決**:
```bash
# ハード再読込
# Ctrl+Shift+R (Windows/Linux)
# Cmd+Shift+R (Mac)

# ブラウザキャッシュクリア
# DevTools > F12 > Application > Clear Storage

# または、別ブラウザで確認
```

---

### ❌ Error: Cannot find module 'react'

**症状**:
```
Error: Cannot find module 'react'
```

**原因**: npm install が実行されていない

**解決**:
```bash
cd client
npm install
npm run dev
```

---

### ❌ React Router ナビゲーションが動作しない

**症状**:
```
TypeError: useNavigate is not a function
```

**原因**: ルーターの外でフック使用

**解決**:
```javascript
// ❌ 正しくない
function MyComponent() {
  const navigate = useNavigate() // Router 外だと失敗
}

// ✅ 正しい
function App() {
  return (
    <Router>
      <MyComponent /> {/* Router 内 */}
    </Router>
  )
}
```

---

## API 連携

### ❌ CORS error: Access-Control-Allow-Origin missing

**症状**:
```
Access to XMLHttpRequest at 'http://localhost:5000/api/...' 
from origin 'http://localhost:5173' has been blocked by CORS policy
```

**原因**:
- バックエンド CORS 設定なし
- API サーバーがダウン

**解決**:

1. **バックエンド CORS 設定確認**:
```javascript
// server/server.js
app.use(cors({
  origin: ['http://localhost:5173', 'http://localhost:3000'],
  credentials: true
}));
```

2. **バックエンド動作確認**:
```bash
curl http://localhost:5000/health
# 応答: {"status":"OK","timestamp":"..."}
```

3. **API URL 確認**:
```javascript
// client/src/App.jsx
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000'
console.log('API URL:', API_URL)
```

---

### ❌ 404: API endpoint not found

**症状**:
```
GET /api/transactions 404 Not Found
```

**原因**: API ルート未実装

**解決**:
- バックエンド実装状況確認
- `server/routes/transactions.js` が作成済みか確認

---

### ❌ API response が 500 エラー

**症状**:
```
500 Internal Server Error
```

**原因**:
- データベース接続エラー
- SQL クエリ構文エラー

**解決**:
```bash
# サーバーコンソール確認
npm run dev
# エラーメッセージを確認

# ブラウザ DevTools で ネットワークタブ確認
# Response にエラー内容が表示される
```

---

## Docker 関連

### ❌ docker-compose up で 起動失敗

**症状**:
```
Docker daemon is not running
```

**原因**: Docker デスクトップが起動していない

**解決**:

**Windows/Mac**: Docker Desktop アプリを起動

**Linux**:
```bash
sudo systemctl start docker
docker-compose up -d
```

---

### ❌ Container 起動はするが接続できない

**症状**:
```
curl: (7) Failed to connect to localhost port 5000
```

**原因**: コンテナネットワーク設定

**解決**:
```bash
# コンテナ確認
docker ps

# ログ確認
docker logs web-accounting-server

# コンテナ再起動
docker-compose down
docker-compose up -d
```

---

### ❌ node_modules サイズが大きく過ぎる

**症状**:
```
disk space: 1.2 GB ...
```

**原因**: Docker ボリューム キャッシュ蓄積

**解決**:
```bash
# ボリューム削除
docker volume prune

# または、コンテナ完全削除
docker-compose down -v
docker-compose up -d
```

---

## 🎯 デバッグのコツ

### 1. コンソール出力を確認

**サーバー**:
```bash
npm run dev
# 端末に出力されるログを確認
```

**クライアント**:
```javascript
console.log('Debug info:', data)
```

### 2. ネットワークデバッグ

ブラウザ DevTools:
```
F12 > Network タブ > API リクエスト確認
- Request Headers（CORS ヘッダ）
- Response Body（エラー内容）
```

### 3. Database 直接検査

```bash
sqlite3 server/database.db

# SQLite プロンプト
.tables    # テーブル一覧
.schema    # スキーマ表示
SELECT * FROM transactions;  # データ確認
```

---

## 📞 サポート

問題が解決しない場合：

1. [GitHub Issues](https://github.com/hirotoitpost/VibeCoding/issues)
2. ローカルで再現可能なテストケース作成
3. エラーログ・スクリーンショット添付

---

**最終更新**: 2026年3月29日
