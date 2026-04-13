# ドキュメント作成・修正時の確認チェックリスト

> **参照**: [DOCUMENTATION_STRATEGY.md](DOCUMENTATION_STRATEGY.md), [agents.md](agents.md)

---

## 📋 ドキュメント作成前の判定フロー

```
「新規ドキュメントまたは大規模修正が必要」
  ↓
【1】内容の分類
  ├─ YES: 既存ドキュメントに追加可能 → 統合検討
  ├─ NO:  新規ドキュメント必要 → 【2】へ
  
【2】チェックリスト実施
  ├─ Tier 判定
  ├─ 行数見積もり
  ├─ 参照関係
  └─ スキル化判定
  
【3】作成・修正実施
  ├─ 新規ファイル作成 or 既存ファイル修正
  └─ チェックリスト項目 実行
  
【4】完了・コミット
  ├─ PR 作成
  └─ SESSION_PROGRESS.md / WORK_ID_REGISTRY.md 更新
```

---

## ✅ ドキュメント作成チェックリスト

### 【1】内容の分類

- [ ] **既存ドキュメントとの関連性**
  - [ ] agents.md に統合できるか？
  - [ ] DEVELOPMENT_PROCESS.md に組み込むべきか？
  - [ ] GIT_WORKFLOW.md の補足か？
- [ ] **新規ドキュメント判定**
  - [ ] 単独でのドキュメント化が必要？
  - [ ] 独立した理由を説明できるか？

### 【2】Tier 判定

**以下のいずれかに該当するか確認**:

| Tier | カテゴリ | 行数目標 | 例 |
|------|---------|---------|-----|
| **Tier 1** | コアガイド | 100-150 | AGENTS_SIMPLIFIED.md |
| **Tier 2** | 運用ガイド | 100-150 | GIT_COMMIT_CONVENTION.md |
| **Tier 3** | ロードマップ | 200-300 | APP_CANDIDATES_ADVANCED.md |
| **Tier 4** | レジストリ | 100-200 | WORK_ID_REGISTRY.md |
| **Tier 5** | 知識・理論 | 200+ | docs/vibe_coding_instruction_design.md |

- [ ] **Tier を決定**（1-5 のどれか）
- [ ] **行数目標を設定**（上記を参考）
- [ ] **更新頻度を決定**（毎セッション/月1回/随時）

### 【3】行数・スコープ見積もり

- [ ] **初期予想行数を記録**: ____ 行
- [ ] **最大行数を設定**: ____ 行（通常は目標 × 1.5）
- [ ] **400行超過時の分割計画**（あれば）
  - [ ] 分割先ファイル 1: ___________
  - [ ] 分割先ファイル 2: ___________

### 【4】参照関係設定

- [ ] **参照元の追加**（このドキュメントから他を参照）
  - 例: `[参照先ドキュメント](ファイル名.md)` を記入
  - [ ] 参照先1: _______________
  - [ ] 参照先2: _______________

- [ ] **参照先の更新**（他から このドキュメントを参照）
  - 例: [DOCUMENTATION_STRATEGY.md](DOCUMENTATION_STRATEGY.md) に参照リンク追加
  - [ ] 更新対象1: _______________
  - [ ] 更新対象2: _______________

### 【5】スキル化判定

**以下の場合、スキル化を検討**:

- [ ] **本プロジェクト固有の規約か？** (Yes → スキル化候補)
  - 例: GIT_COMMIT_CONVENTION.md, PULL_REQUEST_GUIDELINES.md
  
- [ ] **AI エージェント向けの手順書か？** (Yes → スキル化候補)
  - 例: DEVELOPMENT_PROCESS.md

- [ ] **スキル化の判定**: 
  - [ ] スキル化進行 → agent-customization スキルを参照
  - [ ] ドキュメント単独で管理 → そのまま進行

### 【6】SESSION_PROGRESS.md 更新

ドキュメント作成後に必ず記録:

