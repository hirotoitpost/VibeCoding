# 📖 VibeCoding AI エージェント実行ガイド

> **最終更新**: 2026年4月13日 | **進捗**: Phase 5.5.2 進行中 (ID 027)

---

## 🚀 クイックリファレンス

### 📚 主要ドキュメント

| ドキュメント | 用途 | 行数 |
|-----------|------|------|
| [README.md](README.md) | プロジェクト概要 | - |
| [LEARNING_PATH.md](LEARNING_PATH.md) | フェーズロードマップ | 314 |
| [SESSION_PROGRESS.md](SESSION_PROGRESS.md) | セッション統計・進捗 | 148 |
| [WORK_ID_REGISTRY.md](WORK_ID_REGISTRY.md) | Work ID 履歴 | 215 |

### 🔧 運用ガイド

| ドキュメント | コンテキスト |
|-----------|-----------|
| [GIT_WORKFLOW.md](GIT_WORKFLOW.md) | ブランチ戦略、PR フロー |
| [DEVELOPMENT_PROCESS.md](DEVELOPMENT_PROCESS.md) | 6ステップデバッグワークフロー |
| [MERGE_CONFLICT_GUIDE.md](MERGE_CONFLICT_GUIDE.md) | 競合解消手順 |

### 📖 理論・参考

| ドキュメント | トピック | 行数 |
|-----------|---------|------|
| [docs/vibe_coding_theory.md](docs/vibe_coding_theory.md) | 理論体系 | 250+ |
| [docs/vibe_coding_instruction_design.md](docs/vibe_coding_instruction_design.md) | 5段階フレームワーク | 600+ |

---

## 🤖 AI エージェント責務

### ✅ 実施するもの
- ✅ feature ブランチ作成・コード実装・コミット
- ✅ `git push origin feature/[ID]_[title]` で Push
- ✅ **GitHub Web UI または CLI から PR 作成**
- ✅ ドキュメント更新 → docs/session-X ブランチで PR 作成

### ❌ 禁止事項
- ❌ `git merge` を main に直接実行
- ❌ PR を自分で Approve / Merge
- ❌ `git push origin main` - すべてのケース禁止

### ユーザー責務
- ✅ GitHub Web UI で PR 確認・Approve & Merge
- ✅ ローカルで `git pull origin main` して同期

---

## 📊 現在の進捗

| Phase | ID | タイトル | ステータス |
|-------|----|---------|---------| 
| 1-3 | 001-014 | 基礎～スマートコントラクト | ✅ 完了 |
| 3.3.C | 015 | Web3 フロントエンド | ✅ 完了 |
| 3.3.D | 016-020 | 動画生成エンジン | ✅ 完了 |
| 4 | 021 | AviUtl 統合 | ✅ 完了 |
| 5 | 022-026 | 映像要素・効果設定 | ✅ 完了 |
| **5.5.2** | **027** | **INI Exo (進行中)** | 🔄 進行中 |

詳細: [SESSION_PROGRESS.md](SESSION_PROGRESS.md)

---

## 📂 ファイルパス・ポカヨケ

### リポジトリ

```
正式名: VibeCoding (「ビ」段)
URL: https://github.com/hirotoitpost/VibeCoding
```

### ブランチ management

```powershell
# 新規ブランチ作成
git checkout -b feature/[ID]_[タイトル]

# Push & PR
git push origin feature/[ID]_[タイトル]
# → GitHub Web UI で PR 作成
```

### Examples ディレクトリ

```
examples/
├── 01-basic/weather-tool/
├── 02-intermediate/web-accounting-app/
├── 03-intermediate/iot-sensor-simulator/
├── 04-intermediate/chatbot-web-app/
├── 05-advanced/smart-home-iot-hub/
├── 06-advanced/smart-contract-dapp/
└── 07-advanced/aviutl_voicevox_pipeline/
```

---

## 🎯 セッション開始チェックリスト

1. ✅ `git log --oneline main -3` で最新コミット確認
2. ✅ [SESSION_PROGRESS.md](SESSION_PROGRESS.md) で前セッション確認
3. ✅ [WORK_ID_REGISTRY.md](WORK_ID_REGISTRY.md) で次 ID 確認
4. ✅ `git checkout -b feature/[ID]_[title]` で新規ブランチ
5. ✅ 実装 → `git add . && git commit`
6. ✅ `git push origin feature/[ID]_[title]` → **GitHub Web UI で PR**

---

## 📞 サポート

**詳細リファレンス**:
- 🔧 [GIT_WORKFLOW.md](GIT_WORKFLOW.md) - Git 操作トラブル
- 💡 [DEVELOPMENT_PROCESS.md](DEVELOPMENT_PROCESS.md) - デバッグフロー
- 📚 [docs/vibe_coding_instruction_design.md](docs/vibe_coding_instruction_design.md) - AI 指示パターン

---

**このガイドは長期的に 150-200 行を維持します。詳細は各リンク先ドキュメントを参照。**
