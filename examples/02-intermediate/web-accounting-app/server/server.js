/**
 * Web 家計簿アプリ - Express サーバー
 * 
 * ポート: 5000（開発環境）
 * API エンドポイント: /api/
 */

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');
require('dotenv').config();

const { initializeDatabase } = require('./db');

const app = express();
const PORT = process.env.SERVER_PORT || 5000;

// ===========================
// ミドルウェア設定
// ===========================

// CORS: フロントエンド（localhost:5173）からのリクエストを許可
app.use(cors({
  origin: ['http://localhost:5173', 'http://localhost:3000'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type']
}));

// JSON パーサー
app.use(bodyParser.json());
app.use(express.json());

// ===========================
// ルート定義
// ===========================

// ヘルスチェック
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// API ルート（後続ステップで実装予定）
// app.use('/api/transactions', require('./routes/transactions'));
// app.use('/api/summary', require('./routes/summary'));

// ===========================
// エラーハンドリング
// ===========================

app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    status: err.status || 500
  });
});

// ===========================
// サーバー起動
// ===========================

const startServer = async () => {
  try {
    // データベース初期化
    await initializeDatabase();
    console.log('✅ SQLite database initialized');

    // サーバー起動
    app.listen(PORT, () => {
      console.log(`\n🚀 Server running on http://localhost:${PORT}`);
      console.log(`📊 Health check: http://localhost:${PORT}/health`);
      console.log(`\n💡 API endpoints (to be implemented):`);
      console.log(`   POST   /api/transactions`);
      console.log(`   GET    /api/transactions`);
      console.log(`   GET    /api/summary/monthly`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

// 未処理エラーをキャッチ
process.on('unhandledRejection', (reason, promise) => {
  console.error('🚨 Unhandled Rejection at:', promise, 'reason:', reason);
});

// サーバー起動
startServer();

module.exports = app;
