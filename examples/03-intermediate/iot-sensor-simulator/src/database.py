"""
データベース モジュル - SQLite 時系列データ管理

センサーデータの保存・取得を管理
"""

import logging
from typing import List, Optional, Tuple
from datetime import datetime, timedelta
from sqlalchemy import create_engine, Column, String, Float, DateTime, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session
from sqlalchemy.pool import StaticPool

logger = logging.getLogger(__name__)

Base = declarative_base()


class SensorReading(Base):
    """
    センサー計測値テーブル
    """
    __tablename__ = "sensor_readings"
    
    id = Column(Integer, primary_key=True)
    sensor_id = Column(String(50), nullable=False, index=True)
    room = Column(String(50), nullable=False)
    temperature = Column(Float, nullable=False)
    humidity = Column(Float, nullable=False)
    timestamp = Column(DateTime, nullable=False, index=True, default=datetime.now)
    
    def __repr__(self) -> str:
        return (
            f"SensorReading("
            f"sensor_id={self.sensor_id}, "
            f"room={self.room}, "
            f"temp={self.temperature:.1f}, "
            f"humidity={self.humidity:.1f}, "
            f"@{self.timestamp.isoformat()})"
        )
    
    def to_dict(self) -> dict:
        """辞書型に変換"""
        return {
            "id": self.id,
            "sensor_id": self.sensor_id,
            "room": self.room,
            "temperature": round(self.temperature, 2),
            "humidity": round(self.humidity, 2),
            "timestamp": self.timestamp.isoformat(),
        }


class AlarmEvent(Base):
    """
    アラームイベント テーブル
    """
    __tablename__ = "alarm_events"
    
    id = Column(Integer, primary_key=True)
    sensor_id = Column(String(50), nullable=False, index=True)
    alarm_type = Column(String(20), nullable=False)  # "high_temp", "low_temp", "high_humidity", "low_humidity"
    value = Column(Float, nullable=False)
    threshold = Column(Float, nullable=False)
    message = Column(String(255), nullable=False)
    timestamp = Column(DateTime, nullable=False, default=datetime.now, index=True)
    
    def __repr__(self) -> str:
        return (
            f"AlarmEvent("
            f"sensor_id={self.sensor_id}, "
            f"type={self.alarm_type}, "
            f"value={self.value}, "
            f"threshold={self.threshold})"
        )
    
    def to_dict(self) -> dict:
        """辞書型に変換"""
        return {
            "id": self.id,
            "sensor_id": self.sensor_id,
            "alarm_type": self.alarm_type,
            "value": round(self.value, 2),
            "threshold": round(self.threshold, 2),
            "message": self.message,
            "timestamp": self.timestamp.isoformat(),
        }


