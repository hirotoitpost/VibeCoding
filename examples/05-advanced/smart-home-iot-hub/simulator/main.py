"""
Main entry point for Smart Home IoT Hub Device Simulator
"""
import logging
import sys
from simulator.config import mqtt_config, device_config, sim_config
from simulator.mqtt_client import SimpleMQTTClient
from simulator.device_simulator import (
    DeviceSimulator, TemperatureSensor, HumiditySensor, SmartSwitch
)

# Configure logging
logging.basicConfig(
    level=getattr(logging, sim_config.LOG_LEVEL, "INFO"),
    format="[%(asctime)s] %(levelname)-8s [%(name)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)

logger = logging.getLogger(__name__)

def main():
    """Main function - Initialize and start simulator"""
    
    try:
        # Initialize MQTT client
        logger.info("🌐 Initializing MQTT client...")
        mqtt_client = SimpleMQTTClient(
            broker=mqtt_config.broker,
            port=mqtt_config.port,
            client_id=mqtt_config.client_id
        )
        
        # Connect to broker
        logger.info("🔗 Connecting to MQTT broker...")
        mqtt_client.connect()
        
        # Initialize simulator
        logger.info("🏠 Initializing device simulator...")
        simulator = DeviceSimulator(mqtt_client)
        
        # Register devices
        logger.info("📱 Registering IoT devices...")
        simulator.add_device(TemperatureSensor(
            min_temp=device_config.TEMP_MIN,
            max_temp=device_config.TEMP_MAX,
            change_rate=device_config.TEMP_CHANGE_RATE
        ))
        simulator.add_device(HumiditySensor(
            min_hum=device_config.HUMIDITY_MIN,
            max_hum=device_config.HUMIDITY_MAX,
            change_rate=device_config.HUMIDITY_CHANGE_RATE
        ))
        simulator.add_device(SmartSwitch("Living Room Light", device_config.LIGHT_SWITCH_TOPIC))
        simulator.add_device(SmartSwitch("AC", device_config.AC_TOPIC))
        
        logger.info(f"✓ Registered {len(simulator.devices)} devices")
        
        # Start simulation
        logger.info("▶ Starting simulation...")
        logger.info(f"  MQTT Broker: {mqtt_config.broker}:{mqtt_config.port}")
        logger.info(f"  Update interval: {sim_config.UPDATE_INTERVAL}s")
        
        simulator.run(update_interval=sim_config.UPDATE_INTERVAL)
        
    except KeyboardInterrupt:
        logger.info("⏹ Interrupted by user")
        sys.exit(0)
    except Exception as e:
        logger.error(f"❌ Fatal error: {e}", exc_info=True)
        sys.exit(1)
    finally:
        logger.info("🛑 Shutting down...")

if __name__ == "__main__":
    main()
