# コントリビューター向けガイド

このドキュメントは、VibeCoding プロジェクトへのコントリビューション方法を説明します。

---

## 🚀 クイックスタート

### 1. リポジトリをフォークしてクローン

```bash
git clone https://github.com/YOUR_USERNAME/VibeCoding.git
cd VibeCoding
```

### 2. 開発ブランチを作成

```bash
git checkout -b feature/YOUR_BRANCH_NAME
```

### 3. 変更を実装

- コードを編集
- テストを追加・実行
- ドキュメントを更新

### 4. コミットして Push

```bash
git add .
git commit -m "feat: 簡潔で説明的なメッセージ"
git push origin feature/YOUR_BRANCH_NAME
```

### 5. プルリクエストを作成

GitHub Web UI で PR を作成してください（詳細は [PULL_REQUEST_TEMPLATE.md](PULL_REQUEST_TEMPLATE.md) を参照）。

---

## 📋 コントリビューションの種類

### 🐛 バグ修正

- Issue を参照して修正してください
- テストケースを含めてください
- 修正内容を PR に詳細に記載してください

### ✨ 新機能追加

- 事前に Issue や Discussion で提案してください
- `APP_CANDIDATES.md` に記載されているロードマップに合致しているか確認してください
- テスト、ドキュメント、E2E テストを含めてください

### 📚 ドキュメント改善

- タイポ修正
- 説明の改善
- 新しいガイド作成
- 翻訳（今後対応予定）

---

## 🛠️ 開発環境セットアップ

詳細は [SETUP.md](SETUP.md) を参照してください。

### 必須要件

- Windows / macOS / Linux
- Python 3.9+
- Node.js 16+
- Docker & Docker Compose（オプション）
- Git

### セットアップステップ

```bash
# 1. 仮想環境作成
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\Activate.ps1

# 2. 依存関係インストール
pip install -r requirements.txt

# 3. 環境変数設定
cp .env.example .env
# .env を編集して必要な API キーを設定

# 4. テスト実行
pytest
```

---

## 📖 コードスタイル・ガイドライン

### Python

- **フォーマッター**: `black`
- **リンター**: `flake8`
- **型チェック**: `mypy`

```bash
black .
flake8 .
mypy .
```

### JavaScript / React

- **フォーマッター**: `prettier`
- **リンター**: `eslint`

```bash
npm run format
npm run lint
```

### ドキュメント

- **マークダウン**: 1 行 100 文字以内（ドキュメント説明部分）
- **行数**: 400 行超は分割検討（[DOCUMENTATION_STRATEGY.md](DOCUMENTATION_STRATEGY.md) 参照）
- **言語**: 日本語（メインドキュメント）

---

## ✅ PR チェックリスト

プルリクエストを作成する前に、以下を確認してください：

- [ ] `main` ブランチから最新を Pull してマージ競合がないか確認
- [ ] テストが全て Pass している
- [ ] コードがスタイルガイドに従っている
- [ ] ドキュメントが更新されている
- [ ] コミットメッセージが明確で説明的
- [ ] 大きな変更の場合は Issue が参照されている

---

## 🔄 Git ワークフロー

詳細は [GIT_WORKFLOW.md](GIT_WORKFLOW.md) を参照してください。

### ブランチ命名規則

```
feature/[ID]_[brief-description]  # 新機能
fix/[ID]_[brief-description]      # バグ修正
docs/[ID]_[brief-description]     # ドキュメント
refactor/[ID]_[brief-description] # リファクタリング
```

### コミットメッセージ形式

```
feat: 新機能について簡潔に説明
fix: バグ修正の内容
docs: ドキュメント更新内容
refactor: リファクタリング内容

本文（必要に応じて詳細を記載）
- 背景（Why）
- 変更内容（What）
- 検証方法（How to verify）
```

---

## 📞 質問・サポート

- **Issue**: バグ報告や機能リクエストは Issue を作成してください
- **Discussion**: アイデアや質問は Discussion で議論してください
- **Documentation**: [DEVELOPMENT_PROCESS.md](DEVELOPMENT_PROCESS.md) でトラブルシューティング方法を確認

---

## 🙏 感謝

VibeCoding プロジェクトへのコントリビューション、ありがとうございます！

---

**詳細**: [agents.md](agents.md) - AI エージェント運用ルール  
**参考**: [LEARNING_PATH.md](LEARNING_PATH.md) - プロジェクトロードマップ
