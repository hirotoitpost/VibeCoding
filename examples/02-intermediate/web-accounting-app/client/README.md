# Web 家計簿アプリ - フロントエンド構築ガイド

## 概要

React + Vite で構築された 家計簿アプリの UI。  
バックエンド REST API と連携して、収支データの表示・入力・集計を行います。

---

## 📋 実装予定

### フロントエンド基本構成 ✅ 完了

- [x] React + Vite プロジェクト
- [x] React Router（ナビゲーション基盤）
- [x] Axios（API クライアント）
- [x] Chart.js 統合準備
- [x] 基本スタイル（レスポンシブ対応）

### ステップ 1: ダッシュボード ⏳

実装予定:
```
pages/Dashboard.jsx

- 月別収支集計表示
- カテゴリ別集計（円グラフ）
- 日別推移グラフ
- 最近の取引表示
```

コンポーネント:
- `MonthlyChart.jsx`: 円グラフ
- `DailyChart.jsx`: 折れ線グラフ
- `SummaryCards.jsx`: 集計カード

### ステップ 2: 取引入力フォーム ⏳

実装予定:
```
pages/TransactionForm.jsx

- 日付入力（カレンダーピッカー）
- カテゴリ選択（ドロップダウン）
- 金額入力
- 説明テキスト
- 送信・キャンセルボタン
```

バリデーション:
- 必須項目チェック
- 日付形式チェック
- 金額の正負判定

### ステップ 3: 取引管理テーブル ⏳

実装予定:
```
components/TransactionTable.jsx

- 一覧表示
- フィルタリング（月・カテゴリ）
- 検索機能
- 編集・削除ボタン
- ページネーション
```

---

## 🚀 クイックスタート

### インストール

```bash
npm install
```

依存関係:
- `react`: UI フレームワーク
- `react-router-dom`: ナビゲーション
- `axios`: HTTP クライアント
- `chart.js` + `react-chartjs-2`: グラフ表示
- `vite`: ビルドツール

### 開発実行

```bash
npm run dev
```

ブラウザ自動オープン:
```
➜  Local:   http://localhost:5173/
```

### ビルド

```bash
npm run build
```

成果物: `dist/` フォルダ に静的ファイルが生成

### プレビュー

```bash
npm run preview
```

---

## 🏗️ コンポーネント構造

```
App.jsx (ルート)
├── Navbar
├── Routes
│   ├── Dashboard page
│   │   ├── SummaryCards
│   │   ├── MonthlyChart
│   │   ├── DailyChart
│   │   └── TransactionTable
│   └── TransactionForm page
└── Footer
```

---

## 🔗 バックエンド連携

### API ベース URL

環境変数 `VITE_API_URL` から取得:

```javascript
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000'
```

### API エンドポイント

```javascript
// 取引一覧
GET ${API_URL}/api/transactions

// 月別集計
GET ${API_URL}/api/summary/monthly

// カテゴリ別集計
GET ${API_URL}/api/summary/category
```

### Axios インスタンス

`services/api.js` でラップ予定:

```javascript
import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5000'
})

export default api
```

---

## ⚠️ よくある問題

### ❌ Error: Cannot find module 'react'

解決:
```bash
npm install
```

### ❌ Port 5173 already in use

解決:
```bash
# Linux/Mac: ポート 5173 を使用中のプロセス確認
lsof -i :5173

# Windows:
netstat -ano | findstr :5173

# 別ポート指定
npm run dev -- --port 5174
```

### ❌ CORS error: Access-Control-Allow-Origin missing

解決:
- バックエンド（server）起動確認: `http://localhost:5000/health`
- CORS 設定確認: `server/server.js` の CORS 設定
- 環境変数確認: `.env` ファイルの `REACT_APP_API_URL`

### ❌ Blank page / Components not rendering

解決:
```bash
# ブラウザキャッシュクリア
# DevTools > F12 > Application > Clear Storage

# または、ハード再読込
# Ctrl+Shift+R (Win/Linux)
# Cmd+Shift+R (Mac)
```

---

## 🎯 実装チェックリスト

- [ ] `npm install` 実行可能
- [ ] `npm run dev` で フロント起動（ポート 5173）
- [ ] ダッシュボード表示
- [ ] バックエンド（ポート 5000）から データ取得可能
- [ ] 取引フォーム表示
- [ ] グラフ表示
- [ ] エラー時にメッセージ表示

---

## 📚 参考資料

- [React 18](https://react.dev)
- [React Router v6](https://reactrouter.com)
- [Vite](https://vitejs.dev)
- [Axios](https://axios-http.com)
- [Chart.js](https://www.chartjs.org)

---

**最終更新**: 2026年3月29日  
**ステータス**: 🚀 開発中
