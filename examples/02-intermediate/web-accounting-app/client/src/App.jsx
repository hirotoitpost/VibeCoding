import { useState } from 'react'
import './App.css'
import Dashboard from './Dashboard'
import TransactionForm from './TransactionForm'

/**
 * Web 家計簿アプリケーション
 * 
 * ページ遷移:
 * - Dashboard: 取引一覧・集計表示
 * - TransactionForm: 新規作成・編集
 */

function App() {
  const [currentPage, setCurrentPage] = useState('dashboard') // dashboard | form
  const [editingTxId, setEditingTxId] = useState(null)

  // API ベース URL（環境変数から取得）
  const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000'

  /**
   * Open form for new transaction
   */
  const handleAddTransaction = () => {
    setEditingTxId(null)
    setCurrentPage('form')
  }

  /**
   * After successful save
   */
  const handleFormSave = () => {
    setCurrentPage('dashboard')
    setEditingTxId(null)
  }

  /**
   * Cancel form
   */
  const handleFormCancel = () => {
    setCurrentPage('dashboard')
    setEditingTxId(null)
  }

  return (
    <div className="app">
      {/* Navigation Bar */}
      <nav className="navbar">
        <div className="nav-brand">
          <h1>
            {currentPage === 'dashboard' ? '💰' : '📝'} Web 家計簿
          </h1>
        </div>
        <div className="nav-status">
          <span className="page-indicator">
            {currentPage === 'dashboard' ? '📊 ダッシュボード' : '➕ 新規取引'}
          </span>
        </div>
      </nav>

      {/* Main Content */}
      <main className="container">
        {currentPage === 'dashboard' ? (
          <Dashboard
            apiUrl={API_URL}
            onAddClick={handleAddTransaction}
          />
        ) : (
          <TransactionForm
            apiUrl={API_URL}
            txId={editingTxId}
            onSave={handleFormSave}
            onCancel={handleFormCancel}
          />
        )}
      </main>

      {/* Footer */}
      <footer className="footer">
        <p>🚀 Web 家計簿 v1.0 | VideCoding Learning Project</p>
      </footer>
    </div>
  )
}

export default App
