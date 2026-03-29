"""
設定管理モジュル - IoT センサーシミュレーター
環境変数から設定を読み込む
"""

import os
from typing import Optional
from dataclasses import dataclass
from functools import lru_cache
from dotenv import load_dotenv

# .env ファイルを読み込む
load_dotenv()


@dataclass
class MQTTConfig:
    """MQTT ブローカー設定"""
    host: str = os.getenv("MQTT_BROKER_HOST", "localhost")
    port: int = int(os.getenv("MQTT_BROKER_PORT", "1883"))
    username: Optional[str] = os.getenv("MQTT_USERNAME")
    password: Optional[str] = os.getenv("MQTT_PASSWORD")
    topic_prefix: str = os.getenv("MQTT_TOPIC_PREFIX", "sensor")
    client_id: str = os.getenv("MQTT_CLIENT_ID", "iot_simulator_001")
    keepalive: int = 60
    qos: int = 1


@dataclass
class DatabaseConfig:
    """データベース設定"""
    db_type: str = os.getenv("DATABASE_TYPE", "sqlite")
    url: str = os.getenv("DATABASE_URL", "sqlite:///sensor_data.db")
    echo: bool = os.getenv("DATABASE_ECHO", "false").lower() == "true"
    poolsize: int = 5
    max_overflow: int = 10


@dataclass
class SensorConfig:
    """センサーシミュレーション設定"""
    interval: int = int(os.getenv("SENSOR_INTERVAL", "5"))
    count: int = int(os.getenv("SENSOR_COUNT", "3"))
    rooms: list = None
    
    temp_min: float = float(os.getenv("TEMP_MIN", "10"))
    temp_max: float = float(os.getenv("TEMP_MAX", "35"))
    temp_variance: float = float(os.getenv("TEMP_VARIANCE", "2.0"))
    
    humidity_min: float = float(os.getenv("HUMIDITY_MIN", "20"))
    humidity_max: float = float(os.getenv("HUMIDITY_MAX", "95"))
    humidity_variance: float = float(os.getenv("HUMIDITY_VARIANCE", "5.0"))
    
    def __post_init__(self):
        """ルーム名をパース"""
        if self.rooms is None:
            rooms_str = os.getenv("SENSOR_ROOMS", "room1,room2,room3")
            self.rooms = [r.strip() for r in rooms_str.split(",")]


@dataclass
class AlarmConfig:
    """アラーム設定"""
    temp_high: float = float(os.getenv("ALARM_TEMP_HIGH", "30"))
    temp_low: float = float(os.getenv("ALARM_TEMP_LOW", "5"))
    humidity_high: float = float(os.getenv("ALARM_HUMIDITY_HIGH", "80"))
    humidity_low: float = float(os.getenv("ALARM_HUMIDITY_LOW", "40"))
    notify_interval: int = int(os.getenv("ALARM_NOTIFY_INTERVAL", "60"))


@dataclass
class FlaskConfig:
    """Flask 設定"""
    env: str = os.getenv("FLASK_ENV", "development")
    debug: bool = os.getenv("FLASK_DEBUG", "false").lower() == "true"
    host: str = os.getenv("FLASK_HOST", "0.0.0.0")
    port: int = int(os.getenv("FLASK_PORT", "5000"))
    secret_key: str = os.getenv("SECRET_KEY", "dev-secret-key")
    testing: bool = False


@dataclass
class LogConfig:
    """ログ設定"""
    level: str = os.getenv("LOG_LEVEL", "INFO")
    file: str = os.getenv("LOG_FILE", "logs/iot_simulator.log")
    format: str = os.getenv(
        "LOG_FORMAT",
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )


class Config:
    """マスター設定クラス"""
    
    def __init__(self):
        self.mqtt = MQTTConfig()
        self.database = DatabaseConfig()
        self.sensor = SensorConfig()
        self.alarm = AlarmConfig()
        self.flask = FlaskConfig()
        self.log = LogConfig()
        
    def __repr__(self) -> str:
        return (
            f"Config(\n"
            f"  mqtt={self.mqtt},\n"
            f"  database={self.database},\n"
            f"  sensor={self.sensor},\n"
            f"  alarm={self.alarm},\n"
            f"  flask={self.flask},\n"
            f"  log={self.log}\n"
            f")"
        )
    
    def to_dict(self) -> dict:
        """辞書形式で取得"""
        return {
            "mqtt": self.mqtt.__dict__,
            "database": self.database.__dict__,
            "sensor": self.sensor.__dict__,
            "alarm": self.alarm.__dict__,
            "flask": self.flask.__dict__,
            "log": self.log.__dict__,
        }


@lru_cache(maxsize=1)
def get_config() -> Config:
    """シングルトンパターンで Config を取得"""
    return Config()


# 起動時のデバッグ出力用
if __name__ == "__main__":
    config = get_config()
    print("=== IoT Simulator Configuration ===")
    print(config)
