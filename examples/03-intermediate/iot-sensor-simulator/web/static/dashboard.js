/**
 * IoT センサーシミュレーター - ダッシュボード JavaScript
 * リアルタイム更新・グラフ描画・アラーム表示
 */

// グラフ参照
let tempChart = null;
let humidityChart = null;

// データストレージ
const chartData = {
    temperatures: [],
    humidities: [],
    timestamps: [],
};

const maxDataPoints = 50;

/**
 * 初期化
 */
document.addEventListener('DOMContentLoaded', () => {
    console.log('🚀 Dashboard initialized');
    
    // ダッシュボード初期化
    initCharts();
    updateDashboard();
    updateFooter();
    
    // 定期更新
    setInterval(updateDashboard, 5000);  // 5秒間隔
    setInterval(updateFooter, 1000);      // 1秒間隔
});

/**
 * グラフ初期化
 */
function initCharts() {
    const ctxTemp = document.getElementById('tempChart').getContext('2d');
    const ctxHumidity = document.getElementById('humidityChart').getContext('2d');
    
    tempChart = new Chart(ctxTemp, {
        type: 'line',
        data: {
            labels: chartData.timestamps,
            datasets: [{
                label: '温度（℃）',
                data: chartData.temperatures,
                borderColor: '#FF6384',
                backgroundColor: 'rgba(255, 99, 132, 0.1)',
                tension: 0.4,
                fill: true,
                pointRadius: 3,
            }],
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: '温度時系列',
                },
                legend: {
                    display: true,
                },
            },
            scales: {
                y: {
                    beginAtZero: false,
                    title: {
                        display: true,
                        text: '温度（℃）',
                    },
                },
            },
        },
    });
    
    humidityChart = new Chart(ctxHumidity, {
        type: 'line',
        data: {
            labels: chartData.timestamps,
            datasets: [{
                label: '湿度（%）',
                data: chartData.humidities,
                borderColor: '#36A2EB',
                backgroundColor: 'rgba(54, 162, 235, 0.1)',
                tension: 0.4,
                fill: true,
                pointRadius: 3,
            }],
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: '湿度時系列',
                },
                legend: {
                    display: true,
                },
            },
            scales: {
                y: {
                    beginAtZero: false,
                    min: 0,
                    max: 100,
                    title: {
                        display: true,
                        text: '湿度（%）',
                    },
                },
            },
        },
    });
}

/**
 * ダッシュボード更新
 */
async function updateDashboard() {
    try {
        // センサー情報取得
        const sensorsResp = await fetch('/api/sensors');
        const sensorsData = await sensorsResp.json();
        updateSensorsGrid(sensorsData.sensors);
        
        // 計測値取得
        const readingsResp = await fetch('/api/readings?limit=50');
        const readingsData = await readingsResp.json();
        updateCharts(readingsData.readings);
        
        // アラーム取得
        const alarmsResp = await fetch('/api/alarms?limit=10');
        const alarmsData = await alarmsResp.json();
        updateAlarmsList(alarmsData.alarms);
        
        // ステータス更新
        updateStatus('ok');
    } catch (err) {
        console.error('Error updating dashboard:', err);
        updateStatus('error');
    }
}

/**
 * センサーグリッド更新
 */
function updateSensorsGrid(sensors) {
    const grid = document.getElementById('sensors-grid');
    
    if (!sensors || sensors.length === 0) {
        grid.innerHTML = '<p class="placeholder">データ取得中...</p>';
        return;
    }
    
    grid.innerHTML = sensors
        .sort((a, b) => a.room.localeCompare(b.room))
        .map(sensor => {
            const tempAlarm = sensor.temperature > 30 || sensor.temperature < 5;
            const humidityAlarm = sensor.humidity > 80 || sensor.humidity < 40;
            const isAlarm = tempAlarm || humidityAlarm;
            
            return `
                <div class="sensor-card ${isAlarm ? 'alarm' : ''}">
                    <div class="room-name">${sensor.room}</div>
                    <div class="sensor-value">
                        <div class="sensor-value-item">
                            <div class="label">温度</div>
                            <div class="value">${sensor.temperature.toFixed(1)}°C</div>
                        </div>
                        <div class="sensor-value-item">
                            <div class="label">湿度</div>
                            <div class="value">${sensor.humidity.toFixed(1)}%</div>
                        </div>
                    </div>
                </div>
            `;
        })
        .join('');
}

/**
 * グラフ更新
 */
function updateCharts(readings) {
    if (!readings || readings.length === 0) return;
    
    // データを時間順にソート
    const sortedReadings = readings
        .sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
    
    // 最新データのみを保持（maxDataPoints）
    chartData.temperatures = sortedReadings
        .slice(-maxDataPoints)
        .map(r => r.temperature);
    chartData.humidities = sortedReadings
        .slice(-maxDataPoints)
        .map(r => r.humidity);
    chartData.timestamps = sortedReadings
        .slice(-maxDataPoints)
        .map(r => formatTime(r.timestamp));
    
    // グラフ更新
    if (tempChart) {
        tempChart.data.labels = chartData.timestamps;
        tempChart.data.datasets[0].data = chartData.temperatures;
        tempChart.update();
    }
    
    if (humidityChart) {
        humidityChart.data.labels = chartData.timestamps;
        humidityChart.data.datasets[0].data = chartData.humidities;
        humidityChart.update();
    }
}

/**
 * アラームリスト更新
 */
function updateAlarmsList(alarms) {
    const list = document.getElementById('alarms-list');
    
    if (!alarms || alarms.length === 0) {
        list.innerHTML = '<p class="placeholder">アラームはありません</p>';
        return;
    }
    
    list.innerHTML = alarms
        .slice(0, 10)
        .map(alarm => {
            const isHigh = alarm.alarm_type.includes('high');
            return `
                <div class="alarm-item ${isHigh ? 'high' : ''}">
                    <div class="message">
                        <strong>${alarm.alarm_type}</strong>: 
                        ${alarm.message}
                    </div>
                    <div class="timestamp">${formatTime(alarm.timestamp)}</div>
                </div>
            `;
        })
        .join('');
}

/**
 * ステータス更新
 */
function updateStatus(status) {
    const statusEl = document.getElementById('status');
    const lastUpdateEl = document.getElementById('last-update');
    
    if (status === 'ok') {
        statusEl.textContent = '✅ オンライン';
        statusEl.style.color = '#4CAF50';
    } else {
        statusEl.textContent = '❌ オフライン';
        statusEl.style.color = '#F44336';
    }
    
    lastUpdateEl.textContent = new Date().toLocaleTimeString('ja-JP');
}

/**
 * フッター更新
 */
function updateFooter() {
    const footerTime = document.getElementById('footer-time');
    const now = new Date();
    footerTime.textContent = now.toLocaleString('ja-JP');
}

/**
 * 時刻フォーマット
 */
function formatTime(timestamp) {
    const date = new Date(timestamp);
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
}

// デバッグログ
console.log('🎯 Dashboard script loaded');
