# シンプルな Web 家計簿アプリ

## ID 008: Phase 3.2.A 中級プロジェクト

---

## 📋 プロジェクト概要

収支を記録・管理する Web アプリケーション。**フロントエンド + バックエンド + データベース** の統合体験を通じて、複数サービス間の連携と API 設計を学びます。

### 目的

**Vibe Coding の高度な実践**:
- 複数プロジェクト（フロントエンド・バックエンド）の統合管理
- API 設計と実装の経験
- データベーススキーマ設計の基礎
- エラーハンドリング・バリデーションの実装方法
- Docker/docker-compose による環境構築の自動化

---

## 🛠️ 技術スタック

| レイヤー | 技術 | 用途 |
|---------|------|------|
| **フロントエンド** | React 18, React Router, Axios | UI・API クライアント |
| **バックエンド** | Node.js, Express 4 | REST API サーバー |
| **データベース** | SQLite 3 | ローカルデータ永続化 |
| **コンテナ** | Docker, docker-compose | 環境の自動化 |
| **ビルドツール** | npm, Vite（フロントエンド） | 依存関係管理・ビルド |

---

## 📂 プロジェクト構造

```
web-accounting-app/
│
├── server/                        # バックエンド (Node.js + Express)
│   ├── package.json
│   ├── server.js                  # Express メインサーバー
│   ├── db.js                      # SQLite データベース初期化
│   ├── routes/
│   │   ├── transactions.js        # 収支取引 API
│   │   └── summary.js             # 集計・サマリー API
│   ├── middleware/
│   │   ├── errorHandler.js        # エラーハンドリング
│   │   └── validation.js          # バリデーション
│   ├── models/
│   │   └── Transaction.js         # トランザクションモデル
│   ├── database.db                # SQLite DB ファイル（自動生成）
│   └── README.md                  # バックエンド構築ガイド
│
├── client/                        # フロントエンド (React)
│   ├── package.json
│   ├── vite.config.js             # Vite 設定
│   ├── src/
│   │   ├── main.jsx               # アプリケーションエントリ
│   │   ├── App.jsx                # ルートコンポーネント
│   │   ├── pages/
│   │   │   ├── Dashboard.jsx      # ダッシュボード（集計・グラフ）
│   │   │   └── TransactionForm.jsx # 取引入力フォーム
│   │   ├── components/
│   │   │   ├── TransactionTable.jsx
│   │   │   ├── MonthlyChart.jsx   # Chart.js グラフ
│   │   │   └── CategoryChart.jsx
│   │   ├── services/
│   │   │   └── api.js             # Axios API クライアント
│   │   └── styles/
│   │       └── App.css
│   ├── index.html
│   └── README.md                  # フロントエンド構築ガイド
│
├── docker-compose.yml             # 全サービス起動設定
├── Dockerfile                     # コンテナイメージ定義（両用）
├── .env.example                   # 環境変数テンプレート
└── README.md                      # このファイル
```

---

## 🚀 クイックスタート

### 前提条件

- Node.js 18+ 
- npm 9+
- Docker & docker-compose（オプションだが推奨）
- git

### パターン 1: ローカル実行（推奨・学習用）

#### 1. リポジトリクローン（既済）

```bash
cd examples/02-intermediate/web-accounting-app
```

#### 2. .env ファイル作成

```bash
cp .env.example .env
```

内容:
```
REACT_APP_API_URL=http://localhost:5000
SERVER_PORT=5000
NODE_ENV=development
```

#### 3. バックエンド起動

```bash
cd server
npm install
npm start
```

出力例:
```
Server running on http://localhost:5000
SQLite database initialized
```

#### 4. フロントエンド起動（別ターミナル）

```bash
cd client
npm install
npm run dev
```

出力例:
```
VITE v4.1.0 ready in 1234 ms
➜  Local:   http://localhost:5173/
```

#### 5. ブラウザで確認

- http://localhost:5173 を開く
- 家計簿アプリが表示される

---

### パターン 2: Docker Compose（本番風・推奨）

```bash
# 全サービス起動（バックエンド + フロント + ホットリロード対応）
docker-compose up -d

# ブラウザで確認
# http://localhost:5173
```

**メリット**:
- 環境差分なし
- ワンコマンド起動
- 本番環境に近い設定

---

## ✨ 主な機能

### フロントエンド

- ✅ **ダッシュボード**
  - 月別収支集計
  - カテゴリ別集計（円グラフ）
  - 日別推移グラフ

- ✅ **取引入力**
  - 日付、カテゴリ、金額、説明の入力
  - リアルタイム バリデーション
  - 即座に DB に保存

- ✅ **取引管理**
  - テーブル表示
  - フィルタリング（月・カテゴリ）
  - 編集・削除機能

### バックエンド

- ✅ **REST API エンドポイント**
  ```
  POST   /api/transactions         # 取引作成
  GET    /api/transactions         # 取引一覧
  GET    /api/transactions/:id     # 取引詳細
  PUT    /api/transactions/:id     # 取引更新
  DELETE /api/transactions/:id     # 取引削除
  
  GET    /api/summary/monthly      # 月別集計
  GET    /api/summary/category     # カテゴリ別集計
  GET    /api/summary/daily        # 日別推移
  ```

- ✅ **バリデーション**
  - 金額：正の数値のみ
  - 日付：有効な日付形式
  - カテゴリ：事前定義リストから選択

- ✅ **エラーハンドリング**
  - 400: 不正なリクエスト
  - 404: リソース未見つかり
  - 500: サーバーエラー

