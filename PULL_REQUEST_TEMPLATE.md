<!--
VibeCoding プルリクエストテンプレート

🤖 NOTE: このプロジェクトでは、AI エージェント（GitHub Copilot）が feature ブランチを作成し、
このテンプレートに従って PR を投稿します。通常のコントリビューションは CONTRIBUTORS.md を参照してください。

→ [CONTRIBUTORS.md](../CONTRIBUTORS.md) - コントリビューター向けガイド
→ [agents.md](../agents.md) - AI エージェント運用ルール
-->

## 📋 概要

<!-- PR の目的を簡潔に記載 -->
<!-- 例: ID 013 - スマートホーム IoT ハブ の実装 -->

**Work ID**: ID `[YYY]`  
**Phase**: Phase `[X.Y]`  
**Related Issue**: Closes #[NUMBER]  

---

## 🎯 実装内容

<!-- 何を実装したかを記載 -->

- [ ] 機能 A: [説明]
- [ ] 機能 B: [説明]
- [ ] テスト: [テストケース数]
- [ ] ドキュメント: [対象ファイル]

---

## ✅ チェックリスト

### コード品質
- [ ] テストが全て Pass している
- [ ] コードスタイルが遵守されている（`black`, `prettier` など）
- [ ] リンターエラーなし（`flake8`, `eslint` など）
- [ ] 型チェック Pass（関連ファイル）

### ドキュメント
- [ ] README が更新されている
- [ ] API ドキュメントが最新
- [ ] TROUBLESHOOTING に既知の問題を記載（あれば）
- [ ] 新規ファイルに JSDoc / docstring 記載

### 互換性・セキュリティ
- [ ] 既存機能に互換性がない場合は記載
- [ ] 環境変数が必要な場合は `.env.example` に追加
- [ ] シークレット情報がコードに含まれていない

### テスト
- [ ] ローカルテスト完了
- [ ] Docker Compose で動作確認（関連ファイルの場合）
- [ ] E2E テスト Pass（Frontend 変更の場合）

---

## 🔍 検証方法

<!-- 実装者がどのように検証したか、または レビュアーがどのように検証すべきか記載 -->

### ローカル実行方法

```bash
# 例: Python プロジェクト
cd examples/[XX]/[project-name]/
pip install -r requirements.txt
python main.py

# 例: React + Flask プロジェクト
docker-compose up --build
# http://localhost:3000 でアクセス
```

### テスト実行

```bash
pytest -v
npm test  # Frontend の場合
```

---

## 📊 変更統計

<!-- GitHub が自動生成する統計 -->

**Files changed**: [N]  
**Total additions**: +[N]  
**Total deletions**: -[N]  

---

## 🎓 参考資料

- 🛠️ [GIT_WORKFLOW.md](../GIT_WORKFLOW.md) - Git/GitHub 運用ガイド
- 💡 [DEVELOPMENT_PROCESS.md](../DEVELOPMENT_PROCESS.md) - デバッグワークフロー
- 📚 [CONTRIBUTORS.md](../CONTRIBUTORS.md) - コントリビューター向けガイド
- 🎯 [agents.md](../agents.md) - AI エージェント運用ルール

---

## 🤖 AI エージェントについて

このプロジェクトでは、**AI エージェント（GitHub Copilot）** が以下を担当します：

### ✅ AI エージェントの責務
1. **feature ブランチ作成** — `git checkout -b feature/[ID]_[title]`
2. **コード実装** — 機能実装、テスト追加
3. **コミット** — `git add` と `git commit` で変更記録
4. **PR 投稿** — このテンプレートに従って PR を作成
5. **ドキュメント更新** — `main` ブランチでドキュメント修正

### ⏳ ユーザーの責務（人間がやる）
1. **PR レビュー** — GitHub Web UI で変更内容確認
2. **テスト** — ローカルテスト、動作確認
3. **Approve & Merge** — PR を **main** にマージ
4. **ローカル同期** — `git pull origin main` で最新化

### ❌ AI エージェントが **してはいけないこと**
- ❌ feature ブランチを main に `git merge` する
- ❌ PR を自分で Approve / Merge する
- ❌ `git push origin main` を直接実行（ドキュメント更新以外）
- ❌ コンフリクト解決後に勝手にマージする

---

## 📝 レビュアーへのメモ

<!-- 変更内容で注意すべき点、確認してほしい点があれば記載 -->

<!-- 例:
- API レスポンス形式が変更されているため、Frontend の対応が必要
- Docker イメージサイズが 50MB 増加したため、最適化の検討が必要
- デモ環境での検証をお願いします
-->

---

**テンプレート参考**: [PULL_REQUEST_TEMPLATE.md](https://github.com/hirotoitpost/VibeCoding/blob/main/PULL_REQUEST_TEMPLATE.md)  
**更新**: 2026年4月2日
