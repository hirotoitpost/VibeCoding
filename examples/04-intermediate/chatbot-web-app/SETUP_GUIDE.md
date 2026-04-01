# チャットボット Web App - セットアップガイド

> **最終更新**: 2026年3月29日  
> **ステータス**: ✅ 完成（Mock レスポンス実装）

---

## 📌 概要

Vibe Coding による学習用フルスタック Web アプリケーション。

- **フロントエンド**: React + Vite + Axios
- **バックエンド**: Flask + Flask-CORS
- **AI エンジン**: Google Generative AI (Gemini) — Mock フォールバック対応
- **デプロイ**: Docker Compose 対応

---

## 🚀 クイックスタート

### **1️⃣ 環境ファイル設定**

```powershell
cd examples\04-intermediate\chatbot-web-app\backend
copy .env.example .env
```

`.env` に **Google AI API キー** を設定（オプション）：
```bash
GOOGLE_API_KEY=your-api-key-here
```

> **注**: キーがなくても Mock レスポンスで動作します ✅

---

### **2️⃣ バックエンド起動**

```powershell
cd .\backend
python -m venv .venv
.\.venv\Scripts\Activate
pip install -r requirements.txt
python server.py
```

✅ **結果**: `http://localhost:5000/api/health` で確認

---

### **3️⃣ フロントエンド起動**（別ターミナル）

```powershell
cd .\frontend
npm install
npm run dev
```

✅ **結果**: `http://localhost:3000` でアクセス

---

## 🎮 使用方法

### **チャットしてみる**

以下のキーワードで **事前定義レスポンス** が返されます：

| キーワード | レスポンス例 |
|-----------|-----------|
| `hello` | 👋 Hello! I'm a chatbot... |
| `what is vibe coding` | 🎯 Vibe Coding is a learning project... |
| `how are you` | 😊 I'm doing great! |
| `tell me` | 📚 I'd be happy to help! |
| `joke` | 😄 Why do Java developers wear glasses?... |
| `help` | 📖 I can help you with... |
| `python` | 🐍 Python is an excellent programming language! |
| その他 | デフォルト応答（ユーザー質問をエコーバック） |

---

## 🔧 トラブルシューティング

### ❌ "Cannot connect to backend"
- **原因**: バックエンドが起動していない
- **解決**: `python server.py` を実行（port 5000）

### ❌ メッセージ送信後にハング
- **原因**: API URL が間違っている
- **解決**: `frontend/.env` で `VITE_API_URL=http://localhost:5000` を確認

### ❌ "404 endpoint not found"
- **原因**: Vite プロキシが設定されていない
- **解決**: `vite.config.js` に `/api` プロキシを設定

---

## 📊 プロジェクト構成

```
chatbot-web-app/
├── backend/
│   ├── .env                    # API キー（git 対象外）
│   ├── requirements.txt        # Python 依存関係
│   ├── server.py              # Flask エントリーポイント
│   └── src/
│       ├── config.py          # 設定管理
│       ├── chat_service.py    # Mock + Gemini API 統合
│       └── __init__.py
├── frontend/
│   ├── .env                    # Vite 環境変数
│   ├── package.json           # Node.js 依存関係
│   ├── vite.config.js         # Vite + プロキシ設定
│   ├── index.html
│   └── src/
│       ├── App.jsx            # React メインコンポーネント
│       ├── main.jsx
│       └── components/
│           └── ChatWindow.jsx # チャットUI
├── tests/
│   ├── test_chat_service.py
│   ├── test_server.py
│   └── test_chat_window.test.jsx
└── SETUP_GUIDE.md             # このファイル
```

---

## 🎓 学習ポイント

このプロジェクトから学べることは：

1. **フロントエンド**:
   - React の状態管理（useState）
   - API 統合（axios）
   - Component 設計

2. **バックエンド**:
   - Flask でのシンプルな REST API
   - CORS 対応
   - エラーハンドリング

3. **DevOps**:
   - 環境分離（開発 / 本番）
   - プロキシ設定
   - Docker 準備（docker-compose.yml）

4. **AI/ML**:
   - API 統合パターン
   - Mock レスポンスの活用
   - Fallback 戦略

---

## 🐳 Docker で起動（将来）

```bash
docker-compose up -d
```

---

## 📝 API リファレンス

### **`GET /api/health`**
```json
{
  "status": "ok",
  "message": "Server is running"
}
```

### **`POST /api/chat`**
**Request**:
```json
{
  "message": "Hello",
  "conversation_history": [
    {"role": "user", "content": "Hi"},
    {"role": "assistant", "content": "Hello!"}
  ]
}
```

**Response** (成功):
```json
{
  "message": "👋 Hello! I'm a chatbot...",
  "success": true
}
```

**Response** (エラー):
```json
{
  "error": "Invalid message",
  "success": false
}
```

---

## ✅ チェックリスト

セットアップ検証：

- [ ] Backend が `http://localhost:5000` で起動
- [ ] Frontend が `http://localhost:3000` で起動
- [ ] メッセージ送信でレスポンスが返される
- [ ] ブラウザコンソールにエラーがない
- [ ] `.env` に API キーが設定されている（オプション）

---

## 🎯 次のステップ

### 改善案：
1. **Gemini API 統合** - 実際の AI 応答
2. **チャット履歴保存** - ローカルストレージ or DB
3. **マークダウンレンダリング** - AI 応答の表示改善
4. **音声入力** - Speech-to-Text API
5. **テーマ切り替え** - Dark/Light モード

---

**Happy Coding! 🚀**

Author: Vibe Coding AI Agent  
Last Updated: 2026-03-29