---

## 📚 実装ガイド

### ステップ 1: バックエンド実装（Node.js + Express）

1. `server/package.json` 作成
   - 依存関係：express, sqlite3, cors, body-parser
   
2. `server/server.js` 作成
   - Express サーバー基本設定
   - CORS 有効化
   - ルート登録

3. `server/db.js` 作成
   - SQLite データベース初期化
   - テーブル作成スクリプト

4. `server/routes/transactions.js` 作成
   - CRUD エンドポイント実装

5. `server/routes/summary.js` 作成
   - 集計クエリ実装

### ステップ 2: フロントエンド実装（React + Vite）

1. `client/package.json` 作成
   - 依存関係：react, react-router-dom, axios, chart.js

2. `client/src/App.jsx` 作成
   - ルート定義
   - ページレイアウト

3. `client/src/pages/Dashboard.jsx` 作成
   - 集計データ表示
   - グラフ描画

4. `client/src/pages/TransactionForm.jsx` 作成
   - 取引入力フォーム
   - API 通信

5. `client/src/services/api.js` 作成
   - Axios インスタンス
   - API ラッパー関数

### ステップ 3: データベース設計

**transactions テーブル**:
```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,               -- YYYY-MM-DD 形式
  category TEXT NOT NULL,           -- '食費', '交通費', '給与' など
  amount REAL NOT NULL,             -- 金額（正=収入、負=支出）
  description TEXT,                 -- 説明
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔍 Vibe Coding での指示設計パターン

### パターン: 複数サービス統合

```markdown
# バックエンド実装（Express + SQLite）
技術要件：
- Express アプリケーション（ポート 5000）
- SQLite ローカルデータベース
- REST API 5 エンドポイント
- バリデーション & エラーハンドリング

実装スコープ：
1. server/package.json：express, sqlite3, cors, body-parser
2. server/server.js：Express 初期化 + ルート登録
3. server/db.js：DB 初期化スクリプト
4. server/routes/transactions.js：CRUD 実装
5. server/routes/summary.js：集計実装

制約：
- SQLite = ローカルファイル（database.db）
- CORS は フロントエンド（localhost:5173）のみ許可
- エラーレスポンスは JSON 形式：{error: "メッセージ"}
```

### パターン: API 設計の検討

**質問**:
- どの操作が単一トランザクションで完了するか
- 並行実行時の問題（競合）への対応
- キャッシュの必要性（月別集計は頻繁に変更？）

---

## ⚠️ よくある問題とトラブルシューティング

| 問題 | 症状 | 原因 | 解決策 |
|------|------|------|------|
| **ポート競合** | EADDRINUSE: address already in use | 別プロセスが 5000/5173 ポート使用中 | `lsof -i :5000` でプロセス確認・終了 |
| **CORS エラー** | Cross-Origin Request Blocked | バックエンド CORS 設定未設定 | `express.json()` + CORS ミドルウェア確認 |
| **DB ロック** | SQLITE_BUSY: database is locked | 複数プロセスが同時アクセス | SQLite → PostgreSQL に移行 or WAL モード有効化 |
| **npm install 失敗** | ERR! code E404 | パッケージ名誤り or キャッシュ問題 | `npm cache clean --force` + 再度インストール |

詳細は [TROUBLESHOOTING.md](TROUBLESHOOTING.md) を参照。

---

## 🎯 学習チェックポイント

完了したら以下を確認してください:

- [ ] バックエンド起動 → ブラウザで `/api/transactions` にアクセス可能
- [ ] フロントエンド起動 → ダッシュボード表示
- [ ] 取引追加 → データがテーブルに表示される
- [ ] グラフ動的更新 → 新規取引後、集計が自動更新
- [ ] エラーハンドリング → 不正入力で適切にエラー表示
- [ ] Docker 起動 → `docker-compose up` ワンコマンドで全起動

---

## 📖 参考資料

### 公式ドキュメント
- [Express.js](https://expressjs.com)
- [React](https://react.dev)
- [SQLite](https://www.sqlite.org)
- [Chart.js](https://www.chartjs.org)

### Vibe Coding パターン
テクニックは [docs/vibe_coding_instruction_design.md](../../../../docs/vibe_coding_instruction_design.md) を参照。

### Phase 3.1 の経験活用
天気情報ツール（[examples/01-basic/weather-tool/](../01-basic/weather-tool/)）の以下の知見を活かしてください:
- エラーハンドリングパターン
- 環境変数の使用方法
- テスト戦略

---

## 📝 次のステップ

1. ✅ バックエンド実装（Express CRUD API）
2. ✅ フロントエンド実装（React ダッシュボード）
3. ✅ テスト作成（バックエンド・フロントエンド統合テスト）
4. ✅ Docker 化（docker-compose.yml）
5. ⏳ PR 投稿・マージ
6. ⏭️ ID 008.B（IoT センサーシミュレーター）へ進行

---

## 🏆 成功基準

このプロジェクトが完了したら以下を達成しています:

✅ **複数サービス統合**: フロント・バック・DB が連携  
✅ **API 設計**: RESTful な CRUD エンドポイント設計経験  
✅ **エラーハンドリング**: フロントで適切にエラー処理表示  
✅ **自動化デプロイ**: Docker ワンコマンド起動  
✅ **Vibe Coding 習熟**: AI との協働で大規模プロジェクト完成

---

**最終更新**: 2026年3月29日  
**プロジェクトID**: ID 008.2A  
**ステータス**: 🚀 開発開始
