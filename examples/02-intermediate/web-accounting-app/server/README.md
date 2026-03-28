# Web 家計簿アプリ - バックエンド構築ガイド

## 概要

Express + SQLite で構築された REST API サーバー。  
フロントエンドの要求に応じて、収支データの CRUD 操作と集計を提供します。

---

## 📋 実装予定

### サーバー基本構成 ✅ 完了

- [x] Express server.js
- [x] SQLite db.js
- [x] CORS 設定
- [x] ヘルスチェック `/health`

### ステップ 1: トランザクション CRUD ⏳

実装予定:
```
routes/transactions.js

POST   /api/transactions         # 取引作成
GET    /api/transactions         # 取引一覧（フィルタ対応）
GET    /api/transactions/:id     # 取引詳細
PUT    /api/transactions/:id     # 取引更新
DELETE /api/transactions/:id     # 取引削除
```

バリデーション:
- 日付：YYYY-MM-DD 形式
- 金額：数値（正負両対応）
- カテゴリ：事前定義リスト
- 説明：最大 500 文字

### ステップ 2: 集計 API ⏳

実装予定:
```
routes/summary.js

GET    /api/summary/monthly      # 月別集計
GET    /api/summary/category     # カテゴリ別集計
GET    /api/summary/daily        # 日別推移
```

### ステップ 3: テスト作成 ⏳

- Jest テストフレームワーク
- Supertest で API テスト
- サンプルデータ fixture

---

## 🚀 クイックスタート

### インストール

```bash
npm install
```

依存関係:
- `express`: Web フレームワーク
- `sqlite3`: SQLite ドライバ
- `cors`: CORS ミドルウェア
- `body-parser`: リクエスト パーサー
- `dotenv`: 環境変数

### 開発モード実行

```bash
npm run dev
```

出力:
```
🚀 Server running on http://localhost:5000
✅ SQLite database initialized
📊 Health check: http://localhost:5000/health
```

### テスト実行

```bash
npm test
```

---

## 🗄️ データベーススキーマ

### transactions テーブル

```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,              -- 'YYYY-MM-DD'
  category TEXT NOT NULL,          -- '食費', '交通費', '給与'等
  amount REAL NOT NULL,            -- 金額（正=収入、負=支出）
  description TEXT,                -- 摘要・説明（最大500文字）
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**インデックス**:
- `idx_transactions_date`: 日付検索最適化
- `idx_transactions_category`: カテゴリフィルタ最適化

---

## 📝 API リスト（拡張予定）

### 取引作成

```bash
curl -X POST http://localhost:5000/api/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "date": "2026-03-29",
    "category": "食費",
    "amount": -1500,
    "description": "昼食"
  }'
```

レスポンス:
```json
{
  "id": 1,
  "date": "2026-03-29",
  "category": "食費",
  "amount": -1500,
  "description": "昼食",
  "created_at": "2026-03-29T10:00:00.000Z"
}
```

---

## ⚠️ よくある問題

### ❌ Error: Cannot find module 'express'

解決:
```bash
npm install
```

### ❌ SQLITE_CANTOPEN: unable to open database file

解決:
```bash
# database.db ファイルが空でないことを確認
ls -la database.db

# 問題がある場合は削除して再実行
rm database.db
npm run dev
```

### ❌ EADDRINUSE: Port 5000 already in use

解決:
```bash
# ポート 5000 使用中のプロセスを確認（Linux/Mac）
lsof -i :5000

# Windows の場合
netstat -ano | findstr :5000

# プロセスを終了
kill -9 <PID>

# または別ポートで実行
SERVER_PORT=5001 npm run dev
```

---

## 🎯 実装チェックリスト

- [ ] `npm install` 実行可能
- [ ] `npm run dev` で サーバー起動（ポート 5000）
- [ ] `GET /health` で ステータス確認
- [ ] `POST /api/transactions` でデータ作成可能
- [ ] `GET /api/transactions` でデータ取得可能
- [ ] `npm test` でテスト実行

---

## 📚 参考資料

- [Express.js](https://expressjs.com)
- [SQLite3 Node.js](https://github.com/mapbox/node-sqlite3)
- [CORS Express](https://github.com/expressjs/cors)

---

**最終更新**: 2026年3月29日  
**ステータス**: 🚀 開発中
