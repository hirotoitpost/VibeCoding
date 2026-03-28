"""
天気情報取得ツールのテストスイート

テスト項目:
    - WeatherFetcher クラスの初期化
    - キャッシュの保存・読み込み
    - API 呼び出し（モック使用）
    - エラーハンドリング
    - データフォーマット
"""

import unittest
import json
import time
import os
from pathlib import Path
from unittest.mock import patch, MagicMock, mock_open
from io import BytesIO

# テスト対象モジュールをインポート
# main.py と同じディレクトリにあるため直接インポート
import sys
sys.path.insert(0, os.path.dirname(__file__))
from main import WeatherFetcher


class TestWeatherFetcher(unittest.TestCase):
    """WeatherFetcher クラスのテストケース"""

    def setUp(self):
        """各テスト前の初期化処理"""
        self.api_key = "test_api_key_12345"
        self.cache_duration = 5
        
        # テンポラリキャッシュディレクトリを作成
        self.test_cache_dir = Path("./test_cache")
        self.test_cache_dir.mkdir(exist_ok=True)

    def tearDown(self):
        """各テスト後のクリーンアップ処理"""
        # テストキャッシュディレクトリを削除
        import shutil
        if self.test_cache_dir.exists():
            shutil.rmtree(self.test_cache_dir)

    def test_initialization_with_valid_key(self):
        """正常なAPI キーでの初期化テスト"""
        fetcher = WeatherFetcher(
            self.api_key,
            cache_duration=self.cache_duration
        )
        self.assertIsNotNone(fetcher)
        self.assertEqual(fetcher.api_key, self.api_key)
        self.assertEqual(fetcher.cache_duration, self.cache_duration * 60)

    def test_initialization_with_invalid_key(self):
        """不正なAPI キーでの初期化テスト"""
        with self.assertRaises(ValueError) as context:
            WeatherFetcher("your_api_key_here")
        
        self.assertIn("API キー が設定されていません", str(context.exception))

    def test_initialization_with_empty_key(self):
        """空のAPI キーでの初期化テスト"""
        with self.assertRaises(ValueError):
            WeatherFetcher("")

    def test_cache_path_generation(self):
        """キャッシュパス生成テスト"""
        with patch.dict(os.environ, {"CACHE_DIR": "./test_cache"}):
            fetcher = WeatherFetcher(self.api_key)
            
            cache_path = fetcher._get_cache_path("Tokyo")
            
            # パスが正しく生成されているか確認
            self.assertIsInstance(cache_path, Path)
            self.assertTrue(str(cache_path).endswith(".json"))
            # 都市名がハッシュ化されているか（8文字）
            self.assertIn("weather_", cache_path.name)

    def test_save_and_load_cache(self):
        """キャッシュの保存・読み込みテスト"""
        with patch.dict(os.environ, {"CACHE_DIR": str(self.test_cache_dir)}):
            fetcher = WeatherFetcher(self.api_key)
            
            # テストデータ
            test_city = "Tokyo"
            test_data = {
                "name": "Tokyo",
                "sys": {"country": "JP"},
                "main": {"temp": 20.0},
                "weather": [{"description": "clear"}]
            }
            
            # キャッシュに保存
            fetcher._save_cache(test_city, test_data)
            
            # キャッシュから読み込み
            loaded_data = fetcher._load_cache(test_city)
            
            # データが同じか確認
            self.assertEqual(loaded_data, test_data)

    def test_cache_expiration(self):
        """キャッシュ有効期限切れテスト"""
        with patch.dict(os.environ, {"CACHE_DIR": str(self.test_cache_dir)}):
            # キャッシュ有効期間を1秒に設定
            fetcher = WeatherFetcher(self.api_key, cache_duration=1)
            
            test_city = "Paris"
            test_data = {"name": "Paris", "sys": {"country": "FR"}}
            
            # キャッシュを保存
            fetcher._save_cache(test_city, test_data)
            
            # キャッシュが有効か確認
            loaded = fetcher._load_cache(test_city)
            self.assertIsNotNone(loaded)
            
            # 1.5秒待機（キャッシュ有効期限を超える）
            time.sleep(1.5)
            
            # キャッシュが期限切れか確認
            expired = fetcher._load_cache(test_city)
            self.assertIsNone(expired)

    def test_cache_with_nonexistent_file(self):
        """存在しないキャッシュファイルの処理テスト"""
        with patch.dict(os.environ, {"CACHE_DIR": str(self.test_cache_dir)}):
            fetcher = WeatherFetcher(self.api_key)
            
            # 存在しいない都市のキャッシュを読み込み
            result = fetcher._load_cache("NonExistentCity12345")
            
            # None を返すことを確認
            self.assertIsNone(result)

    @patch("main.urlopen")
    def test_fetch_with_cache(self, mock_urlopen):
        """キャッシュ利用時の fetch テスト"""
        with patch.dict(os.environ, {"CACHE_DIR": str(self.test_cache_dir)}):
            fetcher = WeatherFetcher(self.api_key)
            
            test_city = "Tokyo"
            test_response = {
                "name": "Tokyo",
                "sys": {"country": "JP"},
                "main": {"temp": 22.0},
                "weather": [{"description": "sunny"}]
            }
            
            # API モック設定
            mock_response = MagicMock()
            mock_response.status = 200
            mock_response.read.return_value = json.dumps(test_response).encode()
            mock_urlopen.return_value.__enter__.return_value = mock_response
            
            # 1回目の fetch（API 呼び出し）
            result1 = fetcher.fetch(test_city)
            self.assertEqual(mock_urlopen.call_count, 1)
            
            # 2回目の fetch（キャッシュから読み込み）
            result2 = fetcher.fetch(test_city)
            self.assertEqual(mock_urlopen.call_count, 1)  # 呼び出し数は変わらず
            
            # 結果が同じか確認
            self.assertEqual(result1, result2)

    @patch("main.urlopen")
    def test_fetch_city_not_found(self, mock_urlopen):
        """存在しない都市の fetch テスト"""
        fetcher = WeatherFetcher(self.api_key)
        
        # 404 エラーをシミュレート
        from urllib.error import HTTPError
        mock_urlopen.side_effect = HTTPError(
            "url", 404, "Not Found", None, None
        )
        
        with self.assertRaises(ValueError) as context:
            fetcher.fetch("NonExistentCity")
        
        self.assertIn("都市が見つかりません", str(context.exception))

    @patch("main.urlopen")
    def test_fetch_network_error(self, mock_urlopen):
        """ネットワーク エラー内の fetch テスト"""
        from urllib.error import URLError
        
        fetcher = WeatherFetcher(self.api_key)
        
        # URLError をシミュレート
        mock_urlopen.side_effect = URLError("Connection refused")
        
        with self.assertRaises(ConnectionError) as context:
            fetcher.fetch("Tokyo")
        
        self.assertIn("ネットワークエラー", str(context.exception))

    @patch("main.urlopen")
    def test_fetch_http_error(self, mock_urlopen):
        """HTTP エラーの fetch テスト"""
        from urllib.error import HTTPError
        
        fetcher = WeatherFetcher(self.api_key)
        
        # 401 Unauthorized をシミュレート
        mock_urlopen.side_effect = HTTPError(
            "url", 401, "Unauthorized", None, None
        )
        
        with self.assertRaises(ConnectionError) as context:
            fetcher.fetch("Tokyo")
        
        self.assertIn("APIエラー", str(context.exception))

    def test_format_output_with_valid_data(self):
        """有効なデータでのフォーマット テスト"""
        test_data = {
            "name": "Tokyo",
            "sys": {"country": "JP"},
            "main": {
                "temp": 22.5,
                "feels_like": 21.0,
                "humidity": 65,
                "pressure": 1013
            },
            "weather": [{"description": "clear sky"}],
            "wind": {"speed": 3.2},
            "clouds": {"all": 10}
        }
        
        output = WeatherFetcher.format_output(test_data)
        
        # 重要な情報が含まれているか確認
        self.assertIn("Tokyo", output)
        self.assertIn("JP", output)
        self.assertIn("22.5", output)
        self.assertIn("65", output)

    def test_format_output_with_incomplete_data(self):
        """不完全なデータでのフォーマット テスト"""
        test_data = {
            "name": "Unknown",
            "main": {"temp": 20.0}
            # 他のフィールドは不足
        }
        
        output = WeatherFetcher.format_output(test_data)
        
        # フォーマットが失敗せず、JSON フォールバック
        self.assertIsNotNone(output)
        self.assertTrue(len(output) > 0)


class TestIntegration(unittest.TestCase):
    """統合テスト（実際のAPI呼び出しが必要な場合）"""
    
    @unittest.skipUnless(
        os.getenv("RUN_INTEGRATION_TESTS") == "true",
        "統合テストは明示的に有効化が必要（RUN_INTEGRATION_TESTS=true）"
    )
    def test_real_api_call(self):
        """実際の API 呼び出しテスト"""
        api_key = os.getenv("OPENWEATHER_API_KEY")
        if not api_key or api_key == "your_api_key_here":
            self.skipTest("OPENWEATHER_API_KEY が設定されていません")
        
        fetcher = WeatherFetcher(api_key)
        data = fetcher.fetch("Tokyo")
        
        # 基本的なデータ構造を確認
        self.assertIn("name", data)
        self.assertIn("main", data)
        self.assertIn("weather", data)


if __name__ == "__main__":
    # テストスイートを実行
    unittest.main(verbosity=2)
