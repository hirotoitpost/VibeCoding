"""
アラーム管理モジュル - ID 011 IoT センサーシミュレーター

閾値監視とアラーム生成
"""

import logging
from typing import Dict, List, Optional, Callable
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)


class AlarmRule:
    """アラームルール"""
    
    def __init__(
        self,
        alarm_type: str,
        sensor_param: str,  # "temperature" or "humidity"
        threshold: float,
        direction: str,  # "high" or "low"
        message_template: str,
    ):
        """
        初期化
        
        Args:
            alarm_type: アラーム型 (e.g., "high_temp", "low_humidity")
            sensor_param: センサーパラメータ
            threshold: 閾値
            direction: "high" (以上) or "low" (以下)
            message_template: メッセージテンプレート
        """
        self.alarm_type = alarm_type
        self.sensor_param = sensor_param
        self.threshold = threshold
        self.direction = direction
        self.message_template = message_template
    
    def check(self, value: float) -> bool:
        """
        閾値チェック
        
        Args:
            value: 計測値
        
        Returns:
            True = アラーム条件満たす
        """
        if self.direction == "high":
            return value >= self.threshold
        elif self.direction == "low":
            return value <= self.threshold
        else:
            raise ValueError(f"Invalid direction: {self.direction}")
    
    def format_message(self, sensor_id: str, value: float) -> str:
        """メッセージを生成"""
        return self.message_template.format(
            sensor_id=sensor_id,
            value=round(value, 2),
            threshold=round(self.threshold, 2),
        )


class AlarmManager:
    """
    アラーム管理
    
    センサーデータ→アラーム判定→デダップリング→コールバック
    """
    
    def __init__(self, notify_interval: int = 60):
        """
        初期化
        
        Args:
            notify_interval: 同一アラームの再通知間隔（秒）
        """
        self.notify_interval = notify_interval
        self.rules: List[AlarmRule] = []
        self._active_alarms: Dict[str, datetime] = {}  # alarm_key -> 最終アラーム時刻
        self._callbacks: List[Callable] = []
        
        logger.info(f"AlarmManager initialized (notify_interval={notify_interval}s)")
    
    def add_rule(self, rule: AlarmRule):
        """アラームルールを追加"""
        self.rules.append(rule)
        logger.info(f"Added alarm rule: {rule.alarm_type}")
    
    def add_callback(self, callback: Callable):
        """
        アラーム発生時のコールバックを登録
        
        Args:
            callback: def callback(alarm_dict: dict) -> None
        """
        self._callbacks.append(callback)
    
    def check_and_trigger(
        self,
        sensor_id: str,
        temperature: float,
        humidity: float,
    ) -> List[Dict]:
        """
        センサーデータをチェックしてアラームを発火
        
        Args:
            sensor_id: センサーID
            temperature: 温度
            humidity: 湿度
        
        Returns:
            発火したアラームのリスト
        """
        triggered_alarms = []
        current_time = datetime.now()
        
        for rule in self.rules:
            # パラメータ値を取得
            if rule.sensor_param == "temperature":
                value = temperature
            elif rule.sensor_param == "humidity":
                value = humidity
            else:
                continue
            
            # 閾値チェック
            if not rule.check(value):
                continue
            
            # デダップリング：同じアラームが既に発火しているか
            alarm_key = f"{sensor_id}:{rule.alarm_type}"
            now = datetime.now()
            
            if alarm_key in self._active_alarms:
                last_notify = self._active_alarms[alarm_key]
                elapsed = (now - last_notify).total_seconds()
                
                if elapsed < self.notify_interval:
                    # notify_interval の間隔が経っていないためスキップ
                    logger.debug(
                        f"Alarm suppressed (deduplication): {alarm_key} "
                        f"(elapsed={elapsed:.1f}s < {self.notify_interval}s)"
                    )
                    continue
            
            # アラーム情報を構築
            message = rule.format_message(sensor_id, value)
            alarm_dict = {
                "sensor_id": sensor_id,
                "alarm_type": rule.alarm_type,
                "param": rule.sensor_param,
                "value": round(value, 2),
                "threshold": round(rule.threshold, 2),
                "message": message,
                "timestamp": now.isoformat(),
            }
            
            triggered_alarms.append(alarm_dict)
            
            # アラーム履歴を更新
            self._active_alarms[alarm_key] = now
            
            logger.warning(f"Alarm triggered: {alarm_dict}")
            
            # コールバック実行
            for callback in self._callbacks:
                try:
                    callback(alarm_dict)
                except Exception as e:
                    logger.error(f"Error in alarm callback: {e}")
        
        return triggered_alarms
    
    def get_active_alarms(self) -> Dict[str, datetime]:
        """
        既知のアラームリストを返す
        
        Returns:
            {alarm_key: last_notification_time} 辞書
        """
        return dict(self._active_alarms)
    
    def reset_alarm(self, sensor_id: str, alarm_type: str):
        """
        特定のアラームをリセット
        
        Args:
            sensor_id: センサーID
            alarm_type: アラーム型
        """
        alarm_key = f"{sensor_id}:{alarm_type}"
        if alarm_key in self._active_alarms:
            del self._active_alarms[alarm_key]
            logger.info(f"Alarm reset: {alarm_key}")
    
    def clear_all_alarms(self):
        """全アラームをリセット"""
        self._active_alarms.clear()
        logger.info("All alarms cleared")


