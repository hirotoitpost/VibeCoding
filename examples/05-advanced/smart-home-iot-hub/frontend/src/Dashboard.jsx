import { useState, useEffect } from 'react'
import './Dashboard.css'

function Dashboard({ devices, onDelete }) {
  const [deviceData, setDeviceData] = useState({})

  useEffect(() => {
    // Fetch recent data for all devices
    const fetchAllData = async () => {
      const newData = {}
      for (const device of devices) {
        try {
          const response = await fetch(`/api/devices/${device.id}/data?limit=5`)
          if (response.ok) {
            const result = await response.json()
            newData[device.id] = result.data || []
          }
        } catch (err) {
          console.error(`Failed to fetch data for ${device.id}:`, err)
        }
      }
      setDeviceData(newData)
    }

    if (devices.length > 0) {
      fetchAllData()
      const interval = setInterval(fetchAllData, 5000)
      return () => clearInterval(interval)
    }
  }, [devices])

  if (devices.length === 0) {
    return <p className="no-devices">デバイスが登録されていません</p>
  }

  return (
    <div className="dashboard-grid">
      {devices.map((device) => (
        <div key={device.id} className={`device-card device-${device.type}`}>
          <div className="device-header">
            <h3>{device.name}</h3>
            <span className="device-type">{device.type}</span>
          </div>

          <div className="device-body">
            <p><strong>場所:</strong> {device.location}</p>
            <p><strong>MQTT:</strong> <code>{device.mqtt_topic}</code></p>
            <p><strong>状態:</strong> {device.is_active ? '🟢 稼働中' : '🔴 停止中'}</p>

            {/* Recent Data */}
            {deviceData[device.id] && deviceData[device.id].length > 0 && (
              <div className="recent-data">
                <h4>最新データ</h4>
                <table>
                  <thead>
                    <tr>
                      <th>値</th>
                      <th>単位</th>
                      <th>時刻</th>
                    </tr>
                  </thead>
                  <tbody>
                    {deviceData[device.id].slice(0, 3).map((data, idx) => (
                      <tr key={idx}>
                        <td>{data.value}</td>
                        <td>{data.unit || '-'}</td>
                        <td>{new Date(data.timestamp).toLocaleTimeString('ja-JP')}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>

          <div className="device-footer">
            <button
              className="btn-delete"
              onClick={() => onDelete(device.id)}
            >
              削除
            </button>
          </div>
        </div>
      ))}
    </div>
  )
}

export default Dashboard