```markdown
## セッション XX (YYYY-MM-DD)

**新規ドキュメント作成**:
- [ドキュメント名](ドキュメント.md) ← NEW: XX行 / Tier X
  - 目的: [簡潔な説明]
  - 参照先: [参照元ドキュメント名]

**既存ドキュメント更新**:
- [ファイル名](ファイル.md): XX行 → YY行 (+ZZ行)
  - 変更内容: [何を追加/修正したか]
```

### 【7】WORK_ID_REGISTRY.md 更新

**ドキュメント系タスク終了時**:

```markdown
| ID | Session | タイプ | 説明 | Status |
|----|---------|--------|------|--------|
| 0XX | S27 | docs | ドキュメント整理 | ✅ |
```

---

## 📋 チェックリスト実行例

### 例 1: GIT_COMMIT_CONVENTION.md 作成

**判定フロー**:
```
【1】分類: ×既存に統合不可 → 新規ドキュメント必須
【2】Tier: Tier 2 (運用ガイド)
【3】行数: 150 行見積 (最大: 200行)
【4】参照: GIT_WORKFLOW.md ← → このドキュメント
【5】スキル化: YES (本プロジェクト固有規約)
```

**チェック内容**:
- [ ] Tier 2 行数目標 (100-150行) に設定
- [ ] GIT_WORKFLOW.md にリンク追加
- [ ] スキル化の検討 (agent-customization 参照)
- [ ] SESSION_PROGRESS.md に記録
- [ ] WORK_ID_REGISTRY.md に追加

### 例 2: APP_CANDIDATES_ADVANCED.md 分割作成

**判定フロー**:
```
【1】分類: ×APP_CANDIDATES.md から分割
【2】Tier: Tier 3 (ロードマップ)
【3】行数: 150 行見積 (最大: 300行)
【4】参照: APP_CANDIDATES.md ← → APP_CANDIDATES_OVERVIEW.md
【5】スキル化: NO (一般的なドキュメント)
```

**チェック内容**:
- [ ] Tier 3 行数目標 (200-300行) に設定
- [ ] APP_CANDIDATES.md との相互参照確立
- [ ] APP_CANDIDATES_OVERVIEW.md に参照追加
- [ ] SESSION_PROGRESS.md に記録

---

## 🔍 作成後の検証

| 項目 | 確認方法 |
|------|---------|
| **行数確認** | `Get-Content ドキュメント.md \| Measure-Object -Line` |
| **リンク確認** | ドキュメント内の `[](ファイル.md)` がすべて有効か |
| **参照整合性** | 参照元・参照先が双方向で正確か |
| **表示確認** | VS Code プレビューで markdown 形式が正しいか |
| **スペル・文法** | 誤字脱字、不自然な表現がないか |

---

## 📊 ドキュメント行数監視ダッシュボード

**定期実行**：各セッション終了時、以下を集計

```powershell
Get-ChildItem -Path "." -Filter "*.md" | 
    Select-Object @{Name="ファイル"; Expression={$_.Name}},
                  @{Name="行数"; Expression={(Get-Content $_.FullName | Measure-Object -Line).Lines}} |
    Sort-Object 行数 -Descending
```

**警告基準**:
- 400行超過 → 分割検討（このチェックリスト実施）
- 600行超過 → **強制分割**（フェーズ完了時に実施）

---

## 🔗 関連ドキュメント

| ドキュメント | 用途 |
|----------|------|
| [DOCUMENTATION_STRATEGY.md](DOCUMENTATION_STRATEGY.md) | Tier 別目標行数、テンプレート |
| [SESSION_PROGRESS.md](SESSION_PROGRESS.md) | セッション記録テンプレート |
| [WORK_ID_REGISTRY.md](WORK_ID_REGISTRY.md) | Work ID 登録方法 |
| [agents.md](agents.md) | プロジェクト概要・参照リンク |

---

**最終更新**: 2026年4月13日 | **バージョン**: 1.0
