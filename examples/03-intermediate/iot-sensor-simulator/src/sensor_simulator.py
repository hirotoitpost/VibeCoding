"""
センサーシミュレーション モジュル - ID 011 IoT センサーシミュレーター

温度・湿度データの疑似生成
"""

import random
import logging
from typing import Dict, Tuple, Optional
from datetime import datetime
from dataclasses import dataclass
from threading import Thread, Event
import time

logger = logging.getLogger(__name__)


@dataclass
class SensorReading:
    """センサー計測値"""
    sensor_id: str
    room: str
    temperature: float      #℃
    humidity: float         # %
    timestamp: datetime
    
    def to_dict(self) -> dict:
        """辞書形式に変換"""
        return {
            "sensor_id": self.sensor_id,
            "room": self.room,
            "temperature": round(self.temperature, 2),
            "humidity": round(self.humidity, 2),
            "timestamp": self.timestamp.isoformat(),
        }
    
    def __repr__(self) -> str:
        return (
            f"SensorReading("
            f"room={self.room}, "
            f"temp={self.temperature:.1f}°C, "
            f"humidity={self.humidity:.1f}%, "
            f"@{self.timestamp.strftime('%H:%M:%S')})"
        )


class SensorSimulator:
    """
    温度・湿度センサーシミュレーター
    
    複数のセンサーを管理し、リアルタイムでデータを生成
    """
    
    def __init__(
        self,
        sensor_ids: list,
        temp_min: float = 10.0,
        temp_max: float = 35.0,
        humidity_min: float = 20.0,
        humidity_max: float = 95.0,
        temp_variance: float = 2.0,
        humidity_variance: float = 5.0,
    ):
        """
        初期化
        
        Args:
            sensor_ids: センサーID（ルーム名）のリスト
            temp_min: 最小温度（℃）
            temp_max: 最大温度（℃）
            humidity_min: 最小湿度（%）
            humidity_max: 最大湿度（%）
            temp_variance: 温度の変動幅（℃）
            humidity_variance: 湿度の変動幅（%）
        """
        self.sensor_ids = sensor_ids
        self.temp_min = temp_min
        self.temp_max = temp_max
        self.humidity_min = humidity_min
        self.humidity_max = humidity_max
        self.temp_variance = temp_variance
        self.humidity_variance = humidity_variance
        
        # センサーの現在値（前回値から連続的に変動させるため保持）
        self._current_values: Dict[str, Tuple[float, float]] = {}
        for sensor_id in sensor_ids:
            initial_temp = (temp_min + temp_max) / 2
            initial_humidity = (humidity_min + humidity_max) / 2
            self._current_values[sensor_id] = (initial_temp, initial_humidity)
        
        # スレッド制御
        self._running = False
        self._thread: Optional[Thread] = None
        self._stop_event = Event()
        
        logger.info(
            f"Sensor Simulator initialized: "
            f"{len(sensor_ids)} sensors, "
            f"temp={temp_min}~{temp_max}°C, "
            f"humidity={humidity_min}~{humidity_max}%"
        )
    
    def generate_reading(self, sensor_id: str) -> SensorReading:
        """
        単一センサーの計測値を生成
        
        前回値から ±variance の範囲で連続的に変動させる
        
        Args:
            sensor_id: センサーID（ルーム名）
        
        Returns:
            SensorReading オブジェクト
        """
        if sensor_id not in self._current_values:
            raise ValueError(f"Unknown sensor_id: {sensor_id}")
        
        current_temp, current_humidity = self._current_values[sensor_id]
        
        # 温度を ±variance の範囲で変動
        new_temp = current_temp + random.uniform(
            -self.temp_variance, self.temp_variance
        )
        new_temp = max(self.temp_min, min(self.temp_max, new_temp))
        
        # 湿度を ±variance の範囲で変動
        new_humidity = current_humidity + random.uniform(
            -self.humidity_variance, self.humidity_variance
        )
        new_humidity = max(self.humidity_min, min(self.humidity_max, new_humidity))
        
        # 現在値を更新
        self._current_values[sensor_id] = (new_temp, new_humidity)
        
        reading = SensorReading(
            sensor_id=f"sensor_{sensor_id}",
            room=sensor_id,
            temperature=new_temp,
            humidity=new_humidity,
            timestamp=datetime.now(),
        )
        
        return reading
    
    def generate_all_readings(self) -> list:
        """
        全センサーの計測値を一括生成
        
        Returns:
            SensorReading のリスト
        """
        readings = []
        for sensor_id in self.sensor_ids:
            reading = self.generate_reading(sensor_id)
            readings.append(reading)
        
        return readings
    
    def start(self, interval: int = 5, callback=None):
        """
        シミュレーション開始（バックグラウンドスレッド）
        
        Args:
            interval: データ生成間隔（秒）
            callback: データ生成時のコールバック関数
                      def callback(readings: list) -> None
        """
        if self._running:
            logger.warning("Simulator already running")
            return
        
        self._running = True
        self._stop_event.clear()
        
        def _run():
            logger.info(f"Simulator started (interval={interval}s)")
            
            while not self._stop_event.is_set():
                try:
                    readings = self.generate_all_readings()
                    
                    if callback:
                        callback(readings)
                    
                    # ログ出力（DEBUG レベル）
                    for reading in readings:
                        logger.debug(f"Generated: {reading}")
                    
                except Exception as e:
                    logger.error(f"Error generating readings: {e}")
                
                # インターバル待機
                self._stop_event.wait(interval)
            
            logger.info("Simulator stopped")
        
        self._thread = Thread(target=_run, daemon=True)
        self._thread.start()
    
    def stop(self, timeout: int = 5):
        """
        シミュレーション停止
        
        Args:
            timeout: スレッド終了まで待機する時間（秒）
        """
        if not self._running:
            logger.warning("Simulator not running")
            return
        
        logger.info("Stopping simulator...")
        self._stop_event.set()
        
        if self._thread:
            self._thread.join(timeout)
        
        self._running = False
    
    def is_running(self) -> bool:
        """実行状態を返す"""
        return self._running
    
    def get_current_values(self, sensor_id: str) -> Tuple[float, float]:
        """
        指定センサーの現在値を取得
        
        Returns:
            (temperature, humidity) のタプル
        """
        if sensor_id not in self._current_values:
            raise ValueError(f"Unknown sensor_id: {sensor_id}")
        
        return self._current_values[sensor_id]
    
    def get_all_current_values(self) -> Dict[str, Tuple[float, float]]:
        """全センサーの現在値を取得"""
        return dict(self._current_values)


# デバッグ実行
if __name__ == "__main__":
    import logging
    
    # ログ設定
    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s - %(levelname)s - %(message)s",
    )
    
    # シミュレーター作成
    simulator = SensorSimulator(
        sensor_ids=["room1", "room2", "room3"],
        temp_min=15,
        temp_max=28,
        humidity_min=30,
        humidity_max=80,
    )
    
    # コールバック定義
    def print_readings(readings):
        for reading in readings:
            print(f"📊 {reading}")
    
    # 開始
    simulator.start(interval=2, callback=print_readings)
    
    # 20秒間実行
    try:
        time.sleep(20)
    except KeyboardInterrupt:
        print("\n🛑 キーボード割り込み")
    finally:
        simulator.stop()
        print("✅ 完了")
