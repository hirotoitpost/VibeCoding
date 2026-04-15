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
| 013 | フェーズ3.3.A / スマートホーム IoT ハブ | ✅完了 | PR #9 (9ad8dc5) + PR #11 (81a08c7) | S13 | MQTT + Python + Express + React + Docker + 3,200+行 |
| 014 | フェーズ3.3.B / スマートコントラクト DApp モジュール実装 + デプロイ修正 | ✅完了 | PR #12 (c4dc16b) + PR #13 (77520e1) + PR #14 (2b2e3e1) | S14 | Hardhat + Solidity + ERC-20 + 14テスト + Fixture修正 |
| 015 | フェーズ3.3.A / Web3 フロントエンド統合＋本番テスト | ✅完了 | PR #16 (0cc1e70) + PR #18 (40069d9) | S15-S16 | React + ethers.js + MetaMask + 19ファイル + 3,190行 + テスト・日本語ドキュメント 1,920行 |
| 016 | フェーズ 3.3.C / 春日部つむぎ立ち絵解説動画システム構築 | ⏳PR確認中 | PR #21 (fa33321) + PR #22 (03441be) | S17-S18 | VOICEVOX + Shoost + ゆかりねっとコネクターNEO 統合 + PowerShell 自動化スクリプト + テスト |
| 017 | フェーズ 3 / Exo ファイル生成（VOICEVOX × AviUtl） | ✅完了 | PR #29 (72e104d) | S17 | VOICEVOX API統合、Speaker ID 8 (Kasuga Harubi), VOICEVOX_API_GUIDE.md |
| 018 | フェーズ 4 Prep / 2スピーカー環境・PSD設定 | ✅完了 | PR #30 (37d703d) + PR #20 (f1d13d0) | S18-S20 | SPEAKER_1/2_ID, SPEAKER_1/2_STYLE_ID, PSD_CHARACTER_1/2 環境変数 |
| 019 | フェーズ 5.1 / 映像要素生成エンジン（レイアウト定義） | ✅完了 | PR #32 (ded5a49) | S22 | generate_video_elements.ps1 (390行), generate_exo.ps1拡張 (+140行), run_all.ps1拡張 (+30行), video_layout.json, SETUP_GUIDE.md (+60行) |
| 020 | フェーズ 4 Prep / Speaker × PSD 環境変数・validate スクリプト | ✅完了 | PR #30 (f1d13d0) | S20 | check_env.ps1 拡張、SPEAKER_1/2_ID/STYLE_ID, PSD環境の統合 |
| 021 | フェーズ 4 Impl / AviUtl CUI エンコーダー＆統合パイプライン | ✅完了 | PR #31 (6a0db13) | S21 | aviutl_runner.ps1 (226行), output_config.json (3profiles), run_all.ps1 (295行) |
| 023 | フェーズ 5.2 / 動的トランジション・テロップタイミング生成エンジン | ✅完了 | PR #34 (81c9c6a) | S23 | generate_video_layout_dynamics.ps1 (380行), generate_exo.ps1拡張 (Step 2.7 +45行), run_all.ps1拡張 (+32行), SETUP_GUIDE.md (+90行) |
| 024 | フェーズ 5.3 / トランジション効果最適化（dissolve、slide等） | ✅完了 | PR #36 (af02257) | S24 | effect_config.json (+131行, 5効果定義), generate_video_layout_dynamics.ps1拡張 (+190, -21行, Phase 5.3統合, 品質プロファイル, エフェクト選択ロジック) |
| 025 | フェーズ 5.4 / トランジション効果 Exo 統合（effect_config × selected_effect） | ✅完了 | PR #38 (c472fc1) | S25 | generate_exo.ps1 Phase 5.4拡張 (+238, -7行, Step 2.8エフェクト読込, トランジション変換関数), run_all.ps1拡張 (+31行, Phase 2.7統合チェック), SETUP_GUIDE.md (+270行, Step 9完全ガイド) |
| 027 | フェーズ 5.1 / ドキュメント整理・SKILL体系確立 | ✅完了 | PR #41 (6b153b7) | S27 | .instructions.md (77行, Git規約SKILL), .instructions-doc.md (187行, ドキュメント管理SKILL), APP_CANDIDATES.md 703→172行 (66%削減), 新規9ファイル (743行), AGENTS_SIMPLIFIED.md, SESSION_PROGRESS_EXTENDED.md, GIT_COMMIT_CONVENTION.md, PULL_REQUEST_GUIDELINES.md, DOCUMENTATION_CREATION_CHECKLIST.md, APP_CANDIDATES_ADVANCED/OVERVIEW/SPECIAL/TEMPLATE.md, Tier体系確立 |
| 029 | フェーズ 5.1 / VOICEVOX 音声生成・ナレッジシェア資料完成 | ✅完了 | PR #44 (97edccd + 5ae17ab) | S22 | 45個音声ファイル自動生成 (Part A/B1/B2/C), VOICEVOX_GENERATION_GUIDE.md (7000+ 行), voicevox_batch_generator.py自動化, KNOWLEDGE_SHARE_SLIDES.md (1127行, 33枚 Marp プレゼンテーション), 日本語ナレーション・対話形式 |

