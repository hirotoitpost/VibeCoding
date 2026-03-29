"""
メインエントリーポイント - ID 011 IoT センサーシミュレーター

センサーシミュレーター + MQTT + DB + アラーム を統合実行
"""

import logging
import sys
import time
from typing import List

from src.config import get_config
from src.sensor_simulator import SensorSimulator
from src.mqtt_client import MQTTPublisher
from src.database import Database
from src.alarm_manager import create_default_alarm_manager

# ログ設定
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - [%(name)s] - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


class IoTSimulatorEngine:
    """
    統合 IoT シミュレーター エンジン
    """
    
    def __init__(self):
        """初期化"""
        self.config = get_config()
        
        logger.info("=" * 60)
        logger.info("🚀 IoT Sensor Simulator Engine - Initialization")
        logger.info("=" * 60)
        
        # コンポーネント初期化
        self._init_sensor_simulator()
        self._init_mqtt()
        self._init_database()
        self._init_alarm_manager()
        
        logger.info("✅ All components initialized")
    
    def _init_sensor_simulator(self):
        """センサーシミュレーター初期化"""
        try:
            self.sensor_simulator = SensorSimulator(
                sensor_ids=self.config.sensor.rooms,
                temp_min=self.config.sensor.temp_min,
                temp_max=self.config.sensor.temp_max,
                humidity_min=self.config.sensor.humidity_min,
                humidity_max=self.config.sensor.humidity_max,
                temp_variance=self.config.sensor.temp_variance,
                humidity_variance=self.config.sensor.humidity_variance,
            )
            logger.info(
                f"✓ Sensor Simulator: {len(self.config.sensor.rooms)} sensors"
            )
        except Exception as e:
            logger.error(f"Failed to initialize sensor simulator: {e}")
            raise
    
    def _init_mqtt(self):
        """MQTT クライアント初期化"""
        try:
            self.mqtt_publisher = MQTTPublisher(
                broker_host=self.config.mqtt.host,
                broker_port=self.config.mqtt.port,
                username=self.config.mqtt.username,
                password=self.config.mqtt.password,
                topic_prefix=self.config.mqtt.topic_prefix,
                client_id=self.config.mqtt.client_id,
            )
            self.mqtt_publisher.connect()
            logger.info(
                f"✓ MQTT Publisher: {self.config.mqtt.host}: "
                f"{self.config.mqtt.port}"
            )
        except Exception as e:
            logger.error(f"Failed to initialize MQTT: {e}")
            raise
    
    def _init_database(self):
        """データベース初期化"""
        try:
            self.database = Database(
                database_url=self.config.database.url,
                echo=self.config.database.echo,
            )
            logger.info(f"✓ Database: {self.config.database.db_type}")
        except Exception as e:
            logger.error(f"Failed to initialize database: {e}")
            raise
    
    def _init_alarm_manager(self):
        """アラームマネージャー初期化"""
        try:
            self.alarm_manager = create_default_alarm_manager(
                temp_high=self.config.alarm.temp_high,
                temp_low=self.config.alarm.temp_low,
                humidity_high=self.config.alarm.humidity_high,
                humidity_low=self.config.alarm.humidity_low,
                notify_interval=self.config.alarm.notify_interval,
            )
            
            # アラームコールバック: MQTT パブリッシュ + DB保存
            def on_alarm(alarm_dict):
                try:
                    # MQTT パブリッシュ
                    self.mqtt_publisher.publish_alarm(alarm_dict)
                    
                    # DB 保存
                    self.database.save_alarm(
                        sensor_id=alarm_dict["sensor_id"],
                        alarm_type=alarm_dict["alarm_type"],
                        value=alarm_dict["value"],
                        threshold=alarm_dict["threshold"],
                        message=alarm_dict["message"],
                    )
                except Exception as e:
                    logger.error(f"Error in alarm handler: {e}")
            
            self.alarm_manager.add_callback(on_alarm)
            logger.info("✓ Alarm Manager initialized")
        except Exception as e:
            logger.error(f"Failed to initialize alarm manager: {e}")
            raise
    
    def run(self):
        """実行"""
        logger.info("=" * 60)
        logger.info("🎬 Starting IoT Simulator Engine")
        logger.info("=" * 60)
        
        try:
            # センサーシミュレーター起動
            def on_readings(readings: List):
                """センサー読取時のコールバック"""
                for reading in readings:
                    # DB 保存
                    try:
                        self.database.save_reading(
                            sensor_id=reading.sensor_id,
                            room=reading.room,
                            temperature=reading.temperature,
                            humidity=reading.humidity,
                            timestamp=reading.timestamp,
                        )
                    except Exception as e:
                        logger.error(f"Failed to save reading: {e}")
                    
                    # MQTT パブリッシュ
                    try:
                        self.mqtt_publisher.publish_reading(
                            reading.room,
                            reading.to_dict(),
                        )
                    except Exception as e:
                        logger.error(f"Failed to publish reading: {e}")
                    
                    # アラーム判定
                    try:
                        self.alarm_manager.check_and_trigger(
                            sensor_id=reading.sensor_id,
                            temperature=reading.temperature,
                            humidity=reading.humidity,
                        )
                    except Exception as e:
                        logger.error(f"Failed to check alarm: {e}")
                    
                    # ログ出力
                    logger.debug(f"📊 {reading}")
            
            self.sensor_simulator.start(
                interval=self.config.sensor.interval,
                callback=on_readings,
            )
            
            logger.info("✅ Engine running. Press Ctrl+C to stop.")
            logger.info("=" * 60)
            
            # メインループ（Ctrl+C まで実行継続）
            while True:
                time.sleep(1)
        
        except KeyboardInterrupt:
            logger.info("\n🛑 Keyboard interrupt received")
        except Exception as e:
            logger.error(f"Error in main loop: {e}")
            raise
        finally:
            self.shutdown()
    
    def shutdown(self):
        """シャットダウン"""
        logger.info("=" * 60)
        logger.info("🔌 Shutting down IoT Simulator Engine")
        logger.info("=" * 60)
        
        # センサーシミュレーター停止
        try:
            self.sensor_simulator.stop()
            logger.info("✓ Sensor Simulator stopped")
        except Exception as e:
            logger.error(f"Error stopping sensor simulator: {e}")
        
        # MQTT 切断
        try:
            self.mqtt_publisher.disconnect()
            logger.info("✓ MQTT Publisher disconnected")
        except Exception as e:
            logger.error(f"Error disconnecting MQTT: {e}")
        
        # 古いデータ削除
        try:
            self.database.cleanup_old_data(days=30)
            logger.info("✓ Database cleanup completed")
        except Exception as e:
            logger.error(f"Error cleaning up database: {e}")
        
        logger.info("✅ Shutdown complete")
        logger.info("=" * 60)


def main():
    """メイン関数"""
    try:
        engine = IoTSimulatorEngine()
        engine.run()
    except Exception as e:
        logger.error(f"Fatal error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
