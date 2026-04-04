/**
 * Smart Home IoT Hub - Express REST API Server
 * VibeCoding ID 013
 */

import express from 'express';
import cors from 'cors';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import sqlite3 from 'sqlite3';
import { v4 as uuidv4 } from 'uuid';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = process.env.API_PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize SQLite database
const DB_PATH = process.env.DB_PATH || './data/smart_home.db';

// Ensure data directory exists
fs.mkdirSync(dirname(DB_PATH), { recursive: true });

const db = new sqlite3.Database(DB_PATH, (err) => {
  if (err) {
    console.error('[DB] Connection error:', err);
  } else {
    console.log('[DB] ✓ Connected to SQLite');
    initializeDatabase();
  }
});

/**
 * Initialize database schema
 */
function initializeDatabase() {
  db.serialize(() => {
    // Devices table
    db.run(`
      CREATE TABLE IF NOT EXISTS devices (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        location TEXT NOT NULL,
        mqtt_topic TEXT NOT NULL,
        is_active BOOLEAN DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `, (err) => {
      if (err) console.error('[DB] Devices table error:', err);
      else console.log('[DB] ✓ Devices table ready');
    });
    
    // Device data table
    db.run(`
      CREATE TABLE IF NOT EXISTS device_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        value REAL NOT NULL,
        unit TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (device_id) REFERENCES devices(id)
      )
    `, (err) => {
      if (err) console.error('[DB] Device data table error:', err);
      else console.log('[DB] ✓ Device data table ready');
    });
    
    // Schedules table
    db.run(`
      CREATE TABLE IF NOT EXISTS schedules (
        id TEXT PRIMARY KEY,
        device_id TEXT NOT NULL,
        action TEXT NOT NULL,
        time_of_day TEXT NOT NULL,
        is_enabled BOOLEAN DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (device_id) REFERENCES devices(id)
      )
    `, (err) => {
      if (err) console.error('[DB] Schedules table error:', err);
      else console.log('[DB] ✓ Schedules table ready');
    });

    // Logs table
    db.run(`
      CREATE TABLE IF NOT EXISTS logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        action TEXT NOT NULL,
        details TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (device_id) REFERENCES devices(id)
      )
    `, (err) => {
      if (err) console.error('[DB] Logs table error:', err);
      else console.log('[DB] ✓ Logs table ready');
    });
  });
}

/**
 * Utility function to run DB query
 */
function runAsync(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function(err) {
      if (err) reject(err);
      else resolve({ lastID: this.lastID, changes: this.changes });
    });
  });
}

function allAsync(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows);
    });
  });
}

function getAsync(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => {
      if (err) reject(err);
      else resolve(row);
    });
  });
}

// ============================================================================
// Health Check
// ============================================================================

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// ============================================================================
// Device Management Routes
// ============================================================================

/**
 * GET /api/devices - List all devices
 */