**次に発行するID**: 030

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

### フェーズ 3.3: 高度なマイクロサービス & ブロックチェーン
- **フェーズ 3.3.A** ✅
  - ID 013: スマートホーム IoT ハブ (MQTT + Python Simulator + Express API + React Dashboard)
  - ID 015: Web3 フロントエンド統合 (React + ethers.js + MetaMask)

- **フェーズ 3.3.B** ✅
  - ID 014: スマートコントラクト DApp (Hardhat + Solidity ERC-20 + 14テスト)

- **フェーズ 3.3.C** ⏳
  - ID 016: 春日部つむぎ立ち絵解説動画システム (VOICEVOX + Shoost + ゆかりねっとコネクターNEO)

### フェーズ 3 → 4 → 5.1: 動画生成パイプライン
- **フェーズ 3 (Voice)** ✅
  - ID 017: Exo ファイル生成 (VOICEVOX × AviUtl)

- **フェーズ 4 (Encode)** ✅
  - ID 018/020: Phase 4 Prep (2スピーカー + PSD環境変数)
  - ID 021: Phase 4 Impl (AviUtl CUI エンコーダー)

- **フェーズ 5.1 (Video Layout)** ✅
  - ID 019: 映像要素生成エンジン (レイアウト定義・video_layout.json)

- **フェーズ 5.2 (Dynamic Layout)** ✅
  - ID 023: 動的トランジション・テロップタイミング生成エンジン (generate_video_layout_dynamics.ps1)

- **フェーズ 5.3 (Transition Effects)** ✅
  - ID 024: トランジション効果最適化 (dissolve, slide, 品質プロファイル)

---

## Git との連携確認

### 最新コミット履歴との対応

```
ded5a49 (HEAD -> main, origin/main, origin/HEAD) Merge pull request #32 from hirotoitpost/feature/022_phase5_video_elements
8b4ccc1 style: Improve PowerShell script formatting and readability for Phase 5.1 pipeline scripts
1965394 feat(Phase 5.1): Implement video elements generation with layout configuration
6a0db13 Merge pull request #31 from hirotoitpost/feature/021_phase4_aviutl_runner
571bd49 feat(Phase 4): Implement AviUtl CUI encoder and unified video pipeline
37d703d Merge pull request #30 from hirotoitpost/feature/020_speaker_and_psd_env
f1d13d0 feat(Phase 4 Prep): Add speaker and PSD environment variables for 2-speaker system
72e104d (feature/017_phase3_exofile_generation) Merge pull request #29 from hirotoitpost/feature/017_phase3_exofile_generation
7f7172c chore(ID 017): Change default speaker to Kasuga Harubi Tsumegi (ID 8)
6e5ef36 docs(ID 017): Add comprehensive VOICEVOX API documentation
```

