# 天気情報取得ツール (Weather Information Fetcher)

## 概要

このスクリプトは **OpenWeatherMap API** を使用して、指定する都市のリアルタイム天気情報を取得・表示します。

**主な特徴**:
- ✅ API レスポンスの5分間ファイルキャッシング
- ✅ 段階的エラーハンドリング（ネットワーク、API、ファイルI/O）
- ✅ 環境変数による設定管理
- ✅ ロギング機能
- ✅ 見やすいテーブル形式での天気表示

---

## 準備

### 1. OpenWeatherMap API キーの取得

1. https://openweathermap.org/api にアクセス
2. 無料プラン「OpenWeatherMap API」に登録
3. API キーを取得（メール確認から約10分後に有効化）

### 2. 依存パッケージのインストール

```bash
pip install -r requirements.txt
```

または手動インストール:

```bash
pip install python-dotenv requests
```

### 3. 環境変数の設定

`.env` ファイルを作成（`.env.example` をコピー）:

```bash
cp .env.example .env
```

`.env` ファイルを編集して API キーとデフォルト設定を記入:

```env
OPENWEATHER_API_KEY=your_actual_api_key_here
CITY=Tokyo
CACHE_DURATION_MINUTES=5
CACHE_DIR=./cache
LANGUAGE=ja
UNIT_SYSTEM=metric
```

**設定項目説明**:

| 項目 | 説明 | デフォルト | 例 |
|------|------|----------|-----|
| `OPENWEATHER_API_KEY` | OpenWeatherMap API キー | 必須 | `abc123...` |
| `CITY` | デフォルト都市名 | Tokyo | `Tokyo`, `Paris`, `New York` |
| `CACHE_DURATION_MINUTES` | キャッシュ有効期間（分） | 5 | 5, 10, 30 |
| `CACHE_DIR` | キャッシュファイルの保存先 | ./cache | `./cache`, `/tmp/cache` |
| `LANGUAGE` | 表示言語（オプション） | en | `ja`, `en`, `fr` |
| `UNIT_SYSTEM` | 温度単位（オプション） | metric | `metric` (°C), `imperial` (°F) |

---

## 使用方法

### 基本的な使い方

#### デフォルト都市の天気を表示

```bash
python main.py
```

#### 特定の都市の天気を表示

```bash
python main.py Tokyo
python main.py "New York"
python main.py Paris
```

複数単語の都市名はダブルクォートで囲む。

### 出力例

```
╔══════════════════════════════════════╗
║      天気情報 (Tokyo, JP)            ║
╚══════════════════════════════════════╝

📍 天気: Clear sky
🌡️  気温: 22.5°C (体感: 21.0°C)
💧 湿度: 65%
🌪️  気圧: 1013 hPa
💨 風速: 3.2 m/s
☁️  雲: 10%

⏰ 取得時刻: 2026-03-28 15:30:45 JST
```

---

## 技術仕様

### キャッシング機構

1. **初回実行**: API に問い合わせ → キャッシュに保存
2. **2回目以降**（5分以内）: キャッシュから速やかに読み込み
3. **5分経過後**: キャッシュが無効化 → 再度 API に問い合わせ

**キャッシュファイル例**:
```
cache/
├── weather_a1b2c3d4.json    # Tokyo
├── weather_e5f6g7h8.json    # Paris
└── weather_i9j0k1l2.json    # New York
```

都市名はハッシュ化されるため、特殊文字を含む都市名でも安全に処理できます。

### エラーハンドリング

| エラーケース | 対応 | 終了コード |
|-----------|------|----------|
| API キー未設定 | エラーメッセージ表示 | 1 |
| 都市が見つからない | `都市が見つかりません` メッセージ | 1 |
| ネットワークエラー | `接続エラー` メッセージ | 1 |
| ファイルI/Oエラー | ログ警告（処理継続） | 0 |
| 予期しないエラー | スタックトレース表示 | 1 |

---

## テスト実行

```bash
python -m pytest test_main.py -v
```

### テスト項目

- ✅ WeatherFetcher の初期化
- ✅ キャッシュの保存・読み込み
- ✅ API 呼び出し（モック）
- ✅ エラーハンドリング（不正なAPI キー、都市未検出）
- ✅ データフォーマット

---

## Vibe Coding 学習ポイント

このプロジェクトでは、以下の実装パターンを実践します:

### 1. **API 連携パターン**
```python
# 指示例: 
# "OpenWeatherMap API から都市の天気を取得してください"
# → 正しい URL 構築、パラメータ指定、リクエスト処理
```

### 2. **エラーハンドリング**
```python
# 指示例:
# "API が見つからない、ネットワークエラー、ファイルI/O エラーに対応してください"
# → 段階的な例外処理、ロギング、適切な終了コード
```

### 3. **ファイルキャッシング**
```python
# 指示例:
# "API の結果を5分间有効なキャッシュに保存してください"
# → ファイル操作、タイムスタンプ管理、ハッシュ化処理
```

### 4. **環境変数管理**
```python
# 指示例:
# ".env ファイルから設定を読み込みます"
# → python-dotenv の使用、デフォルト値の指定
```

---

## トラブルシューティング

### Q: `ModuleNotFoundError: No module named 'dotenv'`
**A**: `pip install python-dotenv` を実行してください

### Q: `APIエラー (HTTP 401): Unauthorized`
**A**: API キーが正しいか確認してください。`OPENWEATHER_API_KEY` を確認

### Q: `都市が見つかりません: Tokyo`
**A**: 都市名の入力をご確認ください。正式名称で検索することをお勧めします

### Q: キャッシュが更新されていない
**A**: `cache/` ディレクトリを削除して再度実行するか、環境変数 `CACHE_DURATION_MINUTES` を調整してください

---

## 参考資料

- [OpenWeatherMap API Documentation](https://openweathermap.org/api)
- [Python requests ライブラリ](https://requests.readthedocs.io/)
- [python-dotenv ドキュメント](https://github.com/theskumar/python-dotenv)

---

## ライセンス

MIT License - 個人学習用に自由に使用・改変できます

**作成者**: VideCoding Learning Project  
**作成日**: 2026-03-28  
**バージョン**: 1.0.0
