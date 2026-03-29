"""
MQTT クライアント モジュル - パブリッシャー/サブスクライバー

MQTT ブローカーとの通信を管理
"""

import json
import logging
from typing import Callable, Optional, Dict, Any
import paho.mqtt.client as mqtt
from threading import Thread, Event
import time

logger = logging.getLogger(__name__)


class MQTTPublisher:
    """
    MQTT パブリッシャー - センサーデータをパブリッシュ
    """
    
    def __init__(
        self,
        broker_host: str = "localhost",
        broker_port: int = 1883,
        username: Optional[str] = None,
        password: Optional[str] = None,
        topic_prefix: str = "sensor",
        client_id: str = "iot_simulator_pub",
        keepalive: int = 60,
        qos: int = 1,
    ):
        """
        初期化
        
        Args:
            broker_host: MQTT ブローカーホスト
            broker_port: MQTT ブローカーポート
            username: 認証ユーザー名
            password: 認証パスワード
            topic_prefix: トピックプリフィックス
            client_id: クライアントID
            keepalive: キープアライブ間隔（秒）
            qos: QoS レベル（0, 1, 2）
        """
        self.broker_host = broker_host
        self.broker_port = broker_port
        self.topic_prefix = topic_prefix
        self.qos = qos
        
        # MQTT クライアント作成
        self.client = mqtt.Client(client_id=client_id, protocol=mqtt.MQTTv311)
        self.client.on_connect = self._on_connect
        self.client.on_disconnect = self._on_disconnect
        self.client.on_publish = self._on_publish
        self.client.on_log = self._on_log
        
        # 認証設定
        if username and password:
            self.client.username_pw_set(username, password)
        
        self._connected = False
        
        logger.info(
            f"MQTT Publisher initialized: "
            f"{broker_host}:{broker_port} (topic_prefix={topic_prefix})"
        )
    
    def _on_connect(self, client, userdata, flags, rc):
        """接続時コールバック"""
        if rc == 0:
            self._connected = True
            logger.info(f"MQTT connected: rc={rc}")
        else:
            logger.error(f"MQTT connection failed: rc={rc}")
    
    def _on_disconnect(self, client, userdata, rc):
        """切断時コールバック"""
        self._connected = False
        logger.warning(f"MQTT disconnected: rc={rc}")
    
    def _on_publish(self, client, userdata, mid):
        """パブリッシュ完了時コールバック"""
        logger.debug(f"Message published: mid={mid}")
    
    def _on_log(self, client, userdata, level, buf):
        """MQTT ライブログ"""
        if level == mqtt.MQTT_LOG_DEBUG:
            logger.debug(f"MQTT: {buf}")
    
    def connect(self):
        """ブローカーに接続"""
        try:
            self.client.connect(self.broker_host, self.broker_port, keepalive=60)
            self.client.loop_start()
            time.sleep(1)  # 接続完了待機
            logger.info("MQTT Publisher connected")
        except Exception as e:
            logger.error(f"Failed to connect MQTT: {e}")
            raise
    
    def disconnect(self):
        """ブローカーから切断"""
        self.client.loop_stop()
        self.client.disconnect()
        logger.info("MQTT Publisher disconnected")
    
    def publish_reading(self, sensor_id: str, reading_dict: dict):
        """
        センサーデータをパブリッシュ
        
        トピック: sensor/{sensor_type}/{sensor_id}
        
        Args:
            sensor_id: センサーID（例：room1）
            reading_dict: 計測値辞書（temperature, humidity, timestamp等）
        """
        if not self._connected:
            logger.warning("MQTT not connected, skipping publish")
            return
        
        # 温度と湿度を別トピックでパブリッシュ
        payload_temp = {
            "sensor_id": sensor_id,
            "value": reading_dict.get("temperature"),
            "unit": "celsius",
            "timestamp": reading_dict.get("timestamp"),
        }
        
        payload_humidity = {
            "sensor_id": sensor_id,
            "value": reading_dict.get("humidity"),
            "unit": "%",
            "timestamp": reading_dict.get("timestamp"),
        }
        
        topic_temp = f"{self.topic_prefix}/temperature/{sensor_id}"
        topic_humidity = f"{self.topic_prefix}/humidity/{sensor_id}"
        
        try:
            self.client.publish(
                topic_temp,
                json.dumps(payload_temp),
                qos=self.qos,
            )
            self.client.publish(
                topic_humidity,
                json.dumps(payload_humidity),
                qos=self.qos,
            )
            
            logger.debug(
                f"Published: {topic_temp}, {topic_humidity}"
            )
        except Exception as e:
            logger.error(f"Failed to publish: {e}")
    
    def publish_alarm(self, alarm_dict: dict):
        """
        アラームをパブリッシュ
        
        Args:
            alarm_dict: アラーム情報辞書
        """
        if not self._connected:
            logger.warning("MQTT not connected, skipping alarm")
            return
        
        topic = f"{self.topic_prefix}/alarm"
        
        try:
            self.client.publish(
                topic,
                json.dumps(alarm_dict),
                qos=1,
            )
            logger.info(f"Alarm published: {alarm_dict}")
        except Exception as e:
            logger.error(f"Failed to publish alarm: {e}")
    
    def is_connected(self) -> bool:
        """接続状態を返す"""
        return self._connected


