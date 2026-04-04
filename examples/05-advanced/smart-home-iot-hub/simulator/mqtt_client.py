"""
MQTT Client Wrapper for Device Simulator
"""
import paho.mqtt.client as mqtt
import logging
import time
from typing import Callable, Optional

logger = logging.getLogger(__name__)

class SimpleMQTTClient:
    """Simple MQTT client wrapper for publishing device data"""
    
    def __init__(self, broker: str, port: int, client_id: str):
        self.broker = broker
        self.port = port
        self.client_id = client_id
        self.client = mqtt.Client(mqtt.CallbackAPIVersion.V1, client_id=client_id)
        self.is_connected = False
        
        # Set callbacks
        self.client.on_connect = self._on_connect
        self.client.on_disconnect = self._on_disconnect
        self.client.on_publish = self._on_publish
        
    def _on_connect(self, client, userdata, flags, rc):
        """Callback for when client connects to broker"""
        if rc == 0:
            logger.info(f"✓ Connected to MQTT broker at {self.broker}:{self.port}")
            self.is_connected = True
        else:
            logger.error(f"✗ Connection failed with code {rc}")
            self.is_connected = False
    
    def _on_disconnect(self, client, userdata, rc):
        """Callback for when client disconnects from broker"""
        logger.warning(f"✗ Disconnected from MQTT broker (code: {rc})")
        self.is_connected = False
    
    def _on_publish(self, client, userdata, mid):
        """Callback for when message is published"""
        pass  # Silently succeed
    
    def connect(self, max_retries: int = 5):
        """Connect to MQTT broker with retry logic"""
        retries = 0
        while retries < max_retries and not self.is_connected:
            try:
                logger.info(f"Connecting to MQTT broker ({retries + 1}/{max_retries})...")
                self.client.connect(self.broker, self.port, keepalive=60)
                self.client.loop_start()
                time.sleep(1)
                retries += 1
            except Exception as e:
                logger.error(f"Connection attempt failed: {e}")
                retries += 1
                time.sleep(2)
        
        if not self.is_connected:
            raise RuntimeError(f"Failed to connect to MQTT broker after {max_retries} retries")
    
    def publish(self, topic: str, payload: str, qos: int = 1) -> bool:
        """Publish message to MQTT topic"""
        if not self.is_connected:
            logger.warning(f"Not connected to broker. Skipping publish to {topic}")
            return False
        
        try:
            result = self.client.publish(topic, payload, qos=qos)
            if result.rc == mqtt.MQTT_ERR_SUCCESS:
                logger.debug(f"Published to {topic}: {payload}")
                return True
            else:
                logger.error(f"Publish failed to {topic}: {result.rc}")
                return False
        except Exception as e:
            logger.error(f"Error publishing to {topic}: {e}")
            return False
    
    def subscribe(self, topic: str, callback: Optional[Callable] = None) -> bool:
        """Subscribe to MQTT topic"""
        if callback:
            self.client.on_message = lambda c, ud, msg: callback(msg.topic, msg.payload.decode())
        
        try:
            result = self.client.subscribe(topic, qos=1)
            if result[0] == mqtt.MQTT_ERR_SUCCESS:
                logger.info(f"✓ Subscribed to {topic}")
                return True
            else:
                logger.error(f"Subscribe failed to {topic}: {result[0]}")
                return False
        except Exception as e:
            logger.error(f"Error subscribing to {topic}: {e}")
            return False
    
    def disconnect(self):
        """Disconnect from MQTT broker"""
        self.client.loop_stop()
        self.client.disconnect()
        logger.info("Disconnected from MQTT broker")
