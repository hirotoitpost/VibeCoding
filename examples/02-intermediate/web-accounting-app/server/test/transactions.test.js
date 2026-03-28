/**
 * Transaction API Integration Tests
 * 
 * Jest + supertest を使用した API テスト
 * 
 * 実行方法:
 *   npm test
 *   npm test -- --verbose
 *   npm test -- --watch
 */

const request = require('supertest');
const express = require('express');
const bodyParser = require('body-parser');
const transactionRoutes = require('../routes/transactions');
const db = require('../db');

// Express アプリのセットアップ（テスト用）
const createTestApp = () => {
  const app = express();
  app.use(bodyParser.json());
  app.use(express.json());
  app.use('/api/transactions', transactionRoutes);

  // エラーハンドラー
  app.use((err, req, res, next) => {
    console.error('Test Error:', err);
    res.status(err.status || 500).json({
      error: err.message || 'Internal server error'
    });
  });

  return app;
};

describe('Transaction API Tests', () => {
  let app;

  beforeAll(async () => {
    // テスト用DB初期化
    await db.initializeDatabase();
    app = createTestApp();
  });

  afterEach(async () => {
    // 各テスト後にテーブルをクリア
    try {
      await db.runAsync('DELETE FROM transactions');
    } catch (err) {
      console.error('Cleanup error:', err);
    }
  });

  // ============================================================================
  // GET /api/transactions - List all transactions
  // ============================================================================

  describe('GET /api/transactions', () => {
    test('should return empty array when no transactions exist', async () => {
      const response = await request(app)
        .get('/api/transactions')
        .expect(200);

      expect(response.body).toEqual({
        success: true,
        count: 0,
        data: []
      });
    });

    test('should return all transactions', async () => {
      // Create sample data
      await db.runAsync(
        `INSERT INTO transactions (date, category, amount, description, created_at, updated_at)
         VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))`,
        ['2026-03-01', 'food', 1200, 'Lunch']
      );
      await db.runAsync(
        `INSERT INTO transactions (date, category, amount, description, created_at, updated_at)
         VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))`,
        ['2026-03-02', 'transport', 500, 'Gas']
      );

      const response = await request(app)
        .get('/api/transactions')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.count).toBe(2);
      expect(response.body.data.length).toBe(2);
    });

    test('should filter by category', async () => {
      await db.runAsync(
        `INSERT INTO transactions (date, category, amount, description, created_at, updated_at)
         VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))`,
        ['2026-03-01', 'food', 1200, 'Lunch']
      );
      await db.runAsync(
        `INSERT INTO transactions (date, category, amount, description, created_at, updated_at)
         VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))`,
        ['2026-03-02', 'transport', 500, 'Gas']
      );

      const response = await request(app)
        .get('/api/transactions?category=food')
        .expect(200);

      expect(response.body.count).toBe(1);
      expect(response.body.data[0].category).toBe('food');
    });

    test('should filter by date range', async () => {
      await db.runAsync(
        `INSERT INTO transactions (date, category, amount, description, created_at, updated_at)
         VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))`,
        ['2026-03-01', 'food', 1200, 'Lunch']
      );
      await db.runAsync(
        `INSERT INTO transactions (date, category, amount, description, created_at, updated_at)
         VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))`,
        ['2026-03-05', 'transport', 500, 'Gas']
      );

      const response = await request(app)
        .get('/api/transactions?startDate=2026-03-02&endDate=2026-03-06')
        .expect(200);

      expect(response.body.count).toBe(1);
      expect(response.body.data[0].date).toBe('2026-03-05');
    });
  });

  // ============================================================================
  // GET /api/transactions/:id - Get single transaction
  // ============================================================================

  describe('GET /api/transactions/:id', () => {
    test('should return transaction by ID', async () => {
      const result = await db.runAsync(
        `INSERT INTO transactions (date, category, amount, description, created_at, updated_at)
         VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))`,
        ['2026-03-01', 'food', 1200, 'Lunch']
      );

      const response = await request(app)
        .get(`/api/transactions/${result.lastID}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(result.lastID);
      expect(response.body.data.category).toBe('food');
    });

    test('should return 404 for non-existent transaction', async () => {
      const response = await request(app)
        .get('/api/transactions/9999')
        .expect(404);

      expect(response.body.error).toBe('Transaction not found');
    });

    test('should return 400 for invalid ID', async () => {
      const response = await request(app)
        .get('/api/transactions/invalid')
        .expect(400);

      expect(response.body.error).toBe('Invalid transaction ID');
    });
  });

  // ============================================================================
  // POST /api/transactions - Create transaction
  // ============================================================================

  describe('POST /api/transactions', () => {
    test('should create a transaction', async () => {
      const response = await request(app)
        .post('/api/transactions')
        .send({
          date: '2026-03-01',
          category: 'food',
          amount: 1200,
          description: 'Lunch'
        })
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Transaction created successfully');
      expect(response.body.data.id).toBeDefined();
      expect(response.body.data.category).toBe('food');
    });

    test('should return 400 when missing required fields', async () => {
      const response = await request(app)
        .post('/api/transactions')
        .send({
          date: '2026-03-01',
          category: 'food'
          // amount is missing
        })
        .expect(400);

      expect(response.body.error).toBe('Missing required fields');
    });

    test('should return 400 for invalid date format', async () => {
      const response = await request(app)
        .post('/api/transactions')
        .send({
          date: '03/01/2026', // Invalid format
          category: 'food',
          amount: 1200
        })
        .expect(400);

      expect(response.body.error).toBe('Invalid date format. Use YYYY-MM-DD');
    });

    test('should return 400 for invalid category', async () => {
      const response = await request(app)
        .post('/api/transactions')
        .send({
          date: '2026-03-01',
          category: 'invalid_category',
          amount: 1200
        })
        .expect(400);

      expect(response.body.error).toContain('Invalid category');
    });

    test('should return 400 for negative amount', async () => {
      const response = await request(app)
        .post('/api/transactions')
        .send({
          date: '2026-03-01',
          category: 'food',
          amount: -1200
        })
        .expect(400);

      expect(response.body.error).toBe('Amount must be a positive number');
    });

    test('should allow optional description', async () => {
      const response = await request(app)
        .post('/api/transactions')
        .send({
          date: '2026-03-01',
          category: 'food',
          amount: 1200
          // description omitted
        })
        .expect(201);

      expect(response.body.data.description).toBe('');
    });
  });

  // ============================================================================
  // PUT /api/transactions/:id - Update transaction
  // ============================================================================

  describe('PUT /api/transactions/:id', () => {
    test('should update a transaction', async () => {
      const result = await db.runAsync(
        `INSERT INTO transactions (date, category, amount, description, created_at, updated_at)
         VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))`,
        ['2026-03-01', 'food', 1200, 'Lunch']
      );

      const response = await request(app)
        .put(`/api/transactions/${result.lastID}`)
        .send({
          date: '2026-03-02',
          category: 'transport',
          amount: 500,
          description: 'Updated: Gas'
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.category).toBe('transport');
      expect(response.body.data.amount).toBe(500);
    });

    test('should return 404 when updating non-existent transaction', async () => {
      const response = await request(app)
        .put('/api/transactions/9999')
        .send({
          date: '2026-03-01',
          category: 'food',
          amount: 1200
        })
        .expect(404);

      expect(response.body.error).toBe('Transaction not found');
    });
  });

  // ============================================================================
  // DELETE /api/transactions/:id - Delete transaction
  // ============================================================================

  describe('DELETE /api/transactions/:id', () => {
    test('should delete a transaction', async () => {
      const result = await db.runAsync(
        `INSERT INTO transactions (date, category, amount, description, created_at, updated_at)
         VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))`,
        ['2026-03-01', 'food', 1200, 'Lunch']
      );

      const response = await request(app)
        .delete(`/api/transactions/${result.lastID}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Transaction deleted successfully');

      // Verify deletion
      const checkResponse = await request(app)
        .get(`/api/transactions/${result.lastID}`)
        .expect(404);
    });

    test('should return 404 when deleting non-existent transaction', async () => {
      const response = await request(app)
        .delete('/api/transactions/9999')
        .expect(404);

      expect(response.body.error).toBe('Transaction not found');
    });
  });

  // ============================================================================
  // GET /api/transactions/summary/monthly - Monthly summary
  // ============================================================================

  describe('GET /api/transactions/summary/monthly', () => {
    beforeEach(async () => {
      // Insert sample data
      const data = [
        ['2026-03-01', 'food', 1200],
        ['2026-03-01', 'food', 800],
        ['2026-03-02', 'transport', 500],
        ['2026-03-03', 'utilities', 8000]
      ];

      for (const [date, category, amount] of data) {
        await db.runAsync(
          `INSERT INTO transactions (date, category, amount, description, created_at, updated_at)
           VALUES (?, ?, ?, '', datetime('now'), datetime('now'))`,
          [date, category, amount]
        );
      }
    });

    test('should return monthly summary', async () => {
      const response = await request(app)
        .get('/api/transactions/summary/monthly?year=2026&month=03')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.period).toBe('2026-03');
      expect(response.body.summary.length).toBeGreaterThan(0);
      expect(response.body.grandTotal).toBeGreaterThan(0);
    });

    test('should return 400 when missing parameters', async () => {
      const response = await request(app)
        .get('/api/transactions/summary/monthly?year=2026')
        .expect(400);

      expect(response.body.error).toContain('Missing required parameters');
    });
  });

  // ============================================================================
  // Integration Tests - Combined operations
  // ============================================================================

  describe('Integration Tests', () => {
    test('should handle complete CRUD cycle', async () => {
      // CREATE
      const createRes = await request(app)
        .post('/api/transactions')
        .send({
          date: '2026-03-01',
          category: 'food',
          amount: 1200
        })
        .expect(201);

      const id = createRes.body.data.id;
      expect(id).toBeDefined();

      // READ
      const readRes = await request(app)
        .get(`/api/transactions/${id}`)
        .expect(200);

      expect(readRes.body.data.category).toBe('food');

      // UPDATE
      const updateRes = await request(app)
        .put(`/api/transactions/${id}`)
        .send({
          date: '2026-03-02',
          category: 'transport',
          amount: 500
        })
        .expect(200);

      expect(updateRes.body.data.category).toBe('transport');

      // DELETE
      await request(app)
        .delete(`/api/transactions/${id}`)
        .expect(200);

      // Verify deletion
      await request(app)
        .get(`/api/transactions/${id}`)
        .expect(404);
    });
  });
});
