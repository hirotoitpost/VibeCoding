/**
 * SQLite Database Initialization
 * 
 * テーブル作成とスキーマ定義
 */

const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = process.env.DB_PATH || path.join(__dirname, 'database.db');

/**
 * データベースコネクション取得
 */
const getDatabase = () => {
  return new Promise((resolve, reject) => {
    const db = new sqlite3.Database(DB_PATH, (err) => {
      if (err) {
        console.error('❌ Database connection failed:', err);
        reject(err);
      } else {
        resolve(db);
      }
    });
  });
};

/**
 * 初期化処理
 */
const initializeDatabase = async () => {
  try {
    const db = await getDatabase();

    // テーブル作成（既に存在する場合はスキップ）
    await new Promise((resolve, reject) => {
      db.serialize(() => {
        db.run(`
          CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            description TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        `, (err) => {
          if (err) {
            console.error('❌ Create table failed:', err);
            reject(err);
          } else {
            console.log('✅ transactions table ready');
            resolve();
          }
        });

        // インデックス作成（検索最適化）
        db.run(`
          CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date)
        `, (err) => {
          if (err) console.warn('⚠️  Index creation warning:', err);
        });

        db.run(`
          CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category)
        `, (err) => {
          if (err) console.warn('⚠️  Index creation warning:', err);
        });
      });
    });

    // 正常にクローズ
    db.close();
    console.log('✅ Database initialization complete');

  } catch (error) {
    console.error('❌ Database initialization failed:', error);
    throw error;
  }
};

/**
 * 実行用ヘルパー関数
 */
const runAsync = (db, sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.run(sql, params, (err) => {
      if (err) reject(err);
      else resolve();
    });
  });
};

/**
 * 取得用ヘルパー関数
 */
const getAsync = (db, sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => {
      if (err) reject(err);
      else resolve(row);
    });
  });
};

/**
 * 一覧取得用ヘルパー関数
 */
const allAsync = (db, sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows);
    });
  });
};

module.exports = {
  initializeDatabase,
  getDatabase,
  runAsync,
  getAsync,
  allAsync,
  DB_PATH
};
