# VibeCoding 学習プロジェクト - AIエージェント作業ガイド

> **最終更新**: 2026年3月29日（Session 12 完了 + ID 012 テスト・デプロイ完成）  
> **ステータス**: Phase 3.2.C 完了 ✅（ID 010-012 完了），ID 013 準備中

---

## プロジェクト概要

### 目的
**Vibe Codingの全体像を理解し、実践的なスキルを獲得する**

- 自然言語 → AI実装のパラダイム習得
- AIが担当できる領域と限界の把握
- 段階的な開発実践
- ナレッジシェア資料（スライド＋動画）の提供

### 学習の哲学
> **「AIに任せられることを見極める」** — 開発環境、ランタイム、SDKについて、どこまで無知でいられるか？

### プロジェクト情報
- **開始日**: 2026年3月26日
- **環境**: Windows, VS Code, Git
- **技術スタック**: Python, JavaScript/Node.js, Docker, React, Express
- **進捗**: **Phase 3.2.C 完了** ✅（ID 010-012 完了），Phase 3.3 準備中

---

## 学習フェーズ（4段階）

| フェーズ | タイトル | ステータス | 目標 |
|---------|---------|----------|------|
| **フェーズ1** | 基礎理解 | ✅完了 | 環境構築、プロセス理解 |
| **フェーズ2** | 理論学習 | ✅完了 | VibeCoding基本概念、ベストプラクティス |
| **フェーズ3** | 実装（段階的） | 🔄進行中 | 複数の小規模アプリケーション開発 |
| **フェーズ4** | 成果物化 | ⏳予定 | ナレッジシェア（スライド+動画） |

詳細は [LEARNING_PATH.md](LEARNING_PATH.md) を参照

---

## プロジェクト構成

```
VibeCoding/
├── 📋 ドキュメント
│   ├── agents.md ..................... このファイル（コアガイド）
│   ├── README.md ..................... GitHub用概要
│   ├── SETUP.md ..................... 開発環境セットアップ
│   │
│   └── 📚 ドキュメント体系
│       ├── SESSION_PROGRESS.md ....... セッション進捗記録（S1-S9）
│       ├── WORK_ID_REGISTRY.md ...... 作業ID管理・発行履歴
│       ├── COMPLIANCE_SECURITY.md ... ハウスキーピング・セキュリティ
│       ├── DOCUMENTATION_STRATEGY.md  ドキュメント管理戦略
│       │
│       ├── DEVELOPMENT_PROCESS.md ... デバッグワークフロー（6ステップ）
│       ├── GIT_WORKFLOW.md ........... Git/GitHub運用ガイド
│       ├── MERGE_CONFLICT_GUIDE.md .. 競合解消プロセス
│       ├── LEARNING_PATH.md ......... ラーニングロードマップ
│       ├── APP_CANDIDATES.md ........ プロジェクト候補
│       │
│       └── 📖 理論・ガイド
│           ├── docs/vibe_coding_theory.md
│           ├── docs/vibe_coding_instruction_design.md
│           └── docs/vibe_coding_guide.md
│
├── 🧪 プロジェクト
│   ├── examples/01-basic/weather-tool/ ......................... ✅ Phase 3.1（Python）
│   ├── examples/02-intermediate/web-accounting-app/ ........... ✅ Phase 3.2.A（Python+React）
│   ├── examples/03-intermediate/iot-sensor-simulator/ ......... ✅ Phase 3.2.B（Python+MQTT）
│   └── examples/04-intermediate/chatbot-web-app/ ............. ✅ Phase 3.2.C（React+Flask+OpenAI）
│
├── 🔧 ユーティリティ
│   ├── scripts/ ........................... セットアップスクリプト
│   └── .env.example ....................... 環境変数テンプレート
│
└── ⚙️ Configuration
    ├── .gitignore .......................... Git除外設定
    └── VibeCoding.code-workspace .......... VS Code設定
```

---

## 主要ドキュメント一覧

### 📌 **実行ガイド** — 日常的に参照

