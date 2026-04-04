import { useState, useEffect } from 'react'
import Dashboard from './Dashboard.jsx'
import './App.css'

function App() {
  const [devices, setDevices] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [newDevice, setNewDevice] = useState({
    name: '',
    type: 'sensor',
    location: '',
    mqtt_topic: ''
  })

  // Fetch devices on mount
  useEffect(() => {
    fetchDevices()
    const interval = setInterval(fetchDevices, 5000) // Refresh every 5 seconds
    return () => clearInterval(interval)
  }, [])

  const fetchDevices = async () => {
    try {
      const response = await fetch(`/api/devices`)
      if (!response.ok) throw new Error('Failed to fetch devices')
      const result = await response.json()
      setDevices(result.data || [])
      setError(null)
    } catch (err) {
      setError(err.message)
      console.error('Error fetching devices:', err)
    } finally {
      setLoading(false)
    }
  }

  const registerDevice = async (e) => {
    e.preventDefault()
    if (!newDevice.name || !newDevice.location || !newDevice.mqtt_topic) {
      alert('Please fill in all fields')
      return
    }

    try {
      setLoading(true)
      const response = await fetch(`/api/devices`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newDevice)
      })
      if (!response.ok) throw new Error('Failed to register device')
      
      await fetchDevices()
      setNewDevice({
        name: '',
        type: 'sensor',
        location: '',
        mqtt_topic: ''
      })
    } catch (err) {
      setError(err.message)
      console.error('Error registering device:', err)
    } finally {
      setLoading(false)
    }
  }

  const deleteDevice = async (id) => {
    if (!confirm('Delete this device?')) return
    
    try {
      setLoading(true)
      const response = await fetch(`/api/devices/${id}`, {
        method: 'DELETE'
      })
      if (!response.ok) throw new Error('Failed to delete device')
      await fetchDevices()
    } catch (err) {
      setError(err.message)
      console.error('Error deleting device:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="app-container">
      <header className="app-header">
        <h1>🏠 Smart Home IoT Hub</h1>
        <p>リアルタイム デバイス管理ダッシュボード</p>
      </header>

      {error && <div className="error-banner">{error}</div>}

      <div className="app-main">
        {/* Device Registration Section */}
        <section className="register-section">
          <h2>📱 デバイス登録</h2>
          <form onSubmit={registerDevice} className="register-form">
            <input
              type="text"
              placeholder="デバイス名"
              value={newDevice.name}
              onChange={(e) => setNewDevice({...newDevice, name: e.target.value})}
              required
            />
            <select
              value={newDevice.type}
              onChange={(e) => setNewDevice({...newDevice, type: e.target.value})}
            >
              <option value="sensor">センサー</option>
              <option value="switch">スイッチ</option>
              <option value="actuator">アクチュエーター</option>
            </select>
            <input
              type="text"
              placeholder="設置場所"
              value={newDevice.location}
              onChange={(e) => setNewDevice({...newDevice, location: e.target.value})}
              required
            />
            <input
              type="text"
              placeholder="MQTT トピック"
              value={newDevice.mqtt_topic}
              onChange={(e) => setNewDevice({...newDevice, mqtt_topic: e.target.value})}
              required
            />
            <button type="submit" disabled={loading}>
              {loading ? '登録中...' : '登録'}
            </button>
          </form>
        </section>

        {/* Dashboard Section */}
        <section className="dashboard-section">
          <h2>📊 デバイスダッシュボード</h2>
          {loading && devices.length === 0 ? (
            <p className="loading">読み込み中...</p>
          ) : (
            <Dashboard
              devices={devices}
              onDelete={deleteDevice}
            />
          )}
        </section>
      </div>
    </div>
  )
}

export default App
