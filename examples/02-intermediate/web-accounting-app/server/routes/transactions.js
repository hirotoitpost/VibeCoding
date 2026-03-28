/**
 * Transaction API Routes
 * RESTful CRUD endpoints for personal accounting transactions
 */

const express = require('express')
const router = express.Router()
const db = require('../db')

// ============================================================================
// Middleware for route-specific validation
// ============================================================================

/**
 * Validate transaction data structure
 * - date: ISO date string (YYYY-MM-DD)
 * - category: string (food, transport, entertainment, utilities, other)
 * - amount: positive number
 * - description: optional string
 */
const validateTransaction = (req, res, next) => {
  const { date, category, amount, description } = req.body

  // Required fields check
  if (!date || !category || amount === undefined) {
    return res.status(400).json({
      error: 'Missing required fields',
      required: { date, category, amount }
    })
  }

  // Date format validation
  const dateRegex = /^\d{4}-\d{2}-\d{2}$/
  if (!dateRegex.test(date)) {
    return res.status(400).json({
      error: 'Invalid date format. Use YYYY-MM-DD'
    })
  }

  // Category validation
  const validCategories = ['food', 'transport', 'entertainment', 'utilities', 'other']
  if (!validCategories.includes(category)) {
    return res.status(400).json({
      error: `Invalid category. Must be one of: ${validCategories.join(', ')}`
    })
  }

  // Amount validation
  if (typeof amount !== 'number' || amount <= 0) {
    return res.status(400).json({
      error: 'Amount must be a positive number'
    })
  }

  // Description validation (optional, max 500 chars)
  if (description && typeof description !== 'string') {
    return res.status(400).json({
      error: 'Description must be a string'
    })
  }
  if (description && description.length > 500) {
    return res.status(400).json({
      error: 'Description must not exceed 500 characters'
    })
  }

  next()
}

// ============================================================================
// GET /api/transactions
// Retrieve all transactions with optional filtering
// Query parameters:
//   - startDate: ISO date (YYYY-MM-DD) for filtering
//   - endDate: ISO date (YYYY-MM-DD) for filtering
//   - category: filter by single category
// ============================================================================

router.get('/', async (req, res) => {
  try {
    const { startDate, endDate, category } = req.query
    let query = 'SELECT * FROM transactions WHERE 1=1'
    const params = []

    // Date range filtering
    if (startDate) {
      if (!/^\d{4}-\d{2}-\d{2}$/.test(startDate)) {
        return res.status(400).json({ error: 'Invalid startDate format' })
      }
      query += ' AND date >= ?'
      params.push(startDate)
    }

    if (endDate) {
      if (!/^\d{4}-\d{2}-\d{2}$/.test(endDate)) {
        return res.status(400).json({ error: 'Invalid endDate format' })
      }
      query += ' AND date <= ?'
      params.push(endDate)
    }

    // Category filtering
    if (category) {
      const validCategories = ['food', 'transport', 'entertainment', 'utilities', 'other']
      if (!validCategories.includes(category)) {
        return res.status(400).json({
          error: `Invalid category: ${category}`
        })
      }
      query += ' AND category = ?'
      params.push(category)
    }

    // Sort by date DESC (newest first)
    query += ' ORDER BY date DESC'

    const transactions = await db.allAsync(query, params)
    res.json({
      success: true,
      count: transactions.length,
      data: transactions
    })
  } catch (error) {
    console.error('Error fetching transactions:', error)
    res.status(500).json({
      error: 'Failed to fetch transactions',
      message: error.message
    })
  }
})

// ============================================================================
// GET /api/transactions/:id
// Retrieve a single transaction by ID
// ============================================================================

router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params

    // ID validation
    const idNum = parseInt(id, 10)
    if (isNaN(idNum) || idNum <= 0) {
      return res.status(400).json({
        error: 'Invalid transaction ID'
      })
    }

    const transaction = await db.getAsync(
      'SELECT * FROM transactions WHERE id = ?',
      [idNum]
    )

    if (!transaction) {
      return res.status(404).json({
        error: 'Transaction not found',
        id: idNum
      })
    }

    res.json({
      success: true,
      data: transaction
    })
  } catch (error) {
    console.error('Error fetching transaction:', error)
    res.status(500).json({
      error: 'Failed to fetch transaction',
      message: error.message
    })
  }
})

// ============================================================================
// POST /api/transactions
// Create a new transaction
// ============================================================================