| ドキュメント | 対象 | 用途 |
|------------|------|------|
| [DEVELOPMENT_PROCESS.md](DEVELOPMENT_PROCESS.md) | デバッグに行き詰まった時 | 6ステップワークフロー、AI指示パターン |
| [GIT_WORKFLOW.md](GIT_WORKFLOW.md) | Git/GitHub作業 | ブランチ戦略、コミット規約、PR手順 |
| [MERGE_CONFLICT_GUIDE.md](MERGE_CONFLICT_GUIDE.md) | マージ競合発生時 | 7ステップ競合解消、トラブルシューティング |

### 📚 **計画・ロードマップ** — フェーズ開始時

| ドキュメント | タイミング | 内容 |
|------------|----------|------|
| [LEARNING_PATH.md](LEARNING_PATH.md) | 各フェーズ開始時 | フェーズ目標、マイルストーン、実装要件 |
| [APP_CANDIDATES.md](APP_CANDIDATES.md) | フェーズ開始時 | プロジェクト候補、技術スタック、要件 |

### 📊 **進捗・管理** — セッション完了時

| ドキュメント | 更新頻度 | 内容 |
|------------|---------|------|
| [SESSION_PROGRESS.md](SESSION_PROGRESS.md) | 各セッション終了時 | セッション進捗、完了項目、統計 |
| [WORK_ID_REGISTRY.md](WORK_ID_REGISTRY.md) | 作業完了時 | Work ID発行履歴、統計、次のID計画 |

### 🔒 **ポリシー・戦略** — 参考資料

| ドキュメント | 確認タイミング | 内容 |
|------------|-------------|------|
| [COMPLIANCE_SECURITY.md](COMPLIANCE_SECURITY.md) | 定期レビュー（セッション開始時） | セキュリティ・コンプライアンスチェックリスト |
| [DOCUMENTATION_STRATEGY.md](DOCUMENTATION_STRATEGY.md) | 新規ドキュメント追加時 | ドキュメント管理、モジュール化戦略 |

### 📖 **理論・参考** — 実装中の参照

| ドキュメント | トピック | 行数 |
|------------|---------|------|
| [docs/vibe_coding_theory.md](docs/vibe_coding_theory.md) | Vibe Coding理論、指示設計哲学 | 250+ |
| [docs/vibe_coding_instruction_design.md](docs/vibe_coding_instruction_design.md) | 5段階フレームワーク、パターン集 | 600+ |

---

## 🤖 AI エージェント運用ルール

### 責務（AI エージェント = 私がやる）

#### ✅ Git 運用
1. **feature ブランチでの作業**
   - `git checkout -b feature/[ID]_[タイトル]` で新規ブランチ作成
   - コード実装・ドキュメント修正
   - `git add` と `git commit` で変更をコミット

2. **Push と PR 作成**
   - `git push origin feature/[ID]_[タイトル]` でリモートに Push
   - **GitHub Web UI から PR を作成**（PR URL は返す）
   - PR の説明文（body）に実装内容・検証内容を記載

3. **ドキュメント・レジストリの更新**
   - main ブランチで SESSION_PROGRESS.md, WORK_ID_REGISTRY.md を更新
   - `git add` と `git commit` でコミット
   - `git push origin main` で Push

#### ❌ 禁止事項（AI エージェント がしてはいけないこと）
- ❌ feature ブランチを main に `git merge` する
- ❌ PR を自分で Approve / Merge する
- ❌ `git push origin main` を直接実行（ドキュメント更新以外）
- ❌ PR のレビューコメントに返信（ユーザーの承認待ち）

### ユーザーの責務

#### ✅ PR レビュー・マージ
1. GitHub Web UI で PR の変更内容を確認
2. テスト、コードレビュー実施
3. 問題なければ **Approve & Merge** ボタンをクリック
4. ローカルで `git pull origin main` して同期

#### ✅ マージ後の確認
- ローカル main が最新状態か確認
- 必要に応じてコンテナテスト・動作確認

### Git ワークフロー（図解）

