"""
ユニットテスト - 設定管理（config.py）
"""

import pytest
import os
from src.config import (
    Config,
    MQTTConfig,
    DatabaseConfig,
    SensorConfig,
    AlarmConfig,
    FlaskConfig,
    LogConfig,
    get_config,
)


class TestMQTTConfig:
    """MQTT設定テスト"""
    
    def test_mqtt_config_default(self):
        """デフォルト設定の確認"""
        config = MQTTConfig()
        assert config.host == "localhost"
        assert config.port == 1883
        assert config.topic_prefix == "sensor"
        assert config.client_id == "iot_simulator_001"
    
    def test_mqtt_config_with_auth(self):
        """認証設定試験用"""
        config = MQTTConfig(username="test_user", password="test_pass")
        assert config.username == "test_user"
        assert config.password == "test_pass"


class TestSensorConfig:
    """センサー設定テスト"""
    
    def test_sensor_config_default(self):
        """デフォルト設定"""
        config = SensorConfig()
        assert config.interval == 5
        assert config.temp_min == 10.0
        assert config.temp_max == 35.0
        assert len(config.rooms) >= 1
    
    def test_sensor_config_rooms_parsing(self):
        """ルーム名パース"""
        os.environ["SENSOR_ROOMS"] = "room1,room2,room3"
        config = SensorConfig()
        assert config.rooms == ["room1", "room2", "room3"]


class TestAlarmConfig:
    """アラーム設定テスト"""
    
    def test_alarm_config_thresholds(self):
        """閾値確認"""
        config = AlarmConfig()
        assert config.temp_high == 30.0
        assert config.temp_low == 5.0
        assert config.humidity_high == 80.0
        assert config.humidity_low == 40.0


class TestMasterConfig:
    """マスター設定テスト"""
    
    def test_master_config_creation(self):
        """マスター設定作成"""
        config = Config()
        assert isinstance(config.mqtt, MQTTConfig)
        assert isinstance(config.database, DatabaseConfig)
        assert isinstance(config.sensor, SensorConfig)
        assert isinstance(config.alarm, AlarmConfig)
    
    def test_get_config_singleton(self):
        """シングルトン確認"""
        config1 = get_config()
        config2 = get_config()
        assert config1 is config2
    
    def test_config_to_dict(self):
        """辞書変換"""
        config = Config()
        config_dict = config.to_dict()
        assert "mqtt" in config_dict
        assert "database" in config_dict
        assert "sensor" in config_dict
        assert "alarm" in config_dict


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