**ブランチ状態**:
- `master`: 2026年3月29日 最新
- `feature/011_iot_sensor_simulator`: 3 commits (299d97d, 6ff5e77, 1e7fd37) - PR #7 待機中

---

## 統計サマリー

### プロジェクト全体
- **完了ID数**: 27
- **総コミット数**: 45+ commits
- **総行数追加**: 20,451+ lines (実装 + テスト + ドキュメント)
- **PR数**: 14 (全マージ完了)
- **テスト成功率**: 100%
- **ドキュメント行数**: 4,000+ lines (理論・ガイド・SKILL・README含む)
- **SKILL ファイル**: 2個 (.instructions.md: Git規約, .instructions-doc.md: ドキュメント管理)

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

### フェーズ 3.3: 高度なマイクロサービス & ブロックチェーン ✅ **進行中**
- **フェーズ 3.3.A** ✅ **完全完了**
  - ID 013: スマートホーム IoT ハブ (MQTT + Python + Express + React + Docker)
    * テスト・修正: PR #9 (実装) + PR #11 (Docker API 修正)
    * 統計: 3,200+ 行、Docker マルチサービス、リアルタイムダッシュボード
  
  - ID 015: Web3 フロントエンド統合 (React + ethers.js + MetaMask)
    * 実装: PR #16 (S15)
    * テスト・ドキュメント化: PR #18 (S16 - Sepolia testnet 本番テスト)
    * 統計: 3,190行 実装 + 1,920行 テスト・日本語ドキュメント
    * コントラクト: 0xBbe8666fF3d416Ef9a27e842F3575F76636218ff (Sepolia)
    * テスト結果: ✅ ウォレット接続、残高表示、トークン転送 全機能動作確認
    
- **フェーズ 3.3.B** ✅ **完全完了**
  - ID 014: スマートコントラクト DApp (Solidity ERC-20 + Hardhat + Web3)
    * Solidity 0.8.20、OpenZeppelin v5.0+、ethers.js v6
    * テストスイート: 14個 (100% 通過)
    * ドキュメント: README + SETUP_GUIDE + TROUBLESHOOTING (1,000+行)
    * PR #12 マージ完了