```
┌─────────────────────────────────────────────────────────────┐
│ AI エージェント 処理                                      │
├─────────────────────────────────────────────────────────────┤
│ 1. feature ブランチ作成・コミット                           │
│    $ git checkout -b feature/010_example                   │
│    $ git add . && git commit -m "feat(ID 010): ..."        │
│                                                             │
│ 2. Push & PR 作成                                           │
│    $ git push origin feature/010_example                   │
│    → GitHub Web UI で PR 作成                              │
│    → PR URL を返す                                         │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ ユーザー 処理（人間がやる）                               │
├─────────────────────────────────────────────────────────────┤
│ 3. PR レビュー・マージ                                      │
│    → GitHub Web UI で確認                                  │
│    → ✅ Approve & Merge                                    │
│                                                             │
│ 4. ローカル同期                                             │
│    $ git pull origin main                                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ AI エージェント 最終処理                                   │
├─────────────────────────────────────────────────────────────┤
│ 5. ドキュメント更新（必要に応じて）                         │
│    - SESSION_PROGRESS.md を main で編集                     │
│    - WORK_ID_REGISTRY.md を main で編集                     │
│    $ git add . && git commit -m "docs(Session X): ..."    │
│    $ git push origin main                                  │
└─────────────────────────────────────────────────────────────┘
```

### 違反時の対応

**違反が発生した場合**:
- AI エージェント が feature を main に直接マージしてしまった場合
- マージコミットが origin/main に Push されてしまった場合

**対応**:
1. ユーザーに即座に報告
2. ユーザーの指示に従い revert または修正
3. AGENTS.md のこのセクションを見直す

---

## 🔄 セッション間の自動引き継ぎシステム

### 新規セッション開始時の AI エージェント責務

**毎回、新規チャット冒頭で以下を自動実行**:

```
Step 1: 現在の進捗状況を確認
  $ git log --oneline main -3
  $ git branch -a | grep feature

Step 2: 最新ドキュメントをスキャン
  - main ブランチで SESSION_PROGRESS.md の最終セクションを確認
  - main ブランチで WORK_ID_REGISTRY.md で次のID を確認
  - APP_CANDIDATES.md で対象プロジェクト詳細確認

Step 3: 自動提示（ユーザーへ）
  💡 「Session X : ID YYY を実装します」
  📋 対象: [プロジェクト名]
  🛠️ 技術スタック: [言語/フレームワーク]
  📚 参考: [ドキュメントリンク]
  ⏱️ 推定期間: X 日
  
  👇 上記の内容でよろしいですか？
```

### AI エージェント自動提示テンプレート

**各セッション開始時、以下を自動生成して提示**:

```markdown
# 🎯 Session X オートブリーフィング

## 現在地の確認
- **前セッション**: Session X-1 (ID XXX 完了)
- **前回マージ**: Commit XXXXX - [PR リンク]
- **ローカル状態**: main 最新状態確認済み

## 今回の作業
- **ID**: YYY
- **プロジェクト**: [プロジェクト名]
- **フェーズ**: [Phase X.Y]
- **難易度**: [⭐⭐⭐]

## 技術スタック
- 言語: [Python / JavaScript]
- フレームワーク: [Flask / Express / React]
- 外部API: [OpenAI / MQTT等]
- ローカル実行: [docker-compose / npm]

## 実装内容（要件サマリー）
- 機能 A: [説明]
- 機能 B: [説明]
- テスト: [XX個のテストケース想定]

## 参考資料
- 📄 [APP_CANDIDATES.md](APP_CANDIDATES.md) - プロジェクト詳細
- 🛠️ [GIT_WORKFLOW.md](GIT_WORKFLOW.md) - Git運用ルール
- 💡 [DEVELOPMENT_PROCESS.md](DEVELOPMENT_PROCESS.md) - デバッグワークフロー

## ワークフロー確認
1. ✅ ブランチ作成: feature/YYY_[title]
2. ✅ コード実装 + テスト
3. ✅ git add & commit
4. ✅ git push & PR 作成（GitHub Web UI）
5. ⏳ ユーザーが PR マージ
6. ✅ SESSION_PROGRESS.md 更新と master push

---

**👇 質問や変更指示をお願いします**
```

---

## クイックスタート

### 🚀 新規セッション開始