router.post('/', validateTransaction, async (req, res) => {
  try {
    const { date, category, amount, description = '' } = req.body

    const result = await db.runAsync(
      `INSERT INTO transactions (date, category, amount, description, created_at, updated_at)
       VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))`,
      [date, category, amount, description]
    )

    // Fetch the created transaction
    const transaction = await db.getAsync(
      'SELECT * FROM transactions WHERE id = ?',
      [result.lastID]
    )

    res.status(201).json({
      success: true,
      message: 'Transaction created successfully',
      data: transaction
    })
  } catch (error) {
    console.error('Error creating transaction:', error)
    res.status(500).json({
      error: 'Failed to create transaction',
      message: error.message
    })
  }
})

// ============================================================================
// PUT /api/transactions/:id
// Update an existing transaction
// ============================================================================

router.put('/:id', validateTransaction, async (req, res) => {
  try {
    const { id } = req.params
    const { date, category, amount, description = '' } = req.body

    // ID validation
    const idNum = parseInt(id, 10)
    if (isNaN(idNum) || idNum <= 0) {
      return res.status(400).json({
        error: 'Invalid transaction ID'
      })
    }

    // Check if transaction exists
    const existing = await db.getAsync(
      'SELECT id FROM transactions WHERE id = ?',
      [idNum]
    )

    if (!existing) {
      return res.status(404).json({
        error: 'Transaction not found',
        id: idNum
      })
    }

    // Update transaction
    await db.runAsync(
      `UPDATE transactions 
       SET date = ?, category = ?, amount = ?, description = ?, updated_at = datetime('now')
       WHERE id = ?`,
      [date, category, amount, description, idNum]
    )

    // Fetch updated transaction
    const transaction = await db.getAsync(
      'SELECT * FROM transactions WHERE id = ?',
      [idNum]
    )

    res.json({
      success: true,
      message: 'Transaction updated successfully',
      data: transaction
    })
  } catch (error) {
    console.error('Error updating transaction:', error)
    res.status(500).json({
      error: 'Failed to update transaction',
      message: error.message
    })
  }
})

// ============================================================================
// DELETE /api/transactions/:id
// Delete a transaction
// ============================================================================

router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params

    // ID validation
    const idNum = parseInt(id, 10)
    if (isNaN(idNum) || idNum <= 0) {
      return res.status(400).json({
        error: 'Invalid transaction ID'
      })
    }

    // Check if transaction exists
    const existing = await db.getAsync(
      'SELECT id FROM transactions WHERE id = ?',
      [idNum]
    )

    if (!existing) {
      return res.status(404).json({
        error: 'Transaction not found',
        id: idNum
      })
    }

    // Delete transaction
    await db.runAsync(
      'DELETE FROM transactions WHERE id = ?',
      [idNum]
    )

    res.json({
      success: true,
      message: 'Transaction deleted successfully',
      id: idNum
    })
  } catch (error) {
    console.error('Error deleting transaction:', error)
    res.status(500).json({
      error: 'Failed to delete transaction',
      message: error.message
    })
  }
})

// ============================================================================
// GET /api/transactions/summary/monthly
// Get monthly spending summary by category
// Query parameters:
//   - year: YYYY format
//   - month: MM format (01-12)
// ============================================================================

router.get('/summary/monthly', async (req, res) => {
  try {
    const { year, month } = req.query

    if (!year || !month) {
      return res.status(400).json({
        error: 'Missing required parameters: year, month'
      })
    }

    // Validate year and month format
    const yearNum = parseInt(year, 10)
    const monthNum = parseInt(month, 10)

    if (isNaN(yearNum) || isNaN(monthNum) || monthNum < 1 || monthNum > 12) {
      return res.status(400).json({
        error: 'Invalid year or month format'
      })
    }

    const datePrefix = `${year}-${String(monthNum).padStart(2, '0')}`

    const summary = await db.allAsync(
      `SELECT 
        category,
        COUNT(*) as count,
        SUM(amount) as total,
        AVG(amount) as average,
        MIN(amount) as minimum,
        MAX(amount) as maximum
       FROM transactions
       WHERE date LIKE ?
       GROUP BY category
       ORDER BY total DESC`,
      [`${datePrefix}%`]
    )

    const grandTotal = await db.getAsync(
      `SELECT SUM(amount) as total FROM transactions WHERE date LIKE ?`,
      [`${datePrefix}%`]
    )

    res.json({
      success: true,
      period: datePrefix,
      summary,
      grandTotal: grandTotal?.total || 0
    })
  } catch (error) {
    console.error('Error fetching monthly summary:', error)
    res.status(500).json({
      error: 'Failed to fetch monthly summary',
      message: error.message
    })
  }
})

module.exports = router