def create_default_alarm_manager(
    temp_high: float = 30,
    temp_low: float = 5,
    humidity_high: float = 80,
    humidity_low: float = 40,
    notify_interval: int = 60,
) -> AlarmManager:
    """
    デフォルト設定でアラームマネージャーを作成
    
    Args:
        temp_high: 高温アラーム閾値
        temp_low: 低温アラーム閾値
        humidity_high: 高湿度アラーム閾値
        humidity_low: 低湿度アラーム閾値
        notify_interval: 通知間隔
    
    Returns:
        AlarmManager インスタンス
    """
    manager = AlarmManager(notify_interval=notify_interval)
    
    # 温度アラーム
    manager.add_rule(AlarmRule(
        alarm_type="high_temp",
        sensor_param="temperature",
        threshold=temp_high,
        direction="high",
        message_template="🌡️ 高温アラーム: {sensor_id} = {value}°C (閾値: {threshold}°C)",
    ))
    
    manager.add_rule(AlarmRule(
        alarm_type="low_temp",
        sensor_param="temperature",
        threshold=temp_low,
        direction="low",
        message_template="❄️ 低温アラーム: {sensor_id} = {value}°C (閾値: {threshold}°C)",
    ))
    
    # 湿度アラーム
    manager.add_rule(AlarmRule(
        alarm_type="high_humidity",
        sensor_param="humidity",
        threshold=humidity_high,
        direction="high",
        message_template="💧 高湿度アラーム: {sensor_id} = {value}% (閾値: {threshold}%)",
    ))
    
    manager.add_rule(AlarmRule(
        alarm_type="low_humidity",
        sensor_param="humidity",
        threshold=humidity_low,
        direction="low",
        message_template="🌵 低湿度アラーム: {sensor_id} = {value}% (閾値: {threshold}%)",
    ))
    
    logger.info(
        f"Default AlarmManager created: "
        f"temp({temp_low}~{temp_high}), "
        f"humidity({humidity_low}~{humidity_high})"
    )
    
    return manager


# デバッグ実行
if __name__ == "__main__":
    import logging
    
    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s - %(levelname)s - %(message)s",
    )
    
    # アラームマネージャー作成
    manager = create_default_alarm_manager(
        temp_high=25,
        temp_low=15,
        humidity_high=70,
        humidity_low=30,
    )
    
    # コールバック登録
    def print_alarm(alarm_dict):
        print(f"\n🚨 {alarm_dict['message']}")
    
    manager.add_callback(print_alarm)
    
    # テスト
    print("\n=== Temperature Test ===")
    manager.check_and_trigger("room1", 28.0, 50.0)  # OK
    manager.check_and_trigger("room1", 30.5, 50.0)  # High alarm
    manager.check_and_trigger("room1", 30.0, 50.0)  # Suppressed
    
    print("\n=== Humidity Test ===")
    manager.check_and_trigger("room2", 20.0, 75.0)  # High alarm
    manager.check_and_trigger("room2", 20.0, 32.0)  # Low alarm
    
    print("\n=== Active Alarms ===")
    print(manager.get_active_alarms())
