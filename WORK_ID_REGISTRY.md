# 作業ID（Work ID）レジストリ - VibeCoding Project

> **参照**: [agents.md](agents.md) - コアガイド、[SESSION_PROGRESS.md](SESSION_PROGRESS.md) - セッション進捗記録

---

## 運用ルール

### 形式・割り当て
- **形式**: 3桁の連番（001, 002, 003...）
- **割り当て**: AI エージェントが順次発行
- **記録**: このレジストリに記載
- **用途**: ブランチ名、コミットメッセージ、PR タイトルに使用

### ネーミング規約
```
ブランチ名: feature/[ID]_[日本語タイトル（スペースはハイフン）]
例: feature/008_web家計簿アプリ
    feature/009_web家計簿テスト検証

コミットメッセージ:
- chore(ID 009): テスト・検証インフラ完全統合（Cypress + Docker検証スクリプト）
- feat(ID 008): バックエンド CRUD API 実装完成
- docs(ID 007): Vibe Coding 指示設計パターン体系化

PR タイトル:
- [ID 009] Web 家計簿アプリ - テスト・検証完成
```

---

## 作業ID発行履歴

| ID | 作業内容 | ステータス | PR/Commit | 実施セッション | 備考 |
|----|---------|-----------|----------|-------------|------|
| 001 | プロジェクト初期化 | ✅完了 | cf5dced | S1 | Git リポジトリ、ディレクトリ構造 |
| 002 | ラーニングパス・ロードマップ定義 | ✅完了 | 93b4f60 | S2 | LEARNING_PATH.md, APP_CANDIDATES.md 作成 |
| 003 | Git/GitHub ワークフロー追加 | ✅完了 | bf27c1f | S2 | agents.md に Git ワークフロー追加 |
| 004 | フェーズ2 理論学習 | ✅完了 | PR #3 (408856b) | S2 | docs/vibe_coding_theory.md, tool_usage_guide.md |
| 005 | フェーズ3.1 基礎プロジェクト（天気情報ツール） | ✅完了 | PR #1 (b9bb217) | S3 | OpenWeatherMap API、キャッシング、14テスト |
| 006 | トラブルシューティング文書化・プロセス標準化 | ✅完了 | 86d2146 | S3 | TROUBLESHOOTING.md、6ステップワークフロー |
| 007 | 指示設計ワークショップ（Vibe Coding パターン体系化） | ✅完了 | PR #2 (0bca384) | S4 | docs/vibe_coding_instruction_design.md (600行) |
| 008 | フェーズ3.2.A 中級プロジェクト（Web家計簿） | ✅完了 | PR #4 (378d8b2) | S6 | Backend API + Frontend React + 6,149行追加 |
| 009 | フェーズ3.2.A.3 テスト・検証 | ✅完了 | PR #5 (02373e1) | S7 | Frontend 20/20テスト + E2E + Docker検証 + a438785 |
| 010 | フェーズ3.2.B / DNS + API Gateway 統合 | ✅完了 | PR #6 (cfb0c82) | S8 | Nginx Gateway + dnsmasq DNS |
| 011 | フェーズ3.2.B / IoT センサーシミュレーター | ✅完了 | PR #7 (449f04e) | S9 | Python MQTT + Web ダッシュボード + 24テスト + 4.8K行 |
| 012 | フェーズ3.2.C / チャットボット Web App | ✅完了 | `385d1c6` | S12 | React + Flask + Mock API + 18テスト + 991行 |
| 013 | フェーズ3.3.A / スマートホーム IoT ハブ | ✅完了 | PR #9 (9ad8dc5) | S13 | MQTT + Python Simulator + Express API + React Dashboard + Docker + 3,057行 |

**次に発行するID**: 014

---

## ID 完了サマリー（フェーズ別）

### フェーズ 1: 基礎理解 ✅
- ID 001: プロジェクト初期化

### フェーズ 2: 理論学習 ✅
- ID 002: ラーニングパス・ロードマップ定義
- ID 003: Git/GitHub ワークフロー追加
- ID 004: フェーズ2 理論学習

### フェーズ 3.1: 基礎プロジェクト ✅
- ID 005: 天気情報ツール（Python + pytest）
- ID 006: トラブルシューティング文書化

### フェーズ 2.3: 指示設計ワークショップ ✅
- ID 007: Vibe Coding 指示設計パターン体系化