class MQTTSubscriber:
    """
    MQTT サブスクライバー - センサーデータまたはコマンドをサブスクライブ
    """
    
    def __init__(
        self,
        broker_host: str = "localhost",
        broker_port: int = 1883,
        username: Optional[str] = None,
        password: Optional[str] = None,
        client_id: str = "iot_simulator_sub",
        keepalive: int = 60,
    ):
        """初期化"""
        self.broker_host = broker_host
        self.broker_port = broker_port
        
        self.client = mqtt.Client(client_id=client_id, protocol=mqtt.MQTTv311)
        self.client.on_connect = self._on_connect
        self.client.on_disconnect = self._on_disconnect
        self.client.on_message = self._on_message
        
        if username and password:
            self.client.username_pw_set(username, password)
        
        self._connected = False
        self._message_callbacks: Dict[str, Callable] = {}
        
        logger.info(
            f"MQTT Subscriber initialized: {broker_host}:{broker_port}"
        )
    
    def _on_connect(self, client, userdata, flags, rc):
        """接続時コールバック"""
        if rc == 0:
            self._connected = True
            logger.info("MQTT Subscriber connected")
        else:
            logger.error(f"MQTT connection failed: rc={rc}")
    
    def _on_disconnect(self, client, userdata, rc):
        """切断時コールバック"""
        self._connected = False
        logger.warning(f"MQTT Subscriber disconnected: rc={rc}")
    
    def _on_message(self, client, userdata, msg):
        """メッセージ受信時コールバック"""
        topic = msg.topic
        payload = msg.payload.decode("utf-8")
        
        logger.debug(f"Message received on {topic}: {payload}")
        
        # トピックに登録されているコールバックを実行
        if topic in self._message_callbacks:
            try:
                data = json.loads(payload)
                self._message_callbacks[topic](data)
            except Exception as e:
                logger.error(f"Error processing message: {e}")
    
    def connect(self):
        """ブローカーに接続"""
        try:
            self.client.connect(self.broker_host, self.broker_port, keepalive=60)
            self.client.loop_start()
            time.sleep(1)
            logger.info("MQTT Subscriber connected")
        except Exception as e:
            logger.error(f"Failed to connect: {e}")
            raise
    
    def disconnect(self):
        """切断"""
        self.client.loop_stop()
        self.client.disconnect()
        logger.info("MQTT Subscriber disconnected")
    
    def subscribe(self, topic: str, callback: Callable):
        """
        トピックをサブスクライブ
        
        Args:
            topic: MQTT トピック（ワイルドカード対応）
            callback: メッセージ受信時のコールバック
        """
        try:
            self.client.subscribe(topic, qos=1)
            self._message_callbacks[topic] = callback
            logger.info(f"Subscribed to: {topic}")
        except Exception as e:
            logger.error(f"Failed to subscribe: {e}")
    
    def unsubscribe(self, topic: str):
        """トピックをアンサブスクライブ"""
        try:
            self.client.unsubscribe(topic)
            if topic in self._message_callbacks:
                del self._message_callbacks[topic]
            logger.info(f"Unsubscribed from: {topic}")
        except Exception as e:
            logger.error(f"Failed to unsubscribe: {e}")
    
    def is_connected(self) -> bool:
        """接続状態を返す"""
        return self._connected


# デバッグ実行
if __name__ == "__main__":
    import logging
    
    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s - %(levelname)s - %(message)s",
    )
    
    # パブリッシャーをテスト
    pub = MQTTPublisher()
    try:
        pub.connect()
        
        # テストデータをパブリッシュ
        test_reading = {
            "temperature": 25.5,
            "humidity": 65.0,
            "timestamp": "2026-03-29T12:00:00",
        }
        pub.publish_reading("room1", test_reading)
        
        time.sleep(2)
    finally:
        pub.disconnect()
