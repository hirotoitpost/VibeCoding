import { useState, useEffect } from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import './App.css'

/**
 * メインアプリケーション
 * 
 * ルート管理とナビゲーション
 */
function App() {
  const [transactions, setTransactions] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  // API ベース URL（環境変数から取得）
  const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000'

  /**
   * トランザクション取得
   */
  const fetchTransactions = async () => {
    try {
      setLoading(true)
      const response = await fetch(`${API_URL}/api/transactions`)
      if (!response.ok) throw new Error('Failed to fetch transactions')
      const data = await response.json()
      setTransactions(data)
      setError(null)
    } catch (err) {
      setError(err.message)
      console.error('Error fetching transactions:', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchTransactions()
  }, [])

  return (
    <Router>
      <div className="app">
        <nav className="navbar">
          <h1>💰 Web 家計簿アプリ</h1>
          <p className="status">
            {loading && '読込中...'}
            {error && `⚠️ ${error}`}
            {!loading && !error && `${transactions.length} 件の取引`}
          </p>
        </nav>

        <main className="container">
          {loading && <div className="loading">読込中...</div>}
          {error && <div className="error">エラー: {error}</div>}
          
          {!loading && !error && (
            <Routes>
              <Route path="/" element={
                <div className="dashboard">
                  <h2>ダッシュボード</h2>
                  <p>🚀 フロントエンド実装進行中...</p>
                  <div className="transaction-list">
                    <h3>最近の取引</h3>
                    {transactions.length === 0 ? (
                      <p className="empty">まだ取引記録がありません</p>
                    ) : (
                      <ul>
                        {transactions.map((tx, idx) => (
                          <li key={idx} className="transaction-item">
                            <span className="date">{tx.date}</span>
                            <span className="category">{tx.category}</span>
                            <span className={`amount ${tx.amount > 0 ? 'income' : 'expense'}`}>
                              ¥{tx.amount}
                            </span>
                          </li>
                        ))}
                      </ul>
                    )}
                  </div>
                </div>
              } />
            </Routes>
          )}
        </main>

        <footer className="footer">
          <p>ID 008: Phase 3.2.A Web 家計簿アプリ 🚀 開発中</p>
        </footer>
      </div>
    </Router>
  )
}

export default App
