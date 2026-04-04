"""
Configuration and Constants for Device Simulator
"""
import os
from dataclasses import dataclass

@dataclass
class MQTTConfig:
    """MQTT Broker Configuration"""
    broker: str = os.getenv("MQTT_BROKER", "localhost")
    port: int = int(os.getenv("MQTT_PORT", "1883"))
    keepalive: int = 60
    client_id: str = "device-simulator"
    clean_session: bool = True

@dataclass
class DeviceConfig:
    """Simulated Device Configuration"""
    # Temperature Sensor
    TEMP_SENSOR_TOPIC: str = "home/sensors/living_room/temperature"
    TEMP_MIN: float = 15.0
    TEMP_MAX: float = 30.0
    TEMP_CHANGE_RATE: float = 0.2  # degrees per update
    
    # Humidity Sensor
    HUMIDITY_SENSOR_TOPIC: str = "home/sensors/living_room/humidity"
    HUMIDITY_MIN: float = 30.0
    HUMIDITY_MAX: float = 80.0
    HUMIDITY_CHANGE_RATE: float = 0.5  # percentage per update
    
    # Light Switch
    LIGHT_SWITCH_TOPIC: str = "home/lights/living_room"
    LIGHT_DEFAULT_STATE: bool = False
    
    # AC Control
    AC_TOPIC: str = "home/ac/living_room"
    AC_DEFAULT_STATE: bool = False
    AC_DEFAULT_TEMP: float = 22.0

class SimulationConfig:
    """Simulation Runtime Configuration"""
    UPDATE_INTERVAL: int = 5  # seconds
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    DATABASE_PATH: str = os.getenv("DB_PATH", "./data/simulator.db")

# Singleton instances
mqtt_config = MQTTConfig()
device_config = DeviceConfig()
sim_config = SimulationConfig()
