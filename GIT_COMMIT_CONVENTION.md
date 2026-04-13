# Git コミット規約 - VibeCoding プロジェクト

> **参照**: [GIT_WORKFLOW.md](GIT_WORKFLOW.md), [DEVELOPMENT_PROCESS.md](DEVELOPMENT_PROCESS.md)

---

## 📝 コミットメッセージ形式

### 基本フォーマット

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type（必須）

| Type | 用途 | 例 |
|------|------|-----|
| **feat** | 新機能 | `feat(ID 010): DNS + API Gateway 統合` |
| **fix** | バグ修正 | `fix(generate_exo): INI フォーマット修正` |
| **docs** | ドキュメント変更 | `docs(Session 27): SESSION_PROGRESS 拡張` |
| **refactor** | コード改善（機能変更なし） | `refactor(app): 関数抽出` |
| **test** | テスト追加・修正 | `test(api): エンドポイント検証` |
| **chore** | 依存関係・ビルド設定 | `chore(deps): npm update` |
| **restore** | 削除ファイルの復活 | `restore: Session 2-4 記録復活` |

### Scope（推奨）

実装対象を括弧内に指定：
- **Session + ID**: `Session 27 ID 027`
- **ファイル名**: `video_layout.json`, `generate_exo.ps1`
- **領域**: `backend`, `frontend`, `docs`
- **機能**: `MQTT`, `API`, `UI`

### Subject（必須）

- 命令形で記述（「修正する」ではなく）
- 最初の文字は大文字
- 末尾にピリオドなし
- 50 文字以内（GitHub UI でカット）

### Body（推奨）

- **なぜ**を説明（なにをするのか、ではなく）
- 複数行の場合は空行で区切る
- 72 文字折り返し
- 変更前後の比較、理由、考慮事項を記載

### Footer（オプション）

```
Closes #123
Related-To: ID 027, ID 028
Breaking-Change: API /v1/device → /v2/device に変更
```

---

## 📚 コミットメッセージ例

### ✅ 良い例

**新機能**:
```
feat(Session 27 ID 027): Generate Exo ファイル INI フォーマット書き直し

AviUtl との互換性を確保するため、XML 形式から INI 形式に完全書き換え。
PSDToolKit 標準フォーマット（Layer4.exo）に準拠。

- [exedit] セクション構造を採用
- type=0, filter=2, name=..., param=... 規約に統一
- 複数トランジション効果に対応

Relates-To: ID 026, ID 025
Closes #27
```

**ドキュメント更新**:
```
docs(Session 27): ドキュメント整理・拡張完了

APP_CANDIDATES.md を 3 つのモジュールに分割：
- APP_CANDIDATES.md: 基礎・初級 (200行)
- APP_CANDIDATES_ADVANCED.md: 中級・発展 (新規)
- APP_CANDIDATES_SPECIAL.md: 特殊プロジェクト (新規)

SESSION_PROGRESS.md を 17行 → 148行に拡張し、全27セッション記録を統合。
```

**バグ修正**:
```
fix(generate_exo): XML から INI への テキスト形式判定エラー

症状: テキスト形式の exo ファイルが読み込めない
原因: XML ノード判定で INI セクション記法に対応していなかった
対応: セクション記法 [N.M] の検出ロジックを追加

テスト: video_layout.json の複数ファイルで動作確認済み
```

### ❌ 悪い例

```
❌ "update"           → 何を更新したのか不明
❌ "fixed bugs"       → どのバグか、なぜか不明
❌ "docs updated"     → 大文字で始まらない、スコープなし
❌ "This fixes the issue where..." → 長すぎてカット
❌ "WIP"              → 本番コミットとして不適切
```

---

## 🔗 関連ドキュメント

| ドキュメント | 関連内容 |
|----------|---------|
| [GIT_WORKFLOW.md](GIT_WORKFLOW.md) | ブランチ戦略、PR フロー全体 |
| [DEVELOPMENT_PROCESS.md](DEVELOPMENT_PROCESS.md) | コミット実行フロー（6ステップ）|
| [PULL_REQUEST_GUIDELINES.md](PULL_REQUEST_GUIDELINES.md) | PR メッセージ規約 |

---

**最終更新**: 2026年4月13日 | **バージョン**: 1.0