class Database:
    """
    SQLite データベース管理
    """
    
    def __init__(self, database_url: str = "sqlite:///sensor_data.db", echo: bool = False):
        """
        初期化
        
        Args:
            database_url: データベース URL
            echo: SQL ログ出力フラグ
        """
        self.database_url = database_url
        
        # SQLite の場合、特別な設定
        if "sqlite" in database_url:
            engine = create_engine(
                database_url,
                connect_args={"check_same_thread": False},
                poolclass=StaticPool,
                echo=echo,
            )
        else:
            engine = create_engine(database_url, echo=echo)
        
        self.engine = engine
        self.SessionLocal = scoped_session(sessionmaker(bind=engine))
        
        # テーブル作成
        Base.metadata.create_all(engine)
        
        logger.info(f"Database initialized: {database_url}")
    
    def get_session(self):
        """セッション取得"""
        return self.SessionLocal()
    
    def save_reading(
        self,
        sensor_id: str,
        room: str,
        temperature: float,
        humidity: float,
        timestamp: Optional[datetime] = None,
    ) -> SensorReading:
        """
        センサー計測値を保存
        
        Args:
            sensor_id: センサーID
            room: ルーム名
            temperature: 温度（℃）
            humidity: 湿度（%）
            timestamp: タイムスタンプ（省略時: 現在時刻）
        
        Returns:
            保存されたレコード
        """
        session = self.get_session()
        try:
            reading = SensorReading(
                sensor_id=sensor_id,
                room=room,
                temperature=temperature,
                humidity=humidity,
                timestamp=timestamp or datetime.now(),
            )
            session.add(reading)
            session.commit()
            
            logger.debug(f"Saved reading: {reading}")
            return reading
        except Exception as e:
            session.rollback()
            logger.error(f"Failed to save reading: {e}")
            raise
        finally:
            session.close()
    
    def get_latest_readings(self, limit: int = 100) -> List[SensorReading]:
        """
        最新の計測値を取得
        
        Args:
            limit: 取得件数
        
        Returns:
            SensorReading のリスト
        """
        session = self.get_session()
        try:
            readings = (
                session.query(SensorReading)
                .order_by(SensorReading.timestamp.desc())
                .limit(limit)
                .all()
            )
            return readings
        finally:
            session.close()
    
    def get_readings_by_room(
        self,
        room: str,
        limit: int = 100,
        hours: int = 24,
    ) -> List[SensorReading]:
        """
        指定ルームのデータを取得
        
        Args:
            room: ルーム名
            limit: 取得件数
            hours: 過去何時間分のデータを取得するか
        
        Returns:
            SensorReading のリスト
        """
        session = self.get_session()
        try:
            since = datetime.now() - timedelta(hours=hours)
            readings = (
                session.query(SensorReading)
                .filter(SensorReading.room == room)
                .filter(SensorReading.timestamp >= since)
                .order_by(SensorReading.timestamp.desc())
                .limit(limit)
                .all()
            )
            return readings
        finally:
            session.close()
    
    def get_statistics(
        self,
        room: str,
        hours: int = 24,
    ) -> dict:
        """
        指定ルームの統計情報を取得
        
        Args:
            room: ルーム名
            hours: 過去何時間分のデータを対象とするか
        
        Returns:
            統計情報辞書
        """
        session = self.get_session()
        try:
            since = datetime.now() - timedelta(hours=hours)
            readings = (
                session.query(SensorReading)
                .filter(SensorReading.room == room)
                .filter(SensorReading.timestamp >= since)
                .all()
            )
            
            if not readings:
                return {
                    "room": room,
                    "count": 0,
                    "temperature": None,
                    "humidity": None,
                }
            
            temps = [r.temperature for r in readings]
            humidities = [r.humidity for r in readings]
            
            return {
                "room": room,
                "count": len(readings),
                "temperature": {
                    "min": min(temps),
                    "max": max(temps),
                    "avg": sum(temps) / len(temps),
                },
                "humidity": {
                    "min": min(humidities),
                    "max": max(humidities),
                    "avg": sum(humidities) / len(humidities),
                },
            }
        finally:
            session.close()
    
    def save_alarm(
        self,
        sensor_id: str,
        alarm_type: str,
        value: float,
        threshold: float,
        message: str,
    ) -> AlarmEvent:
        """
        アラームイベントを保存
        
        Args:
            sensor_id: センサーID
            alarm_type: アラーム種別
            value: 現在値
            threshold: 閾値
            message: メッセージ
        
        Returns:
            AlarmEvent
        """
        session = self.get_session()
        try:
            alarm = AlarmEvent(
                sensor_id=sensor_id,
                alarm_type=alarm_type,
                value=value,
                threshold=threshold,
                message=message,
                timestamp=datetime.now(),
            )
            session.add(alarm)
            session.commit()
            
            logger.warning(f"Alarm saved: {alarm}")
            return alarm
        except Exception as e:
            session.rollback()
            logger.error(f"Failed to save alarm: {e}")
            raise
        finally:
            session.close()
    
    def get_recent_alarms(self, limit: int = 50, hours: int = 24) -> List[AlarmEvent]:
        """
        最近のアラームを取得
        
        Args:
            limit: 取得件数
            hours: 過去何時間分のデータを取得するか
        
        Returns:
            AlarmEvent のリスト
        """
        session = self.get_session()
        try:
            since = datetime.now() - timedelta(hours=hours)
            alarms = (
                session.query(AlarmEvent)
                .filter(AlarmEvent.timestamp >= since)
                .order_by(AlarmEvent.timestamp.desc())
                .limit(limit)
                .all()
            )
            return alarms
        finally:
            session.close()
    
    def cleanup_old_data(self, days: int = 30):
        """
        古いデータを削除
        
        Args:
            days: 何日以上前のデータを削除するか
        """
        session = self.get_session()
        try:
            cutoff_date = datetime.now() - timedelta(days=days)
            
            deleted_readings = (
                session.query(SensorReading)
                .filter(SensorReading.timestamp < cutoff_date)
                .delete()
            )
            
            deleted_alarms = (
                session.query(AlarmEvent)
                .filter(AlarmEvent.timestamp < cutoff_date)
                .delete()
            )
            
            session.commit()
            
            logger.info(
                f"Cleanup completed: "
                f"deleted {deleted_readings} readings, "
                f"{deleted_alarms} alarms"
            )
        except Exception as e:
            session.rollback()
            logger.error(f"Failed to cleanup: {e}")
        finally:
            session.close()


# デバッグ実行
if __name__ == "__main__":
    import logging
    
    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s - %(levelname)s - %(message)s",
    )
    
    # デバッグ用メモリDB
    db = Database("sqlite:///:memory:", echo=False)
    
    # テストデータ保存
    for i in range(10):
        db.save_reading("sensor_room1", "room1", 20 + i, 50 + i)
    
    # 取得テスト
    readings = db.get_latest_readings(5)
    print("\n最新5件:")
    for r in readings:
        print(f"  {r.to_dict()}")
    
    # 統計情報
    stats = db.get_statistics("room1", hours=1)
    print(f"\n統計情報: {stats}")