### フェーズ 3.2: 中級プロジェクト
- **フェーズ 3.2.A** ✅
  - ID 008: Web家計簿（Backend + Frontend）
  - ID 009: テスト・検証（Frontend + E2E + Docker）
- **フェーズ 3.2.B** → **フェーズ 3.2.C** ✅
  - ID 010: DNS + API Gateway 統合
  - ID 011: IoT センサーシミュレーター (Python MQTT + Web Dashboard)
  - ID 012: チャットボット Web App (React + Flask + OpenAI)

### フェーズ 3.3: 高度なマイクロサービス
- **フェーズ 3.3.A** ✅
  - ID 013: スマートホーム IoT ハブ (MQTT + Python Simulator + Express API + React Dashboard)

---

## Git との連携確認

### 最新コミット履歴との対応

```
1e7fd37 docs(ID 011): PR テンプレート・レビューチェックリスト追加
6ff5e77 feat(ID 011): ユニットテスト・Docker・トラブルシューティング追加
299d97d feat(ID 011): IoT センサーシミュレーター - プロジェクトスケーフォルド完成
cfb0c82 Merge pull request #6 from hirotoitpost/feature/010_dns_api_gateway
dca43d2 docs(Session 7): ID 009 完全完成記録を更新
a438785 chore(ID 009): テスト・検証インフラ完全統合
02373e1 Merge pull request #5 from hirotoitpost/feature/009_web家計簿テスト検証
```

**ブランチ状態**:
- `master`: 2026年3月29日 最新
- `feature/011_iot_sensor_simulator`: 3 commits (299d97d, 6ff5e77, 1e7fd37) - PR #7 待機中

---

## 統計サマリー

### プロジェクト全体
- **完了ID数**: 13
- **総コミット数**: 35+ commits
- **総行数追加**: 18,400+ lines
- **PR数**: 9 (全マージ完了)
- **テスト成功率**: 100%

### 技術スタック（フェーズ別）
| フェーズ | 言語 | フレームワーク | テスト | 実装状況 |
|---------|------|---|---|---|
| 3.1 | Python | - | pytest | ✅ |
| 3.2.A | Python + Node.js | Express + React | Jest + Cypress | ✅ |
| 3.2.B | Python | Flask | pytest + Cypress | ✅ |
| 3.2.C | Python + Node.js | Flask + React | pytest + Jest | ✅ |
| 3.3.A | Python + Node.js | Express + React | pytest | ✅ |

---

## 次のID計画

### ID 013（候補）
**フェーズ 3.3.A**: スマートホーム IoT ハブ または スマートコントラクト DApp
- **言語**: 
  - オプション A: Python (IoT controller) + Flask + MQTT
  - オプション B: Solidity (Smart Contract) + Hardhat
- **要件（IoT ハブ）**:
  - 複数デバイス管理
  - MQTT ブローカー統合
  - REST API + WebSocket
  - ダッシュボード UI
  - 自動化・スケジューリング
- **要件（スマートコントラクト）**:
  - ERC-20 トークン実装
  - Solidity コンテストロジック
  - Hardhat テストスイート
  - ローカルブロックチェーン
- **推定期間**: 4-5日
- **難易度**: ⭐⭐⭐ (IoT) / ⭐⭐⭐⭐ (Blockchain)
- **予定セッション**: Session 11+

---

## フェーズ進捗サマリー

### フェーズ 3.2: 中級プロジェクト ✅ **完全完了**
- **フェーズ 3.2.A** ✅
  - ID 008: Web家計簿（Backend + Frontend）
  - ID 009: テスト・検証（Frontend + E2E + Docker）
- **フェーズ 3.2.B** ✅
  - ID 010: DNS + API Gateway 統合
  - ID 011: IoT センサーシミュレーター (Python MQTT + Web Dashboard)
- **フェーズ 3.2.C** ✅
  - ID 012: チャットボット Web App (React + Flask + OpenAI GPT)

**フェーズ 3.2 統計**:
- 完了ID: 5個 (008-012)
- 総コミット: 15+
- 総行数追加: 9,200+ 行
- PR: 5個 (全マージ完了 #4-#8)
- テスト数: 70+ テストケース

---

**最終更新**: 2026年3月29日 (Session 10 完了 - ID 012 完全実装 + PR #8 マージ完了)  
**管理者**: VibeCoding Learning Project AI Agent