```
1. AI が「オートブリーフィング」を自動提示
2. ユーザーが内容確認・変更指示
3. AI が git status/log を確認して詳細構成を提示
4. ユーザーが「着手OK」と返答
5. ブランチ作成: git checkout -b feature/[ID]_[タイトル]
6. コード実装
7. [GIT_WORKFLOW.md](GIT_WORKFLOW.md) に従ってコミット・PR
```

### 🐛 デバッグに詰まった

```
1. [DEVELOPMENT_PROCESS.md](DEVELOPMENT_PROCESS.md) の6ステップワークフローを実行
2. [APP_CANDIDATES.md](APP_CANDIDATES.md) のプロジェクト別TROUBLESHOOTING参照
3. [GIT_WORKFLOW.md](GIT_WORKFLOW.md) で既知のGitトラブル確認
```

### 📖 AI指示パターンを学び直したい

```
→ [docs/vibe_coding_instruction_design.md](docs/vibe_coding_instruction_design.md) 参照
→ [DEVELOPMENT_PROCESS.md](DEVELOPMENT_PROCESS.md) の「AI指示パターン」セクション
```

---

## 現在のプロジェクト進捗

### 完了作業（ID 001-012）

| Phase | ID | 内容 | ステータス |
|-------|----|----|-----------|
| **1** | 001 | プロジェクト初期化 | ✅ PR #3 |
| **2** | 002 | ラーニングパス定義 | ✅ PR #3 |
|  | 003 | Git/GitHub ワークフロー | ✅ PR #3 |
|  | 004 | 理論学習（Vibe Coding） | ✅ PR #3 |
| **3.1** | 005 | 天気情報ツール（Python） | ✅ PR #1 |
|  | 006 | トラブルシューティング文書化 | ✅ PR #1 |
| **2.3** | 007 | 指示設計ワークショップ | ✅ PR #2 |
| **3.2.A** | 008 | Web家計簿（Backend+Frontend） | ✅ PR #4 |
|  | 009 | テスト・検証（Frontend+E2E+Docker） | ✅ PR #5 |
| **3.2.B/C** | 010 | DNS + API Gateway 統合 | ✅ PR #6 |
|  | 011 | IoT センサーシミュレーター（Python+MQTT） | ✅ PR #7 |
|  | 012 | チャットボット Web App（React + Flask + Mock API） | ✅ Session 12 完了 |

### 次のステップ

- **ID 013**: フェーズ 3.3.A（スマートホーム IoT ハブ）— Session 13 以降
- **ID 014**: フェーズ 3.3.B（スマートコントラクト DApp）— 予定

詳細は [WORK_ID_REGISTRY.md](WORK_ID_REGISTRY.md) と [SESSION_PROGRESS.md](SESSION_PROGRESS.md) を参照

---

## ドキュメント管理戦略

### 目標
- **agents.md**: 150-200行（コアガイド）
- **各運用ドキュメント**: 100-200行（単一目的化）
- **理論・参考**: 250-600行（深掘り可）

### 原則
1. **モジュール化** — 1ドキュメント 1ドメイン
2. **スケーラビリティ** — 400行超過で分割検討
3. **参照統一** — クロスリファレンスで整合性確保
4. **頻度対応** — 更新頻度に応じたTier分割
5. **監視・保守** — 定期的なリファクタリングで肥大化防止

詳細は [DOCUMENTATION_STRATEGY.md](DOCUMENTATION_STRATEGY.md) 参照

### 📊 ドキュメント監視・リファクタリング

**定期チェック**:
- **各セッション終了時**: 全ドキュメント行数集計
- **警告基準**: 200行超 (400行で即座に分割)
- **Mini リファクタリング**: セッション後（小規模整理）
- **Medium リファクタリング**: フェーズ完了ごと（分割・統合）

**最新リファクタリング**: Session 7 完了時（2026年3月29日）
- agents.md: 400行 → 190行（52.5%削減 ✅）
- 新規4ドキュメント追加（SESSION_PROGRESS, WORK_ID_REGISTRY, COMPLIANCE_SECURITY, DOCUMENTATION_STRATEGY）

