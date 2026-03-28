/**
 * Transaction Form Component
 * 
 * 新規作成・編集フォーム
 */

import { useState, useEffect } from 'react'

export default function TransactionForm({ apiUrl, txId, onSave, onCancel }) {
  const [formData, setFormData] = useState({
    date: new Date().toISOString().split('T')[0],
    category: 'food',
    amount: '',
    description: ''
  })
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [success, setSuccess] = useState(false)

  const categories = ['food', 'transport', 'entertainment', 'utilities', 'other']

  /**
   * Fetch transaction if editing
   */
  useEffect(() => {
    if (txId) {
      fetchTransaction(txId)
    }
  }, [txId])

  /**
   * Fetch existing transaction
   */
  const fetchTransaction = async (id) => {
    try {
      setLoading(true)
      const response = await fetch(`${apiUrl}/api/transactions/${id}`)
      if (!response.ok) throw new Error('Failed to fetch transaction')
      const data = await response.json()
      setFormData(data.data)
    } catch (err) {
      setError('トランザクションの読み込みに失敗しました: ' + err.message)
    } finally {
      setLoading(false)
    }
  }

  /**
   * Handle form input change
   */
  const handleChange = (e) => {
    const { name, value } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: name === 'amount' ? (value ? parseFloat(value) : '') : value
    }))
  }

  /**
   * Submit form
   */
  const handleSubmit = async (e) => {
    e.preventDefault()
    setError(null)
    setSuccess(false)

    // Validation
    if (!formData.date || !formData.category || !formData.amount) {
      setError('必須項目を入力してください')
      return
    }

    if (formData.amount <= 0) {
      setError('金額は正の数である必要があります')
      return
    }

    try {
      setLoading(true)
      const url = txId
        ? `${apiUrl}/api/transactions/${txId}`
        : `${apiUrl}/api/transactions`

      const method = txId ? 'PUT' : 'POST'

      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      })

      if (!response.ok) {
        const errData = await response.json()
        throw new Error(errData.error || 'Save failed')
      }

      setSuccess(true)
      setTimeout(() => {
        onSave && onSave()
      }, 1000)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  if (loading && txId) {
    return <div className="loading">読込中...</div>
  }

  return (
    <div className="form-container">
      <div className="form-header">
        <h2>{txId ? '✏️ 編集' : '➕ 新規取引'}</h2>
        <button className="btn-close" onClick={onCancel}>✕</button>
      </div>

      {error && <div className="alert alert-error">⚠️ {error}</div>}
      {success && (
        <div className="alert alert-success">
          ✅ {txId ? '更新しました' : '作成しました'}
        </div>
      )}

      <form onSubmit={handleSubmit} className="transaction-form">
        {/* Date */}
        <div className="form-group">
          <label htmlFor="date">日付</label>
          <input
            type="date"
            id="date"
            name="date"
            value={formData.date}
            onChange={handleChange}
            required
          />
        </div>

        {/* Category */}
        <div className="form-group">
          <label htmlFor="category">カテゴリ</label>
          <select
            id="category"
            name="category"
            value={formData.category}
            onChange={handleChange}
            required
          >
            {categories.map(cat => (
              <option key={cat} value={cat}>
                {cat}
              </option>
            ))}
          </select>
        </div>

        {/* Amount */}
        <div className="form-group">
          <label htmlFor="amount">
            金額 <span className="required">*</span>
          </label>
          <input
            type="number"
            id="amount"
            name="amount"
            placeholder="0"
            value={formData.amount}
            onChange={handleChange}
            step="0.01"
            min="0"
            required
          />
        </div>

        {/* Description */}
        <div className="form-group">
          <label htmlFor="description">説明（オプション）</label>
          <textarea
            id="description"
            name="description"
            placeholder="メモ..."
            value={formData.description}
            onChange={handleChange}
            maxLength="500"
            rows="3"
          ></textarea>
          <small>
            {formData.description.length}/500
          </small>
        </div>

        {/* Buttons */}
        <div className="form-buttons">
          <button
            type="submit"
            className="btn btn-primary"
            disabled={loading}
          >
            {loading
              ? '送信中...'
              : txId
              ? '更新する'
              : '作成する'}
          </button>
          <button
            type="button"
            className="btn btn-secondary"
            onClick={onCancel}
            disabled={loading}
          >
            キャンセル
          </button>
        </div>
      </form>

      {/* Info Box */}
      <div className="info-box">
        <p>💡 ヒント</p>
        <ul>
          <li>日付は過去の日付も選択できます</li>
          <li>カテゴリは後から変更可能です</li>
          <li>金額は正の数で入力してください</li>
        </ul>
      </div>
    </div>
  )
}