app.get('/api/devices', async (req, res) => {
  try {
    const devices = await allAsync('SELECT * FROM devices ORDER BY created_at DESC');
    res.json({
      success: true,
      data: devices,
      count: devices.length
    });
  } catch (error) {
    console.error('[API] Error fetching devices:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * POST /api/devices - Register a new device
 */
app.post('/api/devices', async (req, res) => {
  try {
    const { name, type, location, mqtt_topic } = req.body;
    
    // Validation
    if (!name || !type || !location || !mqtt_topic) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: name, type, location, mqtt_topic'
      });
    }
    
    const deviceId = uuidv4();
    await runAsync(
      `INSERT INTO devices (id, name, type, location, mqtt_topic) 
       VALUES (?, ?, ?, ?, ?)`,
      [deviceId, name, type, location, mqtt_topic]
    );
    
    const device = await getAsync('SELECT * FROM devices WHERE id = ?', [deviceId]);
    
    res.status(201).json({
      success: true,
      data: device,
      message: 'Device registered successfully'
    });
  } catch (error) {
    console.error('[API] Error registering device:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * GET /api/devices/:id - Get device details
 */
app.get('/api/devices/:id', async (req, res) => {
  try {
    const device = await getAsync('SELECT * FROM devices WHERE id = ?', [req.params.id]);
    
    if (!device) {
      return res.status(404).json({ success: false, error: 'Device not found' });
    }
    
    // Get latest data
    const recentData = await allAsync(
      'SELECT * FROM device_data WHERE device_id = ? ORDER BY timestamp DESC LIMIT 10',
      [req.params.id]
    );
    
    res.json({
      success: true,
      data: { ...device, recentData }
    });
  } catch (error) {
    console.error('[API] Error fetching device:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * DELETE /api/devices/:id - Remove device
 */
app.delete('/api/devices/:id', async (req, res) => {
  try {
    const result = await runAsync('DELETE FROM devices WHERE id = ?', [req.params.id]);
    
    if (result.changes === 0) {
      return res.status(404).json({ success: false, error: 'Device not found' });
    }
    
    res.json({ success: true, message: 'Device deleted' });
  } catch (error) {
    console.error('[API] Error deleting device:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================================
// Device Data Routes
// ============================================================================

/**
 * POST /api/devices/:id/data - Record device data
 */
app.post('/api/devices/:id/data', async (req, res) => {
  try {
    const { value, unit } = req.body;
    
    if (value === undefined) {
      return res.status(400).json({ success: false, error: 'Missing value' });
    }
    
    const device = await getAsync('SELECT * FROM devices WHERE id = ?', [req.params.id]);
    if (!device) {
      return res.status(404).json({ success: false, error: 'Device not found' });
    }
    
    await runAsync(
      'INSERT INTO device_data (device_id, value, unit) VALUES (?, ?, ?)',
      [req.params.id, value, unit || null]
    );
    
    res.status(201).json({
      success: true,
      message: 'Data recorded',
      device_id: req.params.id,
      value,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('[API] Error recording data:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * GET /api/devices/:id/data - Get device data
 */
app.get('/api/devices/:id/data', async (req, res) => {
  try {
    const { limit = 100, offset = 0 } = req.query;
    
    const data = await allAsync(
      'SELECT * FROM device_data WHERE device_id = ? ORDER BY timestamp DESC LIMIT ? OFFSET ?',
      [req.params.id, parseInt(limit), parseInt(offset)]
    );
    
    res.json({
      success: true,
      data,
      count: data.length
    });
  } catch (error) {
    console.error('[API] Error fetching data:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================================
// Schedule Routes
// ============================================================================

/**
 * POST /api/schedules - Create schedule
 */
app.post('/api/schedules', async (req, res) => {
  try {
    const { device_id, action, time_of_day } = req.body;
    
    if (!device_id || !action || !time_of_day) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: device_id, action, time_of_day'
      });
    }
    
    const scheduleId = uuidv4();
    await runAsync(
      `INSERT INTO schedules (id, device_id, action, time_of_day) 
       VALUES (?, ?, ?, ?)`,
      [scheduleId, device_id, action, time_of_day]
    );
    
    const schedule = await getAsync('SELECT * FROM schedules WHERE id = ?', [scheduleId]);
    
    res.status(201).json({
      success: true,
      data: schedule,
      message: 'Schedule created'
    });
  } catch (error) {
    console.error('[API] Error creating schedule:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * GET /api/schedules/:id - Get schedules for device
 */
app.get('/api/schedules/device/:device_id', async (req, res) => {
  try {
    const schedules = await allAsync(
      'SELECT * FROM schedules WHERE device_id = ? ORDER BY time_of_day',
      [req.params.device_id]
    );
    
    res.json({
      success: true,
      data: schedules,
      count: schedules.length
    });
  } catch (error) {
    console.error('[API] Error fetching schedules:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================================
// Error Handling
// ============================================================================

app.use((err, req, res, next) => {
  console.error('[API] Unhandled error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: err.message
  });
});

// ============================================================================
// Start Server
// ============================================================================

app.listen(PORT, () => {
  console.log(`[Server] ✓ API listening on port ${PORT}`);
  console.log(`[Server] Health: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n[Server] Shutting down...');
  db.close((err) => {
    if (err) console.error('[DB] Close error:', err);
    else console.log('[DB] ✓ Database connection closed');
    process.exit(0);
  });
});
