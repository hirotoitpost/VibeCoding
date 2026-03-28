"""
天気情報取得ツール (Weather Information Fetcher)

このスクリプトは OpenWeatherMap API を使用して
リアルタイムの天気情報を取得・表示します。
5分間のファイルキャッシング機能により、
API呼び出し回数を削減しています。

使用方法:
    python main.py [city_name]

例:
    python main.py Tokyo
    python main.py "New York"
"""

import os
import sys
import json
import time
import hashlib
from datetime import datetime
from pathlib import Path
from typing import Dict, Optional
from urllib.request import urlopen
from urllib.parse import urlencode
from urllib.error import URLError, HTTPError
import logging

# ロギング設定
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class WeatherFetcher:
    """OpenWeatherMap API を使用して天気情報を取得するクラス"""

    def __init__(self, api_key: str, cache_duration: int = 5):
        """
        初期化

        Args:
            api_key (str): OpenWeatherMap API キー
            cache_duration (int): キャッシュ有効期限（分）。デフォルト: 5分
        """
        if not api_key or api_key == "your_api_key_here":
            raise ValueError(
                "API キー が設定されていません。"
                ".env ファイルを確認してください。"
            )
        
        self.api_key = api_key
        self.cache_duration = cache_duration * 60  # 秒に変換
        self.cache_dir = Path(os.getenv("CACHE_DIR", "./cache"))
        self.cache_dir.mkdir(exist_ok=True)
        self.base_url = "https://api.openweathermap.org/data/2.5/weather"

    def _get_cache_path(self, city: str) -> Path:
        """
        キャッシュファイルのパスを生成

        Args:
            city (str): 都市名

        Returns:
            Path: キャッシュファイルのパス
        """
        # 都市名をハッシュ化してファイル名にする（特殊文字対応）
        city_hash = hashlib.md5(city.encode()).hexdigest()[:8]
        return self.cache_dir / f"weather_{city_hash}.json"

    def _load_cache(self, city: str) -> Optional[Dict]:
        """
        キャッシュファイルから天気データを読み込む

        Args:
            city (str): 都市名

        Returns:
            Optional[Dict]: キャッシュデータ（有効な場合）、None（無効な場合）
        """
        cache_path = self._get_cache_path(city)
        
        if not cache_path.exists():
            return None
        
        try:
            file_mtime = os.path.getmtime(cache_path)
            elapsed = time.time() - file_mtime
            
            if elapsed > self.cache_duration:
                logger.info(
                    f"キャッシュ有効期限切れ: {city} "
                    f"({elapsed:.0f}秒経過 > {self.cache_duration}秒)"
                )
                return None
            
            with open(cache_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                logger.info(
                    f"キャッシュから読み込み: {city} "
                    f"({elapsed:.0f}秒前)"
                )
                return data
        
        except (json.JSONDecodeError, IOError) as e:
            logger.warning(f"キャッシュ読み込み失敗: {e}")
            return None

    def _save_cache(self, city: str, data: Dict) -> None:
        """
        天気データをキャッシュに保存

        Args:
            city (str): 都市名
            data (Dict): 天気データ
        """
        cache_path = self._get_cache_path(city)
        try:
            with open(cache_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
                logger.info(f"キャッシュに保存: {city}")
        except IOError as e:
            logger.warning(f"キャッシュ保存失敗: {e}")

    def fetch(self, city: str, use_cache: bool = True) -> Dict:
        """
        指定都市の天気情報を取得

        Args:
            city (str): 都市名
            use_cache (bool): キャッシュを使用するか。デフォルト: True

        Returns:
            Dict: 天気データ

        Raises:
            ValueError: 都市が見つからない場合
            ConnectionError: ネットワークエラーの場合
        """
        # キャッシュ確認
        if use_cache:
            cached_data = self._load_cache(city)
            if cached_data:
                return cached_data

        # API呼び出し
        try:
            params = {
                "q": city,
                "appid": self.api_key,
                "units": os.getenv("UNIT_SYSTEM", "metric"),
                "lang": os.getenv("LANGUAGE", "en"),
            }
            
            # URLを構築（urlencode でパラメータを正しくエンコード）
            query_string = urlencode(params)
            url = f"{self.base_url}?{query_string}"
            
            logger.info(f"API呼び出し: {city}")
            
            with urlopen(url, timeout=10) as response:
                if response.status != 200:
                    raise HTTPError(
                        url, response.status,
                        f"HTTP {response.status}", None, None
                    )
                data = json.loads(response.read().decode('utf-8'))
        
        except HTTPError as e:
            if e.code == 404:
                raise ValueError(f"都市が見つかりません: {city}") from e
            else:
                raise ConnectionError(
                    f"APIエラー (HTTP {e.code}): {e.reason}"
                ) from e
        
        except URLError as e:
            raise ConnectionError(
                f"ネットワークエラー: {e.reason}"
            ) from e
        
        except Exception as e:
            raise ConnectionError(
                f"予期しないエラー: {str(e)}"
            ) from e

        # キャッシュに保存
        self._save_cache(city, data)
        
        return data

    @staticmethod
    def format_output(data: Dict) -> str:
        """
        天気データを見やすく整形

        Args:
            data (Dict): 天気データ

        Returns:
            str: フォーマット済み文字列
        """
        try:
            city = data.get("name", "Unknown")
            country = data.get("sys", {}).get("country", "")
            
            main = data.get("main", {})
            temp = main.get("temp", "N/A")
            feels_like = main.get("feels_like", "N/A")
            humidity = main.get("humidity", "N/A")
            pressure = main.get("pressure", "N/A")
            
            weather = data.get("weather", [{}])[0]
            description = weather.get("description", "N/A")
            icon = weather.get("icon", "")
            
            wind = data.get("wind", {})
            wind_speed = wind.get("speed", "N/A")
            
            clouds = data.get("clouds", {}).get("all", "N/A")
            
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S %Z")
            
            output = f"""
╔══════════════════════════════════════╗
║      天気情報 ({city}, {country})      ║
╚══════════════════════════════════════╝

📍 天気: {description.capitalize()}
🌡️  気温: {temp}°C (体感: {feels_like}°C)
💧 湿度: {humidity}%
🌪️  気圧: {pressure} hPa
💨 風速: {wind_speed} m/s
☁️  雲: {clouds}%

⏰ 取得時刻: {timestamp}
"""
            return output.strip()
        
        except (KeyError, TypeError) as e:
            logger.error(f"データフォーマット失敗: {e}")
            return json.dumps(data, indent=2, ensure_ascii=False)


def main():
    """メイン処理"""
    # 環境変数読み込み
    try:
        from dotenv import load_dotenv
        load_dotenv()
    except ImportError:
        logger.warning("python-dotenv がインストールされていません")
    
    # API キー取得
    api_key = os.getenv("OPENWEATHER_API_KEY", "your_api_key_here")
    cache_duration = int(os.getenv("CACHE_DURATION_MINUTES", "5"))
    
    # 都市名決定
    if len(sys.argv) > 1:
        city = " ".join(sys.argv[1:])
    else:
        city = os.getenv("CITY", "Tokyo")
    
    # 天気情報取得
    try:
        fetcher = WeatherFetcher(api_key, cache_duration)
        weather_data = fetcher.fetch(city)
        print(fetcher.format_output(weather_data))
        
    except ValueError as e:
        logger.error(f"入力エラー: {e}")
        sys.exit(1)
    
    except ConnectionError as e:
        logger.error(f"接続エラー: {e}")
        sys.exit(1)
    
    except Exception as e:
        logger.error(f"予期しないエラー: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
