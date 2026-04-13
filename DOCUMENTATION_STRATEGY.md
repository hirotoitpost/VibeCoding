# ドキュメント管理戦略 - VibeCoding Project

> **背景**: agents.md は 607行に達し、単一ファイル管理が困難になったため、モジュール化戦略を採用。

---

## 概要

VibeCoding プロジェクトのドキュメントは、以下の原則に基づいてモジュール化・管理されています。

### コンセプト
- **モジュール化**: 関数ドメイン別にドキュメントを分離
- **スケーラビリティ**: 各ファイル 150-300行を目安に保つ
- **参照関係**: クロスリファレンスで統合性を確保
- **鮮度**: 頻度に応じた更新ルール

---

## ドキュメント体系

### Tier 1: コアガイド

| ファイル | 行数 | 更新頻度 | 役割 |
|---------|------|---------|------|
| **AGENTS_SIMPLIFIED.md** | 100-120 | 各セッション（最小限） | プロジェクト概要、実行チェックリスト、参照リンク一覧 | 
| **agents.md** | 150-200 | 稀 | 元の詳細ガイド（サポート資料として保持） |
| **README.md** | 20-50 | 稀 | GitHub 公開用の概要 |

### Tier 2: 運用ガイド

| ファイル | 行数 | 更新頻度 | 役割 |
|---------|------|---------|------|
| **DEVELOPMENT_PROCESS.md** | 70-100 | 問題発生時 | 6ステップデバッグワークフロー、AI指示パターン |
| **GIT_WORKFLOW.md** | 150-200 | 各セッション | ブランチ戦略、コミット規約、PR手順 |
| **GIT_COMMIT_CONVENTION.md** | 100-120 | 新規トピック追加時 | コミットメッセージ規約、Type 定義、例集 |
| **PULL_REQUEST_GUIDELINES.md** | 120-140 | 新規パターン発見時 | PR メッセージテンプレート、チェックリスト |
| **MERGE_CONFLICT_GUIDE.md** | 150-200 | 競合発生時 | 7ステップ競合解消プロセス、トラブルシューティング |
| **COMPLIANCE_SECURITY.md** | 100-150 | フェーズ変更時 | セキュリティチェックリスト、ライセンス確認 |

### Tier 3: ロードマップ・計画

| ファイル | 行数 | 更新頻度 | 役割 |
|---------|------|---------|------|
| **LEARNING_PATH.md** | 200-300 | 各フェーズ完了時 | 学習ロードマップ、各フェーズのマイルストーン |
| **APP_CANDIDATES_OVERVIEW.md** | 80-100 | 新規フェーズ時 | 難易度定義、プロジェクト分布、テンプレート概要 |
| **APP_CANDIDATES.md** | 200-300 | フェーズ開始時 | アプリケーション候補詳細、技術スタック、要件 |
| **APP_CANDIDATES_TEMPLATE.md** | 40-60 | 新規ドキュメント作成時 | プロジェクト作成テンプレート |
| **SETUP.md** | 100-150 | 環境変更時 | 開発環境セットアップ手順 |

### Tier 4: レジストリ・記録

| ファイル | 行数 | 更新頻度 | 役割 |
|---------|------|---------|------|
| **WORK_ID_REGISTRY.md** | 100-150 | 作業完了時 | 作業ID管理、発行履歴、統計 |
| **SESSION_PROGRESS.md** | 200+ | 各セッション終了時 | セッション進捗記録、完了項目、統計 |

### Tier 5: 知識・理論

| ファイル | 行数 | 更新頻度 | 役割 |
|---------|------|---------|------|
| **docs/vibe_coding_theory.md** | 250+ | 理論変更時 | Vibe Coding理論、AI指示の哲学 |
| **docs/vibe_coding_instruction_design.md** | 600+ | パターン追加時 | 5段階指示設計フレームワーク、パターン集 |
| **docs/vibe_coding_guide.md** | TBD | 随時 | 実装ガイド、ベストプラクティス |

### Tier 6: プロジェクト別ドキュメント