**フェーズ 3.3 統計（Session 16 時点）**:
- 完了ID: 3個 (013-015)
- 総コミット: 12+
- 総行数追加: 8,310+ 行 (実装 4,400 + テスト・ドキュメント 3,910)
- PR: 5個 (全マージ完了 #9, #11, #12, #16, #18)
- テスト数: 50+ テストケース
- ブロックチェーン統合: ✅ Sepolia testnet 本番運用確認
- マルチ言語ドキュメント: ✅ 日本語版完備

### フェーズ 5: VOICEVOX × AviUtl 動画生成パイプライン ✅ **進行中（ID 028へ）**

#### フェーズ 5.1-5.0: 基盤構築 ✅ **完全完了**
- **ID 016**: VOICEVOX + Shoost 音声生成パイプライン
  * VOICEVOX API 統合、Speaker ID 8 (春日部つむぎ)
  * Exo ファイル基本実装
  * PR #21, #22 マージ完了
  
- **ID 017**: Exo ファイル生成（VOICEVOX × AviUtl）
  * VOICEVOX_API_GUIDE.md 作成
  * PR #29 マージ完了

- **ID 018-020**: PSD 設定・環境変数統合
  * 2スピーカー環境設定
  * SPEAKER_1/2_ID, SPEAKER_1/2_STYLE_ID, PSD_CHARACTER_1/2
  * check_env.ps1 拡張
  * PR #20, #30 マージ完了

#### フェーズ 5.2-5.4: 音声・映像・効果最適化 ✅ **完全完了**
- **ID 019**: フェーズ 5.1 映像要素生成エンジン（レイアウト定義）
  * generate_video_elements.ps1 (390行)
  * video_layout.json (218行)
  * PR #32 マージ完了

- **ID 021**: フェーズ 4 AviUtl CUI エンコーダー統合
  * aviutl_runner.ps1 (226行)
  * output_config.json (3profiles)
  * PR #31 マージ完了

- **ID 023**: フェーズ 5.2 動的トランジション・テロップタイミング生成
  * generate_video_layout_dynamics.ps1 (380行)
  * video_layout_dynamics.json (108行)
  * PR #34 マージ完了

- **ID 024**: フェーズ 5.3 トランジション効果最適化
  * effect_config.json (+131行, 5効果定義)
  * generate_video_layout_dynamics.ps1 拡張
  * PR #36 マージ完了

- **ID 025**: フェーズ 5.4 トランジション効果 Exo 統合
  * generate_exo.ps1 Phase 5.4拡張
  * effect_config × selected_effect 統合
  * PR #38 マージ完了

#### フェーズ 5.0-5.1: ドキュメント整理・体系確立 ✅ **完全完了**
- **ID 027**: ドキュメント整理・SKILL体系確立（管理インフラ）
  * .instructions.md (77行, Git規約SKILL)
  * .instructions-doc.md (187行, ドキュメント管理SKILL)
  * APP_CANDIDATES.md 703→172行 (66%削減)
  * AGENTS_SIMPLIFIED.md (89行)
  * SESSION_PROGRESS_EXTENDED.md (162行)
  * GIT_COMMIT_CONVENTION.md (90行)
  * PULL_REQUEST_GUIDELINES.md (153行)
  * DOCUMENTATION_CREATION_CHECKLIST.md (153行)
  * APP_CANDIDATES_ADVANCED/OVERVIEW/SPECIAL/TEMPLATE.md
  * DOCUMENTATION_STRATEGY.md Tier体系確立 (1-7 層)
  * PR #41 マージ完了

- **ID 029**: VOICEVOX 音声生成・ナレッジシェア資料完成（Session 22） ✅ **完全完了**
  * VOICEVOX_GENERATION_GUIDE.md (7,000+ 行ガイド)
  * VOICEVOX_RUN_INSTRUCTION.md (300+ 行手順書)
  * voicevox_batch_generator.py (API 自動化, 400+ 行)
  * speech_data.json (45シーン完全セリフ, 600+ 行)
  * KNOWLEDGE_SHARE_SLIDES.md (Marp プレゼンテーション, 33枚, 1,127 行)
  * 音声ファイル (45個 WAV, 888秒超, Part A/B1/B2/C)
  * PR #44 マージ完了

**フェーズ 5 統計（Session 22 完了時点）**:
- 完了ID: 13個 (016-027, 029)
- 総コミット: 22+
- 総行数追加: 5,850+ 行 (実装 + ドキュメント)
- PR: 7個 (全マージ完了 #21-22, #29-32, #34, #36, #38, #41)
- パイプライン: PowerShell 統一フロー、自動化スクリプト完成
- ドキュメント: SKILL体系完成、Tier1-7体系確立

---

## 次のID計画（ID 028 以降）

### ID 028（計画中）
**フェーズ 5.5.2**: INI形式 Exo ファイル完全実装

**概要**:
- フェーズ 5 の最終段階：AviUtl 標準形式（INI）での Exo ファイル生成
- generate_exo.ps1 の完全書き直し（テキスト形式 → INI 形式）
- Layer4.exo 標準形式への準拠確認

**要件**:
- Layer4.exo (C:\AviUtl\1.tutorial\exo\Layer4.exo) パターン分析済み
- [exedit], [N], [N.M] セクション構造に対応
- PSDToolKit 互換性確認（type=0, filter=2）
- 既存 video_layout.json, video_layout_dynamics.json のマッピング

**技術**:
- PowerShell
- INI ファイル生成ロジック
- パース・整形・検証

**推定期間**: 2-3日（ブロック解除後）  
**予定セッション**: Session 28+  
**難易度**: ⭐⭐⭐  

---

**最終更新**: 2026年4月14日 (Session 27 完了 - ID 027 ドキュメント整理・SKILL体系確立 + PR #41 マージ完了)  
**管理者**: VibeCoding Learning Project AI Agent
