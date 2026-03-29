## PR テンプレート - ID 011 IoT センサーシミュレーター

**PR タイトル**:
```
[ID 011] IoT センサーシミュレーター - Phase 3.2.B フルスタック実装完成
```

**PR 本文**:
```markdown
## 📋 概要

ID 011: フェーズ 3.2.B IoT センサーシミュレーター（MQTT + Web ダッシュボード）の フルスタック実装を完成させました。

リアルタイム温度・湿度センサーをシミュレーション し、MQTT ブローカーで配信・DB保存・Web ダッシュボードで可視化する統合システムです。

---

## ✨ 実装内容

### 1️⃣ コアモジュール

| ファイル | 目的 | 行数 |
|--------|------|------|
| `src/config.py` | 環境変数・設定一元管理 | 180 |
| `src/sensor_simulator.py` | 温度・湿度データ生成 | 280 |
| `src/mqtt_client.py` | MQTT パブリッシャー・サブスクライバー | 320 |
| `src/database.py` | SQLite 時系列データ管理 | 380 |
| `src/alarm_manager.py` | アラーム判定・生成・デダップリング | 420 |
| `src/simulator_main.py` | 統合実行エンジン | 200 |

**特徴**:
- ✅ 環境変数による柔軟な設定
- ✅ スレッド化されたバックグラウンド処理
- ✅ MQTT QoS 1 確実配信
- ✅ SQLAlchemy ORM での DB抽象化
- ✅ アラーム デダップリング機能

### 2️⃣ Web ダッシュボード

| ファイル | 目的 | 行数 |
|--------|------|------|
| `web/app.py` | Flask REST API | 180 |
| `web/templates/dashboard.html` | ダッシュボード HTML | 120 |
| `web/static/style.css` | レスポンシブ UI スタイル | 380 |
| `web/static/dashboard.js` | リアルタイム更新・グラフ (Chart.js) | 320 |

**API エンドポイント**:
```
GET  /                  ダッシュボードページ
GET  /api/sensors       センサー一覧
GET  /api/readings      計測値 (ページネーション対応)
GET  /api/readings/latest  最新計測値
GET  /api/statistics    統計情報
GET  /api/alarms        アラーム履歴
```

**UI 機能**:
- ✅ リアルタイムセンサーカード表示
- ✅ 温度・湿度 時系列グラフ (Chart.js)
- ✅ アラーム一覧・ハイライト
- ✅ 完全レスポンシブ設計 (PC/タブレット/モバイル)

### 3️⃣ テストスイート (24 テストケース)

```bash
pytest tests/ -v

# テストファイル
tests/test_config.py            (6テスト)
tests/test_sensor_simulator.py  (8テスト)
tests/test_alarm_manager.py     (10テスト)
```

### 4️⃣ Docker & コンテナ化

- `Dockerfile.simulator` - センサーシミュレーター
- `Dockerfile.webapp` - Flask Web App
- `docker-compose.yml` - Mosquitto MQTT + マルチコンテナ統合

### 5️⃣ ドキュメント

- `README.md` - プロジェクト概要・セットアップ・API リファレンス (380行)
- `TROUBLESHOOTING.md` - 7つの一般的な問題・デバッグスキル・最適化ガイド
- `.env.example` - 環境変数テンプレート

---

## 📊 統計

| メトリクス | 値 |
|-----------|-----|
| **総ファイル数** | 22個 |
| **総行数** | 4,800+ |
| **Python コード** | 2,200+ |
| **Web/HTML** | 800 |
| **テスト** | 400+ |
| **ドキュメント** | 1,400+ |
| **テストケース数** | 24個 |

---

## 🚀 クイックスタート

```bash
# 1. セットアップ
cp .env.example .env

# 2. コンテナ起動
docker-compose up -d

# 3. ダッシュボード
http://localhost:5000

# 4. テスト実行
pytest tests/ -v
```

---

## 🔍 検証ポイント

- [ ] `docker-compose up -d` で 4コンテナが起動
- [ ] http://localhost:5000 でダッシュボード表示
- [ ] センサーカード に温度・湿度リアルタイム表示
- [ ] グラフが自動更新（5秒間隔）
- [ ] MQTT: `mosquitto_sub -t "sensor/#"` でデータ流れ確認
- [ ] API: `curl http://localhost:5000/api/sensors` でレスポンス確認
- [ ] テスト: `pytest tests/` すべて成功
- [ ] ログ: `docker-compose logs -f webapp` でエラーなし

---

## 🎯 Vibe Coding 学習ポイント

✅ **AI が得意な領域**:
- 複数モジュール統合の実装
- テストコード自動生成
- Flask REST API 設計

⚠️ **AI の判断が必要**:
- MQTT トピック設計
- アラームロジック
- DB スキーマ最適化

❌ **AI が対応困難**:
- Docker・環境構築の詳細
- Mosquitto ブローカー設定
- ハードウェア連携

---

## 📝 備考

- 次のセッション: ID 012 (チャットボット Web App) で Flask経験を活かす予定
- インフラ: AWS Lambda / Fargate への デプロイ対応準備中
- スケール検討: 複数地点・複数センサーの階層型MQTT設計

---

**リンク**:
- 📄 [APP_CANDIDATES.md](APP_CANDIDATES.md#候補-2b-iot-センサーシミュレーター推奨)
- 📚 [docs/vibe_coding_instruction_design.md](docs/vibe_coding_instruction_design.md)
- 🛠️ [GIT_WORKFLOW.md](GIT_WORKFLOW.md)

---

**レビュー対象**:
- [ ] コード品質・保守性
- [ ] テストカバレッジ
- [ ] ドキュメント完成度
- [ ] 本番環境対応度

---

**Author**: VideCoding AI Agent  
**Date**: 2026-03-29 (Session 9)  
**Commits**: 2個 (299d97d + 6ff5e77)
```

---

## 手順

1. **GitHub Web UI で以下 URL にアクセス**:
   ```
   https://github.com/hirotoitpost/VibeCoding/pull/new/feature/011_iot_sensor_simulator
   ```

2. **PR タイトル (Title)** に以下を入力:
   ```
   [ID 011] IoT センサーシミュレーター - Phase 3.2.B フルスタック実装完成
   ```

3. **説明 (Description)** に、上の PR 本文を貼り付け

4. **Create pull request** をクリック

---

**PR 作成後のステップ**:
- [ ] GitHub で PR の内容確認
- [ ] CI チェック確認（ある場合）
- [ ] Approve & Merge
- [ ] ローカルで `git pull origin master`
- [ ] SESSION_PROGRESS.md を更新・コミット
