"""
ユニットテスト - アラーム管理（alarm_manager.py）
"""

import pytest
import time
from src.alarm_manager import AlarmRule, AlarmManager, create_default_alarm_manager


class TestAlarmRule:
    """AlarmRule テスト"""
    
    def test_high_temp_rule(self):
        """高温アラームルール"""
        rule = AlarmRule(
            alarm_type="high_temp",
            sensor_param="temperature",
            threshold=30.0,
            direction="high",
            message_template="Temperature too high: {value}°C",
        )
        
        assert rule.check(29.9) is False
        assert rule.check(30.0) is True
        assert rule.check(31.0) is True
    
    def test_low_humidity_rule(self):
        """低湿度アラームルール"""
        rule = AlarmRule(
            alarm_type="low_humidity",
            sensor_param="humidity",
            threshold=40.0,
            direction="low",
            message_template="Humidity too low: {value}%",
        )
        
        assert rule.check(40.1) is False
        assert rule.check(40.0) is True
        assert rule.check(39.0) is True
    
    def test_message_format(self):
        """メッセージ生成"""
        rule = AlarmRule(
            alarm_type="test",
            sensor_param="temperature",
            threshold=30.0,
            direction="high",
            message_template="Sensor {sensor_id}: {value}°C (threshold: {threshold}°C)",
        )
        
        message = rule.format_message("room1", 35.5)
        assert "room1" in message
        assert "35.5" in message
        assert "30.0" in message


class TestAlarmManager:
    """AlarmManager テスト"""
    
    def test_manager_creation(self):
        """マネージャー作成"""
        manager = AlarmManager(notify_interval=60)
        assert manager.notify_interval == 60
        assert len(manager.rules) == 0
    
    def test_add_rule(self):
        """ルール追加"""
        manager = AlarmManager()
        rule = AlarmRule(
            alarm_type="test",
            sensor_param="temperature",
            threshold=30.0,
            direction="high",
            message_template="Test alarm",
        )
        
        manager.add_rule(rule)
        assert len(manager.rules) == 1
    
    def test_trigger_alarm(self):
        """アラーム発火"""
        manager = AlarmManager()
        rule = AlarmRule(
            alarm_type="high_temp",
            sensor_param="temperature",
            threshold=30.0,
            direction="high",
            message_template="High temp: {value}°C",
        )
        manager.add_rule(rule)
        
        # アラーム発火
        alarms = manager.check_and_trigger("room1", 35.0, 60.0)
        assert len(alarms) == 1
        assert alarms[0]["alarm_type"] == "high_temp"
        assert alarms[0]["value"] == 35.0
    
    def test_deduplication(self):
        """デダップリング（アラーム抑制）"""
        manager = AlarmManager(notify_interval=1)  # 1秒
        rule = AlarmRule(
            alarm_type="high_temp",
            sensor_param="temperature",
            threshold=30.0,
            direction="high",
            message_template="High temp",
        )
        manager.add_rule(rule)
        
        # 1回目: アラーム発火
        alarms1 = manager.check_and_trigger("room1", 35.0, 60.0)
        assert len(alarms1) == 1
        
        # 2回目: デダップリングで抑制
        alarms2 = manager.check_and_trigger("room1", 35.0, 60.0)
        assert len(alarms2) == 0  # 抑制された
        
        # 1秒待機後: アラーム発火
        time.sleep(1.1)
        alarms3 = manager.check_and_trigger("room1", 35.0, 60.0)
        assert len(alarms3) == 1
    
    def test_callback(self):
        """コールバック実行"""
        manager = AlarmManager()
        rule = AlarmRule(
            alarm_type="high_temp",
            sensor_param="temperature",
            threshold=30.0,
            direction="high",
            message_template="High temp",
        )
        manager.add_rule(rule)
        
        # コールバック登録
        callback_data = []
        def collect_alarm(alarm_dict):
            callback_data.append(alarm_dict)
        
        manager.add_callback(collect_alarm)
        
        # アラーム発火
        manager.check_and_trigger("room1", 35.0, 60.0)
        
        # コールバック実行確認
        assert len(callback_data) == 1
        assert callback_data[0]["alarm_type"] == "high_temp"
    
    def test_reset_alarm(self):
        """アラームリセット"""
        manager = AlarmManager()
        rule = AlarmRule(
            alarm_type="high_temp",
            sensor_param="temperature",
            threshold=30.0,
            direction="high",
            message_template="High temp",
        )
        manager.add_rule(rule)
        
        # アラーム発火
        manager.check_and_trigger("room1", 35.0, 60.0)
        assert len(manager.get_active_alarms()) == 1
        
        # リセット
        manager.reset_alarm("room1", "high_temp")
        assert len(manager.get_active_alarms()) == 0


class TestCreateDefaultAlarmManager:
    """デフォルト設定でのマネージャー作成テスト"""
    
    def test_default_manager_creation(self):
        """デフォルトマネージャー作成"""
        manager = create_default_alarm_manager()
        assert len(manager.rules) == 4  # 4つのルール
    
    def test_default_thresholds(self):
        """デフォルト閾値テスト"""
        manager = create_default_alarm_manager(
            temp_high=25,
            temp_low=15,
            humidity_high=70,
            humidity_low=30,
        )
        
        # 高温アラーム
        alarms_temp = manager.check_and_trigger("room1", 28.0, 50.0)
        assert any(a["alarm_type"] == "high_temp" for a in alarms_temp)
        
        # 低湿度アラーム
        alarms_humidity = manager.check_and_trigger("room2", 20.0, 25.0)
        assert any(a["alarm_type"] == "low_humidity" for a in alarms_humidity)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