| パス | ファイル | 役割 |
|------|---------|------|
| **examples/01-basic/weather-tool/** | README.md, TROUBLESHOOTING.md | 天気情報ツールドキュメント |
| **examples/02-intermediate/web-accounting-app/** | README.md, TESTING_AND_VALIDATION.md | Web家計簿ドキュメント |

### Tier 7: 補助ガイド・チェックリスト（管理用）

| ファイル | 行数 | 用途 | 更新頻度 |
|---------|------|------|---------|
| **DOCUMENTATION_CREATION_CHECKLIST.md** | 200-250 | 新規ドキュメント作成時の確認フロー | 随時 |
| **APP_CANDIDATES_TEMPLATE.md** | 40-60 | プロジェクト作成テンプレート | フェーズ開始時 |

---

## 参照関係図 (アップデート: 2026-04-13)

```
AGENTS_SIMPLIFIED.md (中央クイックハブ)
│
├─ Tier 2: 運用ガイド ─────────────────────────
│  ├─ DEVELOPMENT_PROCESS.md
│  ├─ GIT_WORKFLOW.md
│  ├─ MERGE_CONFLICT_GUIDE.md
│  └─ COMPLIANCE_SECURITY.md
│
├─ Tier 3: ロードマップ ──────────────────────
│  ├─ LEARNING_PATH.md
│  ├─ APP_CANDIDATES_OVERVIEW.md (新)
│  ├─ APP_CANDIDATES.md
│  ├─ APP_CANDIDATES_TEMPLATE.md (新)
│  └─ SETUP.md
│
├─ Tier 4: レジストリ ────────────────────────
│  ├─ WORK_ID_REGISTRY.md
│  └─ SESSION_PROGRESS.md ← 拡張完了 (17→148行)
│
└─ Tier 5: 知識・理論 ────────────────────────
   ├─ docs/vibe_coding_theory.md
   ├─ docs/vibe_coding_instruction_design.md
   └─ docs/vibe_coding_guide.md

【参考】agents.md
  └─ 詳細ガイド（サポート資料として保持）
```

---

## クロスリファレンス規約

### 形式
```markdown
[ファイル名](ファイル名.md)
[ファイル名](ファイル名.md#L10-L20)
[説明テキスト](ファイル名.md#セクション)
```

### 例
```markdown
詳細は [GIT_WORKFLOW.md](GIT_WORKFLOW.md) を参照
競合解消プロセスは [MERGE_CONFLICT_GUIDE.md](MERGE_CONFLICT_GUIDE.md) の7ステップを参照
Session 1 の進捗は [SESSION_PROGRESS.md](SESSION_PROGRESS.md#セッション-1-2026-03-26) を参照
```

### 実装ルール
- 各ドキュメントは関連箇所を必ずリンク
- 参照先ドキュメント名・セクションは正確に
- 相互参照（Aが Bを参照、Bが Aを参照）も許可
- 重複情報（作業ID、進捗記録など）は参照に統一

---

## 更新ルール

### Tier 別更新戦略

#### Tier 1 (コアガイド)
- **agents.md**: 各セッション終了時に最小限の更新
  - 目次は常に最新に
  - 新規ドキュメント参照を追加
  - リンク先の行数・内容が変わったら更新
- **README.md**: ほぼ変更なし（稀に更新）

#### Tier 2 (運用ガイド)
- **DEVELOPMENT_PROCESS.md**: デバッグ手法発見時に更新
- **GIT_WORKFLOW.md**: 各セッション完了時に実績を反映
- **MERGE_CONFLICT_GUIDE.md**: 新しい競合パターン発見時に追加
- **COMPLIANCE_SECURITY.md**: フェーズ開始時 + 定期レビュー

#### Tier 3 (ロードマップ)
- **LEARNING_PATH.md**: 各フェーズ完了時に次フェーズを詳細化
- **APP_CANDIDATES.md**: フェーズ開始時に選定アプリを追加
- **SETUP.md**: OS新規対応時に手順追加

#### Tier 4 (レジストリ)
- **WORK_ID_REGISTRY.md**: 作業完了時に新ID行を追加
- **SESSION_PROGRESS.md**: 各セッション終了時に新セッション記録を追加

#### Tier 5 (知識・理論)
- **docs/vibe_coding_theory.md**: 理論的発見があれば追加
- **docs/vibe_coding_instruction_design.md**: 新パターン・フレームワーク追加時
- **docs/vibe_coding_guide.md**: 実装ガイド充実させるまで随時

---

## 行数管理・分割戦略

### 目標行数
| カテゴリ | 推奨 | 最大 |
|---------|------|------|
| コアガイド | 150-200 | 250 |
| 運用ガイド | 100-150 | 200 |
| ロードマップ | 200-300 | 400 |
| レジストリ | 100-200 | 250 |
| 知識・理論 | 200-600 | 無制限 |

### 分割トリガー
- **400行超過**: 内容を別ファイルに分割検討
- **600行超過**: 強制分割（2つ以上に分割）
- **成長著しい**: 前倒しで分割予定

### 分割例（通過）
```
TESTING_STRATEGY.md (未実装)
 ├─ テスト設計・実行
 ├─ テストレポーティング
 └─ テスト保守

DEPLOYMENT_GUIDE.md (未実装)
 ├─ デプロイメント・プロセス
 ├─ 環境管理
 └─ CI/CD パイプライン設定
```

---

## 新規ドキュメント追加フロー

### 1. 計画・判定

```
「このセクションが大きくなりそう」
  ↓
「行数が150行超える見込み？」
  ├─ YES → 新規ファイル作成を計画
  └─ NO  → agents.md 内に保持
```

### 2. 作成・設定

```
新規ファイル名:
 1. 英語名 + .md (例: TESTING_STRATEGY.md)
 2. 参照セクションを agents.md に追加
 3. 参照リンク集作成
```

### 3. リポジトリ登録

```
git add [新規ファイル名]
git add agents.md (参照リンク更新)
git commit -m "docs: [新規ファイル] を追加"
```

---

## 実装状況（2026年4月13日 Session 27 完全アップデート）

### ✅ Tier 1-5 実装済み
- **AGENTS_SIMPLIFIED.md** (117行)
- **APP_CANDIDATES_OVERVIEW.md** (70行)
- **APP_CANDIDATES_TEMPLATE.md** (55行)
- **APP_CANDIDATES.md** (200行の基礎・初級版に分割)
- **APP_CANDIDATES_ADVANCED.md** ← NEW (150行の中級・発展)
- **APP_CANDIDATES_SPECIAL.md** ← NEW (150行の特殊プロジェクト)
- **SESSION_PROGRESS.md** ← EXPANDED (17→148行)
- DEVELOPMENT_PROCESS.md
- GIT_WORKFLOW.md
- MERGE_CONFLICT_GUIDE.md
- LEARNING_PATH.md
- SETUP.md
- WORK_ID_REGISTRY.md
- COMPLIANCE_SECURITY.md
- docs/vibe_coding_theory.md
- docs/vibe_coding_instruction_design.md

### ✅ Tier 2 新規スキル化ドキュメント
- **GIT_COMMIT_CONVENTION.md** ← NEW (120行)
- **PULL_REQUEST_GUIDELINES.md** ← NEW (140行)

### ✅ Tier 7 補助ガイド・チェックリスト
- **DOCUMENTATION_CREATION_CHECKLIST.md** ← NEW (220行)

### ⏳ 計画中
- TESTING_STRATEGY.md (Phase 3.3 完了後)
- DEPLOYMENT_GUIDE.md (Phase 4)
- TROUBLESHOOTING_LIBRARY.md (Phase 4-5)
- docs/vibe_coding_guide.md (実装中)

---

## ドキュメント行数集計（2026年4月13日 最終版）

| ファイル | 行数 | 状態 | Tier |
|---------|------|------|------|
| **SESSION_PROGRESS.md** | 148 | ✅ 拡張完了 | 4 |
| **AGENTS_SIMPLIFIED.md** | 117 | ✅ 新規作成 | 1 |
| **DOCUMENTATION_CREATION_CHECKLIST.md** | 220 | ✅ 新規作成 | 7 |
| **PULL_REQUEST_GUIDELINES.md** | 140 | ✅ 新規作成 | 2 |
| **GIT_COMMIT_CONVENTION.md** | 120 | ✅ 新規作成 | 2 |
| **DOCUMENTATION_STRATEGY.md** | 330 | ✅ 更新 | - |
| **APP_CANDIDATES_SPECIAL.md** | 150 | ✅ 新規作成 | 3 |
| **APP_CANDIDATES_ADVANCED.md** | 140 | ✅ 新規作成 | 3 |
| **APP_CANDIDATES_OVERVIEW.md** | 70 | ✅ 新規作成 | 3 |
| **APP_CANDIDATES.md** | 185 | ✅ 分割完了 | 3 |
| **APP_CANDIDATES_TEMPLATE.md** | 55 | ✅ 新規作成 | 7 |
| WORK_ID_REGISTRY.md | 215 | ✓ 適正 | 4 |
| LEARNING_PATH.md | 314 | ⚠️ 上限近接 | 3 |
| agents.md | 422 | ⚠️ 参考資料 | 1 |
| docs/vibe_coding_instruction_design.md | 600+ | ⚠️ 監視対象 | 5 |

**要点**:
- ✅ **APP_CANDIDATES 体系**: 477行 → 4ファイル (185+140+150+70) に分割・モジュール化
- ✅ **SESSION_PROGRESS.md**: 17行 → 148行 (全27セッション統計)
- ✅ **スキル化ドキュメント**: GIT_COMMIT_CONVENTION, PULL_REQUEST_GUIDELINES 追加
- ✅ **作成フロー確立**: DOCUMENTATION_CREATION_CHECKLIST で新規ドキュメント基準化

---

**最終更新**: 2026年4月13日 12:30 JST (Session 27)


---

**最終更新**: 2026年4月13日 12:00 JST

| MERGE_CONFLICT_GUIDE.md | 150+ |
| LEARNING_PATH.md | 300+ |
| APP_CANDIDATES.md | 300+ |
| SETUP.md | 150+ |
| **合計** | **2,000+ 行** |

**対比**: 以前は agents.md に 1,600+ 行が集約。モジュール化により、各ドキュメント が適切なサイズに分散。

---

## ベストプラクティス

### DO ✅
- 新規セクション追加時は参照リンク必須
- 80文字/行を目安（可読性）
- 更新日時を常にファイル末尾に記載
- 相互参照で一貫性確保

### DON'T ❌
- 同一情報を複数ファイルに重複記載
- 参照リンクなしで情報分散
- 古い情報を放置
- 行数管理を無視した無限肥大化

---

## 📊 ドキュメント監視・保守ルール

### 肥大化監視（定期チェック）

#### チェックタイミング
| タイミング | 頻度 | 実施者 | 対象 |
|----------|------|--------|------|
| **各セッション終了時** | 毎回 | AI Agent | 全ドキュメント行数集計 |
| **フェーズ完了時** | 4段階 | AI Agent | Tier別集計、肥大化傾向分析 |
| **PR マージ前** | 随時 | Reviewer | 対象ドキュメント行数増減 |

#### 監視対象メトリクス
```
各ファイルの行数 (目標値 ± 30%)
- agents.md: 150-200行 → 超過時は警告
- 運用ガイド各種: 100-150行
- ロードマップ各種: 200-300行
- レジストリ: 100-200行
```

#### 警告基準（アクション発火条件）
| 行数 | ステータス | アクション |
|------|----------|----------|
| 200行超 → 250行未満 | ⚠️ 注意 | セクション分割検討 |
| 250行超 → 400行未満 | 🔴 警告 | 分割計画立案 |
| 400行超 | 🛑 緊急 | 即座に分割実施 |
| 600行超 | 🚨 致命 | PR差し戻し（分割強制） |

### 行数集計スクリプト

各セッション終了時に実行：
```powershell
# PowerShell
Get-ChildItem -Path "*.md" -File | 
  Select-Object Name, @{Name="Lines";Expression={(Get-Content $_.FullName | Measure-Object -Line).Lines}} | 
  Sort-Object Lines -Descending | 
  Format-Table -AutoSize

# 出力例
Name                      Lines
----                      -----
APP_CANDIDATES.md           342
LEARNING_PATH.md            314
...
```

**記録先**: [SESSION_PROGRESS.md](SESSION_PROGRESS.md) の「統計サマリー」セクションに追記

---

## 🔄 定期リファクタリング計画

### リファクタリング周期

| サイクル | タイミング | 対象 | 目的 |
|---------|----------|------|------|
| **Mini** | 各セッション後 | 発生したドキュメント | 即日対応（小規模な整理） |
| **Medium** | フェーズ完了ごと | Tier 全体 | 肥大化箇所の分割・統合 |
| **Major** | 4段階フェーズ終了 | 全ドキュメント | 戦略見直し・大規模リファクタリング |

### Mini リファクタリング（各セッション後）

**実施日**: セッション完了時 → ドキュメント追加時次セッション開始前

**作業内容**:
1. セッション中に追加・修正されたドキュメントの行数確認
2. 参照リンクの妥当性確認
3. 古い情報の削除・アーカイブ化
4. 入力ミスやリンク切れの修正

**コミット例**:
```
chore(docs): Session 8 ドキュメント整理・リンク修正
 - SESSION_PROGRESS.md に新セッション記録
 - 古いセッション情報をアーカイブフォルダへ移行
 - WORK_ID_REGISTRY.md の 次ID更新
```

### Medium リファクタリング（フェーズ完了ごと）

**実施日**: フェーズ完了 → 次フェーズ開始前（例：Phase 3.2.A完了時）

**作業内容**:
1. Tier別の行数集計・分析
2. 肥大化傾向の特定 (どのドキュメント？原因は？)
3. 分割対象の選定 (400行超のドキュメント)
4. 新規ドキュメント候補の検討
5. 参照関係の再整理

**実施例**（過去）:
```
Phase 3.2.A 完了時（2026年3月29日）
- agents.md: 400行 → 190行（52%削減）
↓ 新規ドキュメント追加
- SESSION_PROGRESS.md
- WORK_ID_REGISTRY.md
- COMPLIANCE_SECURITY.md
- DOCUMENTATION_STRATEGY.md (このファイル)
結果: リポジトリ全体コンテンツ量は増加も、各ファイルモジュール化で保守性↑
```

**コミット例**:
```
refactor: Phase 3.2.A 完了 → ドキュメント分割・モジュール化完成
 - agents.md を 400行 → 190行に削減（55%削減）
 - SESSION_PROGRESS.md, WORK_ID_REGISTRY.md 等を新規作成
 - Tier別体系を再整理・ドキュメント化
```

### Major リファクタリング（フェーズ終了 / 戦略変更時）

**実施日**: Phase 4 開始前、または戦略・方針大幅変更時

**作業内容**:
1. ドキュメント全体の戦略見直し
2. 不要なドキュメントの廃止 / アーカイブ化
3. 新しい Tier体系の検討 (Phase 4 で英語版必要？など)
4. 自動ドキュメント生成ツール検討（Sphinx, MkDocs など）
5. GitHub Wiki 統合の検討

**計画例（Phase 4）**:
```
Phase 4: ナレッジシェア・成果物化
- 日本語ドキュメント の確定版ロック
- 英語版ドキュメント 作成
- GitHub Wiki への展開
- Sphinx / MkDocs での自動生成試験
```

---

## 🛠️ リファクタリド判定チェックリスト

セッション終了時に以下をチェック：

### 警告フェーズ（行数 200-250）
- [ ] セクション数を確認（3個以上なら分割候補）
- [ ] 各セクションの独立性を確認
- [ ] 分割後の新規ドキュメント名を構想

### 注意フェーズ（行数 250-400）
- [ ] 即座に分割計画を立案
- [ ] 新規ドキュメント草稿作成
- [ ] agents.md に参照リンク追加
- [ ] 次セッションで実装予定化

### 緊急フェーズ（行数 400 超）
- [ ] PR マージ前に分割を実施
- [ ] コード + ドキュメント分割を同時処理
- [ ] 分割後の参照関係を検証

### 致命フェーズ（行数 600 超）
- [ ] この行数に到達しないようセッション中に監視
- [ ] 到達した場合は PR 差し戻し（分割強制）

---

## 📋 リファクタリング実績

### Session 7 完了時（2026年3月29日）

**実施内容**: Phase 3.2.A 完了 → ドキュメント分割リファクタリング

**Before**
```
agents.md: 400行（肥大化警告レベル）
その他: 情報が分散・重複
```

**After**
```
agents.md: 190行 (52.5%削減) ✅
SESSION_PROGRESS.md: 145行 (新規) ✅
WORK_ID_REGISTRY.md: 88行 (新規) ✅
COMPLIANCE_SECURITY.md: 106行 (新規) ✅
DOCUMENTATION_STRATEGY.md: 225行 (新規) ✅
```

**効果**
- コアガイド(agents.md)の可読性 向上
- 更新頻度に応じた階層化 完成
- 長期保守性 大幅改善
- 新規ドキュメント追加時のリスク低減

**コミット**: `94ef4f8` refactor: ドキュメント分割・モジュール化リファクタリング完成

**次回実施予定**: Phase 3.2.B 完了時（Session 9-10 予定）

---

## 今後の方針

### Phase 3.2-3.3
- セットアップスクリプト実装 → SETUP.md 拡張
- テスト戦略体系化 → TESTING_STRATEGY.md 作成
- デプロイメント実装 → DEPLOYMENT_GUIDE.md 作成
- **リファクタリング**: Phase 3.2.B 完了時実施

### Phase 4
- ドキュメント主要版（英語） 作成
- GitHub Wiki への統合
- 自動ドキュメント生成（Sphinx or MkDocs）
- **リファクタリング**: Phase 4 開始前に大規模実施

---

**最終更新**: 2026年3月29日（ドキュメント分割リファクタリング完成）  
**次回監視**: Session 8 セッション終了時  
**管理者**: VibeCoding Learning Project AI Agent
