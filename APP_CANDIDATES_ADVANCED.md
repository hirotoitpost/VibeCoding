# アプリケーション候補 - 中級・発展プロジェクト

> **参照**: [APP_CANDIDATES.md](APP_CANDIDATES.md) (基礎・初級), [APP_CANDIDATES_SPECIAL.md](APP_CANDIDATES_SPECIAL.md) (特殊), [APP_CANDIDATES_OVERVIEW.md](APP_CANDIDATES_OVERVIEW.md) (難易度定義)

---

## ⭐⭐⭐ フェーズ 3.3: 中級プロジェクト（難易度 ⭐⭐⭐）

### 候補 3A: スマートホーム IoT ハブ

**説明**: 複数の IoT デバイス（シミュレーション）を制御する集中管理システム。

**技術スタック**:
- **言語**: Python + JavaScript | **プロトコル**: MQTT
- **API**: REST API（Express) | **フロントエンド**: React ダッシュボード
- **コンテナ**: Docker Compose

**要件**:
- デバイス登録・管理 | リアルタイムデータ取得
- リモート制御（ON/OFF）| スケジュール設定
- ログ記録 | マイクロサービス構成

**Vibe Coding の学習ポイント**:
- ✅ 複数サービスの統合 | ✅ MQTT プロトコル
- ✅ リアルタイム処理 | ✅ リレーショナルDB基礎

**推定期間**: 1-2 週間

---

### 候補 3B: スマートコントラクト DApp

**説明**: Ethereum ブロックチェーン上のシンプルな DApp（トークン発行・転送）。

**技術スタック**:
- **言語**: Solidity + JavaScript | **フレームワーク**: Hardhat
- **ブロックチェーン**: Sepolia テストネット | **Web3**: ethers.js

**要件**:
- ERC-20 トークン実装 | スマートコントラクト基本操作
- Web UI から操作可能 | テストネットデプロイ

**Vibe Coding の学習ポイント**:
- ✅ スマートコントラクト基礎 | ✅ ブロックチェーン概念
- ✅ Web3.js 統合 | ✅ テストネット操作

**推定期間**: 1-2 週間

---

### 候補 3C: 動画処理・自動字幕生成ツール

**説明**: MP4 ファイルから字幕を自動生成し、動画に合成。

**技術スタック**:
- **言語**: Python | **ライブラリ**: FFmpeg, OpenAI Whisper
- **処理**: 音声抽出 → 文字起こし → 合成

**要件**:
- MP4 から音声抽出 | Whisper で文字起こし
- SRT 形式字幕生成 | FFmpeg で動画に合成
- バッチ処理 | 品質チューニング

**推定期間**: 3-5 日

---

## ⭐⭐⭐⭐ フェーズ 3.4: 発展プロジェクト（難易度 ⭐⭐⭐⭐）

### 候補 4A: IoT × Web × Mobile 統合システム

IoT ハブ + Web ダッシュボード + モバイルアプリの統合。

- **スタック**: Python MQTT + React Web + React Native Mobile
- **インフラ**: Docker Compose + 本番環境シミュレーション
- **推定期間**: 3-4 週間

---

### 候補 4B: AI ファインチューニング × Web API

カスタム LLM をファインチューニング → API 化 → Web 統合。

- **スタック**: Llama 2/Mistral + LoRA + FastAPI + Next.js
- **推定期間**: 2-4 週間

---

### 候補 4C: ドローン飛行制御システム

DroneKit を使用した自動飛行コントローラー（SITL）。

- **スタック**: Python DroneKit + SITL + Ardupilot
- **機能**: GPS ウェイポイント、自動飛行、センサーデータ収集
- **推定期間**: 2-3 週間

---

## 🔗 関連リンク

- [基礎・初級プロジェクト](APP_CANDIDATES.md)
- [特殊プロジェクト (ID 016-017)](APP_CANDIDATES_SPECIAL.md)
- [難易度定義 + テンプレート](APP_CANDIDATES_OVERVIEW.md)

---

**最終更新**: 2026年4月13日 | **バージョン**: 1.0
