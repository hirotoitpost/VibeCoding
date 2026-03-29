# トラブルシューティング - ID 011 IoT センサーシミュレーター

## よくある質問・問題

### 1. MQTT ブローカーに接続できない

**症状**: `Connection refused` エラーが表示される

**原因**:
- Mosquitto コンテナが起動していない
- ポート 1883 が他のプロセスで使用されている
- ホスト名が解決できない（`mosquitto` サービス名）

**解決方法**:

```bash
# コンテナ起動確認
docker-compose ps

# Mosquitto ログ確認
docker-compose logs mosquitto

# 再起動
docker-compose down
docker-compose up -d

# 接続テスト
mosquitto_sub -h localhost -t "test" &
mosquitto_pub -h localhost -t "test" -m "Hello"
```

### 2. SQLite データベースロック エラー

**症状**: `database is locked` エラー

**原因**:
- 複数のプロセスが同時アクセス
- 前回実行時のロックが残っている

**解決方法**:

```bash
# DB ロック解除
rm sensor_data.db

# コンテナの完全リセット
docker-compose restart

# または
docker-compose down -v
docker-compose up -d
```

### 3. Flask ダッシュボードが表示されない

**症状**: `http://localhost:5000` にアクセスできない

**原因**:
- Flask コンテナが起動していない
- ポート 5000 が使用されている
- テンプレートファイルが見つからない

**解決方法**:

```bash
# webapp コンテナ確認
docker-compose logs webapp

# ポート確認
netstat -an | find "5000"

# 再起動
docker-compose restart webapp
```

### 4. グラフが表示されない（ダッシュボード）

**症状**: ダッシュボードは表示されるがグラフが空

**原因**:
- API エンドポイントがデータを返していない
-  JavaScript エラー

**解決方法**:

```bash
# ブラウザの開発者ツール (F12) で console タブを確認
# API エンドポイント動作確認
curl http://localhost:5000/api/sensors
curl http://localhost:5000/api/readings

# webapp ログ確認
docker-compose logs -f webapp
```

### 5. センサーデータが生成されない

**症状**: DB にデータが保存されていない

**原因**:
- センサーシミュレーター プロセスが起動していない
- MQTT パブリッシュ失敗
- DB 接続エラー

**解決方法**:

```bash
# simulator コンテナログ確認
docker-compose logs -f sensor_simulator

# 詳細ログ出力（環境変数で調整）
docker-compose exec sensor_simulator bash
export LOG_LEVEL=DEBUG
python -m src.simulator_main
```

### 6. 高い CPU 使用率

**症状**: CPU が 100% に近い

**原因**:
- センサー生成間隔が短すぎる
- ポーリング間隔の設定ミス

**解決方法**:

```bash
# .env で設定調整
SENSOR_INTERVAL=10  # 10秒に変更

# docker-compose 再起動
docker-compose restart sensor_simulator
```

### 7. メモリ不足エラー

**症状**: `MemoryError` や OOM Killer による終了

**原因**:
- 古いデータが削除されていない
- コンテナメモリリミットが小さい

**解決方法**:

```bash
# データベースクリーンアップ (30日以前のデータ削除)
docker-compose exec webapp python -c "
from src.database import Database
db = Database()
db.cleanup_old_data(days=30)
"

# docker-compose.yml でメモリ制限を増やす
# services:
#   webapp:
#     mem_limit: 512m
```

## デバッグスキル

### ログレベル確認

```bash
# ログレベルを DEBUG に変更
echo "LOG_LEVEL=DEBUG" >> .env
docker-compose restart
```

### データベースの直接確認

```bash
# SQLite CLI で DB を操作
docker-compose exec webapp sqlite3 sensor_data.db

# テーブル確認
> .tables

# データ確認
> SELECT * FROM sensor_readings LIMIT 5;

# 統計
> SELECT room, COUNT(*) FROM sensor_readings GROUP BY room;
```

### MQTT メッセージ監視

```bash
# 全トピックをリッスン
mosquitto_sub -h localhost -t "sensor/#" -v
```

### API レスポンス確認

```bash
# ヘルスチェック
curl http://localhost:5000/api/health | jq

# センサー情報
curl http://localhost:5000/api/sensors | jq

# 計測値
curl "http://localhost:5000/api/readings?limit=5" | jq
```

## 環境別トラブルシューティング

### Windows (WSL2)

- ファイルシステムのパフォーマンス: `/mnt/c` より `/home` に配置
- Docker デスクトップのリソース制限確認

### Mac

- Docker Desktop メモリ配分 (推奨: 4GB+)
- ボリュームマウント パフォーマンス

### Linux

- Docker デーモンが起動しているか確認
- ポート 1883, 5000 が予約済みでないか

## パフォーマンス最適化

### センサー生成最適化

- SENSOR_INTERVAL を 10秒以上に設定
- センサー数を 5個以下に削減

### DB 最適化

- 定期的に cleanup_old_data() を実行
- インデックスを確認

### MQTT 最適化

- QoS レベルを 0 に下げる
- トピック数を削減

## 本番運用チェックリスト

- [ ] ログレベルが WARNING 以上に設定されている
- [ ] 定期的なデータベースクリーンアップが実行される
- [ ] バックアップが設定されている
- [ ] MQTT 認証が有効化されている
- [ ] メモリ・CPU 制限が設定されている
- [ ] ヘルスチェック エンドポイント監視
- [ ] セキュリティパッチが適用されている

---

**問題が解決しない場合**: ステータスコードとエラーメッセージ全文を記録して保存してください。
