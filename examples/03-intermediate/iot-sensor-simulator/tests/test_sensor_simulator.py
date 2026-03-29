"""
ユニットテスト - センサーシミュレーター（sensor_simulator.py）
"""

import pytest
import time
from src.sensor_simulator import SensorSimulator, SensorReading


class TestSensorReading:
    """SensorReading テスト"""
    
    def test_sensor_reading_creation(self):
        """計測値オブジェクト作成"""
        from datetime import datetime
        
        reading = SensorReading(
            sensor_id="sensor_room1",
            room="room1",
            temperature=25.5,
            humidity=60.0,
            timestamp=datetime.now(),
        )
        
        assert reading.sensor_id == "sensor_room1"
        assert reading.room == "room1"
        assert reading.temperature == 25.5
        assert reading.humidity == 60.0
    
    def test_sensor_reading_to_dict(self):
        """辞書変換"""
        from datetime import datetime
        
        reading = SensorReading(
            sensor_id="sensor_room1",
            room="room1",
            temperature=25.5,
            humidity=60.0,
            timestamp=datetime.now(),
        )
        
        reading_dict = reading.to_dict()
        assert reading_dict["sensor_id"] == "sensor_room1"
        assert reading_dict["temperature"] == 25.5
        assert reading_dict["humidity"] == 60.0


class TestSensorSimulator:
    """SensorSimulator テスト"""
    
    def test_simulator_creation(self):
        """シミュレーター作成"""
        simulator = SensorSimulator(
            sensor_ids=["room1", "room2"],
            temp_min=15,
            temp_max=25,
        )
        
        assert len(simulator.sensor_ids) == 2
        assert simulator.temp_min == 15
        assert simulator.temp_max == 25
    
    def test_generate_single_reading(self):
        """単一計測値生成"""
        simulator = SensorSimulator(
            sensor_ids=["room1"],
            temp_min=20,
            temp_max=20.1,  # ほぼ固定値
            humidity_min=50,
            humidity_max=50.1,
        )
        
        reading = simulator.generate_reading("room1")
        assert reading.sensor_id == "sensor_room1"
        assert reading.room == "room1"
        assert 20.0 <= reading.temperature <= 20.1
        assert 50.0 <= reading.humidity <= 50.1
    
    def test_generate_all_readings(self):
        """全計測値生成"""
        simulator = SensorSimulator(
            sensor_ids=["room1", "room2", "room3"],
        )
        
        readings = simulator.generate_all_readings()
        assert len(readings) == 3
        
        rooms = [r.room for r in readings]
        assert "room1" in rooms
        assert "room2" in rooms
        assert "room3" in rooms
    
    def test_continuous_variation(self):
        """連続的な値の変動確認"""
        simulator = SensorSimulator(
            sensor_ids=["room1"],
            temp_min=15,
            temp_max=30,
            temp_variance=1.0,
        )
        
        # 複数回連続生成
        readings = []
        for _ in range(5):
            reading = simulator.generate_reading("room1")
            readings.append(reading.temperature)
        
        # 温度が変動していることを確認
        assert len(set(readings)) > 1, "温度が変動していない"
    
    def test_start_and_stop(self):
        """起動・停止テスト"""
        simulator = SensorSimulator(sensor_ids=["room1"])
        
        # 起動
        readings_list = []
        def collect_readings(readings):
            readings_list.extend(readings)
        
        simulator.start(interval=1, callback=collect_readings)
        assert simulator.is_running(), "シミュレーター起動失敗"
        
        # 3秒待機
        time.sleep(3)
        
        # 停止
        simulator.stop(timeout=5)
        assert not simulator.is_running(), "シミュレーター停止失敗"
        assert len(readings_list) > 0, "データが生成されていない"
    
    def test_get_current_values(self):
        """現在値取得"""
        simulator = SensorSimulator(sensor_ids=["room1", "room2"])
        
        temp, humidity = simulator.get_current_values("room1")
        assert isinstance(temp, float)
        assert isinstance(humidity, float)
    
    def test_get_all_current_values(self):
        """全センサー現在値取得"""
        simulator = SensorSimulator(sensor_ids=["room1", "room2"])
        
        all_values = simulator.get_all_current_values()
        assert len(all_values) == 2
        assert "room1" in all_values
        assert "room2" in all_values


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
