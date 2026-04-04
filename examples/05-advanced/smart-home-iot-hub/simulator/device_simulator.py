"""
IoT Device Simulator - Generates and publishes simulated sensor data
"""
import logging
import json
import time
import random
from datetime import datetime
from typing import Dict, Any

logger = logging.getLogger(__name__)

class SmartHomeDevice:
    """Represents a single simulated IoT device"""
    
    def __init__(self, device_id: str, device_type: str, topic: str, initial_value: Any = None):
        self.device_id = device_id
        self.device_type = device_type
        self.topic = topic
        self.current_value = initial_value
        self.is_active = True
        self.last_update = datetime.now()
    
    def update(self) -> Dict[str, Any]:
        """Generate new sensor data and return as payload"""
        raise NotImplementedError
    
    def get_payload(self) -> str:
        """Get JSON payload for MQTT"""
        data = self.update()
        return json.dumps(data)

class TemperatureSensor(SmartHomeDevice):
    """Simulated temperature sensor with realistic drift"""
    
    def __init__(self, min_temp: float = 15.0, max_temp: float = 30.0, change_rate: float = 0.2):
        super().__init__("temp-sensor-01", "temperature_sensor", "home/sensors/living_room/temperature", 22.0)
        self.min_temp = min_temp
        self.max_temp = max_temp
        self.change_rate = change_rate
    
    def update(self) -> Dict[str, Any]:
        """Simulate temperature with random walk"""
        if self.current_value is None:
            self.current_value = (self.min_temp + self.max_temp) / 2
        
        # Random walk with drift
        change = random.uniform(-self.change_rate, self.change_rate)
        new_value = self.current_value + change
        
        # Clamp to min/max
        self.current_value = max(self.min_temp, min(self.max_temp, new_value))
        
        return {
            "device_id": self.device_id,
            "type": self.device_type,
            "value": round(self.current_value, 2),
            "unit": "°C",
            "timestamp": datetime.now().isoformat(),
            "is_active": self.is_active
        }

class HumiditySensor(SmartHomeDevice):
    """Simulated humidity sensor"""
    
    def __init__(self, min_hum: float = 30.0, max_hum: float = 80.0, change_rate: float = 0.5):
        super().__init__("hum-sensor-01", "humidity_sensor", "home/sensors/living_room/humidity", 55.0)
        self.min_hum = min_hum
        self.max_hum = max_hum
        self.change_rate = change_rate
    
    def update(self) -> Dict[str, Any]:
        """Simulate humidity with random walk"""
        if self.current_value is None:
            self.current_value = (self.min_hum + self.max_hum) / 2
        
        # Random walk with drift
        change = random.uniform(-self.change_rate, self.change_rate)
        new_value = self.current_value + change
        
        # Clamp to min/max
        self.current_value = max(self.min_hum, min(self.max_hum, new_value))
        
        return {
            "device_id": self.device_id,
            "type": self.device_type,
            "value": round(self.current_value, 1),
            "unit": "%",
            "timestamp": datetime.now().isoformat(),
            "is_active": self.is_active
        }

class SmartSwitch(SmartHomeDevice):
    """Simulated smart switch (ON/OFF)"""
    
    def __init__(self, label: str, topic: str):
        super().__init__(f"switch-{label}".lower(), "switch", topic, False)
        self.label = label
    
    def update(self) -> Dict[str, Any]:
        """Return current switch state"""
        return {
            "device_id": self.device_id,
            "type": self.device_type,
            "label": self.label,
            "state": "ON" if self.current_value else "OFF",
            "is_active": self.is_active,
            "timestamp": datetime.now().isoformat()
        }
    
    def toggle(self):
        """Toggle switch state"""
        self.current_value = not self.current_value
        logger.info(f"Toggled {self.label}: {self.current_value}")

class DeviceSimulator:
    """Main simulator orchestrating multiple devices"""
    
    def __init__(self, mqtt_client):
        self.mqtt_client = mqtt_client
        self.devices: Dict[str, SmartHomeDevice] = {}
        self.running = False
    
    def add_device(self, device: SmartHomeDevice):
        """Register a device"""
        self.devices[device.device_id] = device
        logger.info(f"Registered device: {device.device_id} ({device.device_type})")
    
    def publish_device_data(self, device_id: str) -> bool:
        """Publish a single device's data"""
        if device_id not in self.devices:
            logger.warning(f"Device {device_id} not found")
            return False
        
        device = self.devices[device_id]
        if not device.is_active:
            return False
        
        payload = device.get_payload()
        return self.mqtt_client.publish(device.topic, payload)
    
    def publish_all_devices(self) -> int:
        """Publish data from all active devices"""
        count = 0
        for device_id, device in self.devices.items():
            if self.publish_device_data(device_id):
                count += 1
        return count
    
    def run(self, update_interval: int = 5):
        """Main simulation loop"""
        self.running = True
        logger.info(f"▶ Starting simulator with {len(self.devices)} devices (interval: {update_interval}s)")
        
        try:
            while self.running:
                published = self.publish_all_devices()
                if published > 0:
                    logger.debug(f"Published {published} device updates")
                time.sleep(update_interval)
        except KeyboardInterrupt:
            logger.info("Received interrupt signal")
        except Exception as e:
            logger.error(f"Simulator error: {e}")
        finally:
            self.stop()
    
    def stop(self):
        """Stop the simulator"""
        self.running = False
        logger.info("Simulator stopped")
    
    def get_device_list(self) -> Dict[str, Dict[str, Any]]:
        """Get list of all registered devices"""
        result = {}
        for device_id, device in self.devices.items():
            result[device_id] = {
                "type": device.device_type,
                "topic": device.topic,
                "active": device.is_active,
                "current_value": device.current_value
            }
        return result
