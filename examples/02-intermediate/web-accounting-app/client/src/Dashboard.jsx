/**
 * Dashboard Component
 * 
 * 取引一覧、集計、グラフ表示
 */

import { useEffect, useState } from 'react'

export default function Dashboard({ apiUrl, onAddClick }) {
  const [transactions, setTransactions] = useState([])
  const [summary, setSummary] = useState({})
  const [loading, setLoading] = useState(false)
  const [filter, setFilter] = useState({ category: '', month: '' })
  const [error, setError] = useState(null)

  const categories = ['food', 'transport', 'entertainment', 'utilities', 'other']

  /**
   * Get current month in YYYY-MM format
   */
  const getCurrentMonth = () => {
    const now = new Date()
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`
  }

  /**
   * Fetch transactions
   */
  const fetchTransactions = async () => {
    try {
      setLoading(true)
      setError(null)

      let url = `${apiUrl}/api/transactions`
      const params = new URLSearchParams()

      if (filter.category) {
        params.append('category', filter.category)
      }

      if (params.toString()) {
        url += '?' + params.toString()
      }

      const response = await fetch(url)
      if (!response.ok) throw new Error('Failed to fetch transactions')

      const data = await response.json()
      setTransactions(data.data || [])
    } catch (err) {
      setError(err.message)
      console.error('Error fetching transactions:', err)
    } finally {
      setLoading(false)
    }
  }

  /**
   * Fetch monthly summary
   */
  const fetchSummary = async () => {
    try {
      const month = filter.month || getCurrentMonth()
      const [year, monthNum] = month.split('-')

      const response = await fetch(
        `${apiUrl}/api/transactions/summary/monthly?year=${year}&month=${monthNum}`
      )
      if (!response.ok) throw new Error('Failed to fetch summary')

      const data = await response.json()
      setSummary(data)
    } catch (err) {
      console.error('Error fetching summary:', err)
    }
  }

  /**
   * Delete transaction
   */
  const deleteTransaction = async (id) => {
    if (!confirm('本当に削除しますか？')) return

    try {
      const response = await fetch(`${apiUrl}/api/transactions/${id}`, {
        method: 'DELETE'
      })

      if (!response.ok) throw new Error('Delete failed')

      // Refresh list
      fetchTransactions()
      fetchSummary()
    } catch (err) {
      alert('削除に失敗しました: ' + err.message)
    }
  }

  useEffect(() => {
    fetchTransactions()
    fetchSummary()
  }, [filter])

  const totalAmount = transactions.reduce((sum, t) => sum + t.amount, 0)
  const categoryTotals = {}
  transactions.forEach(t => {
    categoryTotals[t.category] = (categoryTotals[t.category] || 0) + t.amount
  })

  return (
    <div className="dashboard">
      {/* Header */}
      <div className="dashboard-header">
        <h2>📊 ダッシュボード</h2>
        <button className="btn btn-primary" onClick={onAddClick}>
          ➕ 新規取引
        </button>
      </div>

      {/* Error Message */}
      {error && <div className="alert alert-error">⚠️ {error}</div>}

      {/* Filter Section */}
      <div className="filter-section">
        <div className="filter-group">
          <label>カテゴリフィルター</label>
          <select
            value={filter.category}
            onChange={(e) => setFilter({ ...filter, category: e.target.value })}
          >
            <option value="">すべて</option>
            {categories.map(cat => (
              <option key={cat} value={cat}>
                {cat}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="summary-cards">
        <div className="card">
          <h3>合計</h3>
          <p className="amount">¥{totalAmount.toLocaleString()}</p>
        </div>
        <div className="card">
          <h3>件数</h3>
          <p className="amount">{transactions.length}件</p>
        </div>
        <div className="card">
          <h3>平均</h3>
          <p className="amount">
            {transactions.length > 0
              ? `¥${Math.round(totalAmount / transactions.length).toLocaleString()}`
              : '¥0'}
          </p>
        </div>
      </div>

      {/* Category Breakdown */}
      {Object.keys(categoryTotals).length > 0 && (
        <div className="category-breakdown">
          <h3>カテゴリ別集計</h3>
          <div className="category-bars">
            {categories.map(cat => {
              const amount = categoryTotals[cat] || 0
              const percentage =
                totalAmount > 0 ? Math.round((amount / totalAmount) * 100) : 0
              return (
                <div key={cat} className="category-bar">
                  <label>{cat}</label>
                  <div className="bar-container">
                    <div
                      className="bar-fill"
                      style={{ width: `${percentage}%` }}
                    ></div>
                  </div>
                  <span className="amount">¥{amount.toLocaleString()}</span>
                </div>
              )
            })}
          </div>
        </div>
      )}

      {/* Transaction List */}
      <div className="transaction-section">
        <h3>取引履歴</h3>
        {loading ? (
          <div className="loading">読込中...</div>
        ) : transactions.length === 0 ? (
          <div className="empty-state">
            <p>🔍 取引記録がありません</p>
          </div>
        ) : (
          <div className="transaction-list">
            <div className="table-header">
              <span>日付</span>
              <span>カテゴリ</span>
              <span>説明</span>
              <span>金額</span>
              <span>操作</span>
            </div>
            {transactions.map((tx) => (
              <div key={tx.id} className="table-row">
                <span className="date">{tx.date}</span>
                <span className="category">{tx.category}</span>
                <span className="description">
                  {tx.description || '-'}
                </span>
                <span className="amount">¥{tx.amount.toLocaleString()}</span>
                <div className="actions">
                  <button
                    className="btn-small btn-danger"
                    onClick={() => deleteTransaction(tx.id)}
                  >
                    🗑️
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
