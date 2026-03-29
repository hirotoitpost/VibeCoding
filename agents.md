# VideCoding 学習プロジェクト - AIエージェント作業ガイド

> **最終更新**: 2026年3月29日（ドキュメント分割リファクタリング完成）  
> **ステータス**: Phase 3.2.A 完了、Phase 3.2.B 開始予定

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
- **進捗**: **Phase 3.2.A 完了** ✅（ID 001-009 すべてマージ完了）

---

## 学習フェーズ（4段階）

| フェーズ | タイトル | ステータス | 目標 |
|---------|---------|----------|------|
| **フェーズ1** | 基礎理解 | ✅完了 | 環境構築、プロセス理解 |
| **フェーズ2** | 理論学習 | ✅完了 | VideCoding基本概念、ベストプラクティス |
| **フェーズ3** | 実装（段階的） | 🔄進行中 | 複数の小規模アプリケーション開発 |
| **フェーズ4** | 成果物化 | ⏳予定 | ナレッジシェア（スライド+動画） |

詳細は [LEARNING_PATH.md](LEARNING_PATH.md) を参照

---

## プロジェクト構成

```
VideCoding/
├── 📋 ドキュメント
│   ├── agents.md ..................... このファイル（コアガイド）
│   ├── README.md ..................... GitHub用概要
│   ├── SETUP.md ..................... 開発環境セットアップ
│   │
│   └── 📚 ドキュメント体系
│       ├── SESSION_PROGRESS.md ....... セッション進捗記録（S1-S7+）
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
│   ├── examples/01-basic/weather-tool/ ......... ✅ Phase 3.1（Python）
│   └── examples/02-intermediate/web-accounting-app/  ✅ Phase 3.2.A（Python+React）
│
├── 🔧 ユーティリティ
│   ├── scripts/ ........................... セットアップスクリプト
│   └── .env.example ....................... 環境変数テンプレート
│
└── ⚙️ Configuration
    ├── .gitignore .......................... Git除外設定
    └── VideCoding.code-workspace .......... VS Code設定
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
   - master ブランチで SESSION_PROGRESS.md, WORK_ID_REGISTRY.md を更新
   - `git add` と `git commit` でコミット
   - `git push origin master` で Push

#### ❌ 禁止事項（AI エージェント がしてはいけないこと）
- ❌ feature ブランチを master に `git merge` する
- ❌ PR を自分で Approve / Merge する
- ❌ `git push origin master` を直接実行（ドキュメント更新以外）
- ❌ PR のレビューコメントに返信（ユーザーの承認待ち）

### ユーザーの責務

#### ✅ PR レビュー・マージ
1. GitHub Web UI で PR の変更内容を確認
2. テスト、コードレビュー実施
3. 問題なければ **Approve & Merge** ボタンをクリック
4. ローカルで `git pull origin master` して同期

#### ✅ マージ後の確認
- ローカル master が最新状態か確認
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
│    $ git pull origin master                                │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ AI エージェント 最終処理                                   │
├─────────────────────────────────────────────────────────────┤
│ 5. ドキュメント更新（必要に応じて）                         │
│    - SESSION_PROGRESS.md を master で編集                   │
│    - WORK_ID_REGISTRY.md を master で編集                   │
│    $ git add . && git commit -m "docs(Session X): ..."    │
│    $ git push origin master                                │
└─────────────────────────────────────────────────────────────┘
```

### 違反時の対応

**違反が発生した場合**:
- AI エージェント が feature を master に直接マージしてしまった場合
- マージコミットが origin/master に Push されてしまった場合

**対応**:
1. ユーザーに即座に報告
2. ユーザーの指示に従い revert または修正
3. AGENTS.md のこのセクションを見直す

---

## クイックスタート

### 🚀 新規セッション開始

```
1. このファイル（agents.md）を確認
2. [LEARNING_PATH.md](LEARNING_PATH.md) から今のフェーズ確認
3. [WORK_ID_REGISTRY.md](WORK_ID_REGISTRY.md) から次のID確認
4. ブランチ作成: git checkout -b feature/[ID]_[タイトル]
5. コード実装
6. [SESSION_PROGRESS.md](SESSION_PROGRESS.md) と [GIT_WORKFLOW.md](GIT_WORKFLOW.md) に従ってコミット・PR
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

### 完了作業（ID 001-009）

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

### 次のステップ

- **ID 010**: フェーズ 3.2.B（Web家計簿拡張 or 新規プロジェクト）— Session 8 で実装予定

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

### リポジトリ

```
https://github.com/hirotoitpost/VideCoding
```

### 開発環境
```powershell
# VS Code ワークスペース
D:\ProjectPool2\hirotoitpost\GitHub\VideCoding\VideCoding.code-workspace

# Python 仮想環境
D:\ProjectPool2\hirotoitpost\GitHub\VideCoding\.venv
```

### 環境構築
```bash
# .env.example をコピーして設定
cp .env.example .env
# OPENWEATHERMAP_API_KEY を入力
```

詳細は [SETUP.md](SETUP.md) 参照

---

## 最新コミット

```
dca43d2 docs(Session 7): ID 009 完全完成記録を更新
a438785 chore(ID 009): テスト・検証インフラ完全統合
02373e1 Merge pull request #5 from hirotoitpost/feature/009_web家計簿テスト検証
```

詳細は [SESSION_PROGRESS.md](SESSION_PROGRESS.md)#セッション-7 参照

---

## 関連リンク

### 学習リソース
- [Vibe Coding理論](docs/vibe_coding_theory.md)
- [指示設計フレームワーク](docs/vibe_coding_instruction_design.md)

### プロジェクト参考
- [天気情報ツール](examples/01-basic/weather-tool/)
- [Web家計簿アプリ](examples/02-intermediate/web-accounting-app/)

### ユーティリティ
- [セットアップガイド](SETUP.md)
- [VS Code ワークスペース](VideCoding.code-workspace)

---

## Contact & Support

**プロジェクト管理**: AI Agent（GitHub Copilot）  
**リポジトリ**: https://github.com/hirotoitpost/VideCoding  
**最終更新**: 2026年3月29日

---

**🎯 次のセッション**: ID 010 実装開始（Session 8）

