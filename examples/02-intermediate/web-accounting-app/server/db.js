/**
 * SQLite Database Initialization
 * 
 * テーブル作成とスキーマ定義
 * シングルトン db インスタンスを管理
 */

const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = process.env.DB_PATH || path.join(__dirname, 'database.db');
let dbInstance = null;

/**
 * データベースコネクション取得（シングルトン）
 */
const getDatabase = () => {
  return new Promise((resolve, reject) => {
    if (dbInstance) {
      resolve(dbInstance);
      return;
    }

    const db = new sqlite3.Database(DB_PATH, (err) => {
      if (err) {
        console.error('❌ Database connection failed:', err);
        reject(err);
      } else {
        dbInstance = db;
        resolve(dbInstance);
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

    console.log('✅ Database initialization complete');

  } catch (error) {
    console.error('❌ Database initialization failed:', error);
    throw error;
  }
};

/**
 * 実行用ヘルパー関数（シングルトン db を使用）
 */
const runAsync = async (sql, params = []) => {
  const db = await getDatabase();
  return new Promise((resolve, reject) => {
    db.run(sql, params, function(err) {
      if (err) reject(err);
      else resolve({ lastID: this.lastID, changes: this.changes });
    });
  });
};

/**
 * 取得用ヘルパー関数（シングルトン db を使用）
 */
const getAsync = async (sql, params = []) => {
  const db = await getDatabase();
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => {
      if (err) reject(err);
      else resolve(row);
    });
  });
};

/**
 * 一覧取得用ヘルパー関数（シングルトン db を使用）
 */
const allAsync = async (sql, params = []) => {
  const db = await getDatabase();
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows || []);
    });
  });
};

/**
 * サンプルデータ初期化
 * 既存データがない場合のみ挿入
 */
const seedDatabase = async () => {
  try {
    const count = await getAsync('SELECT COUNT(*) as count FROM transactions');
    if (count.count > 0) {
      console.log('ℹ️  Database already has data. Skipping seed.');
      return;
    }

    const sampleData = [
      { date: '2026-03-01', category: 'food', amount: 1200, description: 'Lunch' },
      { date: '2026-03-01', category: 'transport', amount: 500, description: 'Gas' },
      { date: '2026-03-02', category: 'entertainment', amount: 3000, description: 'Movie tickets' },
      { date: '2026-03-02', category: 'utilities', amount: 8000, description: 'Electricity bill' },
      { date: '2026-03-03', category: 'food', amount: 800, description: 'Breakfast' },
      { date: '2026-03-03', category: 'food', amount: 950, description: 'Dinner' },
      { date: '2026-03-04', category: 'transport', amount: 600, description: 'Parking' },
      { date: '2026-03-04', category: 'other', amount: 2500, description: 'Books' },
      { date: '2026-03-05', category: 'utilities', amount: 3500, description: 'Water bill' },
      { date: '2026-03-05', category: 'food', amount: 1500, description: 'Restaurant' }
    ];

    for (const item of sampleData) {
      await runAsync(
        `INSERT INTO transactions (date, category, amount, description, created_at, updated_at)
         VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))`,
        [item.date, item.category, item.amount, item.description]
      );
    }

    console.log(`✅ Seeded ${sampleData.length} sample transactions`);
  } catch (error) {
    console.error('⚠️  Seed data error:', error.message);
    // Don't throw, just warn - this shouldn't block server startup
  }
};

module.exports = {
  initializeDatabase,
  getDatabase,
  runAsync,
  getAsync,
  allAsync,
  seedDatabase,
  DB_PATH
};