→ [DOCUMENTATION_STRATEGY.md#-定期リファクタリング計画](DOCUMENTATION_STRATEGY.md#-定期リファクタリング計画) で詳細確認

---

## キーファイル・パス

### 🚨 重要：正確なリポジトリ名

**正式名**: `VibeCoding`（**「ビ」段**）

⚠️ **誤り易い**: `VideoCoding`（「オ」段）× 誤り

### リポジトリ

```
https://github.com/hirotoitpost/VibeCoding
```

### 開発環境（Windows）

```powershell
# VS Code ワークスペース
<WORKSPACE_ROOT>\VibeCoding.code-workspace

# Python 仮想環境
<WORKSPACE_ROOT>\.venv

# examples パス（正確）
<WORKSPACE_ROOT>\examples\

# ローカルリポジトリ確認
cd "<WORKSPACE_ROOT>"
git status
```

### プロジェクトパス（examples/）

```
<WORKSPACE_ROOT>\examples\
├── 01-basic/weather-tool/
├── 02-intermediate/web-accounting-app/
├── 03-intermediate/iot-sensor-simulator/
├── 04-intermediate/chatbot-web-app/          ← ID 012 (Session 10)
└── [今後追加]
```

### 環境構築
```bash
# .env.example をコピーして設定
cp .env.example .env
# OPENWEATHERMAP_API_KEY 等を入力
```

詳細は [SETUP.md](SETUP.md) 参照

### ✅ ポカヨケチェックリスト（AI エージェント用）

**毎セッション開始時に実行**:
```powershell
# 1. 正確なパス確認
Test-Path "<WORKSPACE_ROOT>\.git"

# 2. リポジトリ状態確認
cd "<WORKSPACE_ROOT>"
git log --oneline -1

# 3. 現在のブランチ確認
git branch -a | findstr feature
```

**起動コマンド（テンプレート）**:
```powershell
# 常にこのパスを使う
cd "<WORKSPACE_ROOT>"

# feature ブランチ作成
git checkout -b feature/[ID]_[title]
```

---

## 🎯 次のセッション予告

### ✅ Session 12: ID 012 テスト・デプロイ（チャットボット Web アプリ）**完了**

**プロジェクト**: 2C - チャットボット Web アプリ（フェーズ 3.2.C）

**成果**:
- ✅ React + Vite フロントエンド（port 3000 動作確認）
- ✅ Flask バックエンド（port 5000 動作確認）
- ✅ Mock API レスポンス実装（14 キーワードパターン）
- ✅ End-to-end チャット通信検証完了
- ✅ Docker Compose マルチコンテナ構成
- ✅ ドキュメント完成（SETUP_GUIDE.md, README ×3）
- ✅ コミット: `385d1c6`、3 ファイル、9 挿入 + 25 削除
- ✅ **Session 12 実装・検証完全完了**

**参考**: [WORK_ID_REGISTRY.md](WORK_ID_REGISTRY.md#作業id発行履歴) - ID 012 完成記録

---

### 🔄 Session 13: ID 013 実装（次のプロジェクト予定）

**候補プロジェクト**:
- **3A**: スマートホーム IoT ハブ（複数デバイス + MQTT + REST API）
- **3B**: スマートコントラクト DApp（Solidity + Hardhat）

詳細は [APP_CANDIDATES.md](APP_CANDIDATES.md#フェーズ33-中級プロジェクト候補難易度-) 参照

---

## コミット履歴（最新）

```
385d1c6 (HEAD -> main) feat(ID 012): チャットボット Web App - Mock レスポンス完全実装完了 + google-genai 対応テスト
a3fc6be (origin/main) docs(Session 9): agents.md ・レジストリ最終更新 + .gitignore clean化
449f04e (feature/011_iot_sensor_simulator) Merge pull request #7 from hirotoitpost/feature/011_iot_sensor_simulator
237e4f2 Merge pull request #6 from hirotoitpost/feature/010_dns_api_gateway
```

詳細は [SESSION_PROGRESS.md](SESSION_PROGRESS.md) 参照

---

## Contact & Support

**プロジェクト管理**: AI Agent（GitHub Copilot）  
**リポジトリ**: https://github.com/hirotoitpost/VibeCoding  
**最終更新**: 2026年3月29日

---

**🎯 次のセッション**: Session 13 - ID 013 実装開始

