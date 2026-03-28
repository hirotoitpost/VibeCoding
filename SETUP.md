# 開発環境セットアップ ガイド

## 概要
このドキュメントは、VideCoding プロジェクトの開発環境構築手順を説明します。  
自動セットアップスクリプトと手動セットアップの2つの方法を提供します。

---

## 前提条件

### 必須
- Git がインストール済み
- VS Code がインストール済み

### 推奨
- PowerShell 7.0 以上（Windows）
- Bash（Linux/macOS）

---

## 📦 クイックセットアップ（推奨）

### Windows（PowerShell）
```powershell
# リポジトリをクローン
git clone https://github.com/hirotoitpost/VideCoding.git
cd VideCoding

# セットアップスクリプト実行
./scripts/setup-dev-env.ps1

# VS Code で開く
code .
```

### Linux/macOS（Bash）
```bash
# リポジトリをクローン
git clone https://github.com/hirotoitpost/VideCoding.git
cd VideCoding

# セットアップスクリプト実行
bash scripts/setup-linux.sh

# VS Code で開く
code .
```

---

## 🛠️ 手動セットアップ

### ステップ 1: リポジトリのクローン
```bash
git clone https://github.com/hirotoitpost/VideCoding.git
cd VideCoding
```

### ステップ 2: 環境ファイルの準備
```bash
# .env.example から .env を作成
cp .env.example .env

# .env を開いて、必要な値を設定
# - API キー
# - 開発環境の パス
# - その他の環境変数
```

### ステップ 3: 開発環境の検証
```bash
# Python がインストール済みか確認（例）
python --version

# Node.js がインストール済みか確認（例）
node --version

# その他の必要なツールを確認
```

### ステップ 4: VS Code 拡張の導入

以下の拡張をインストール：

- **Cursor** or **GitHub Copilot** または **Claude Code**
  - Vibe Coding の中核ツール
  - [Cursor](https://www.cursor.com/)
  - [GitHub Copilot](https://github.com/features/copilot)
  - Claude Code（API キーが必要）

- **Python** (Python関連プロジェクト用)
  - Publisher: Microsoft

- **Pylance** (Python関連プロジェクト用)
  - Publisher: Microsoft

- **ESLint** (JavaScript/TypeScript関連プロジェクト用)
  - Publisher: Microsoft

- **Prettier** (コード整形用)
  - Publisher: Prettier

- **GitLens** (Git管理用)
  - Publisher: GitKraken

---

## 📋 セットアップスクリプト設計

### `scripts/setup-dev-env.ps1` (Windows/PowerShell)

**機能**:
1. システム要件の確認（Git, VS Code）
2. 環境ファイルの初期化
3. 依存リポジトリのクローン（必要に応じて）
4. 開発環境のパス設定
5. 初回テストの実行
6. 結果レポート出力

**使用方法**:
```powershell
./scripts/setup-dev-env.ps1 -Verbose
```

### `scripts/setup-linux.sh` (Linux/macOS)

**機能**:
- `setup-dev-env.ps1` と同等の機能を Unix 系環境向けに提供

**使用方法**:
```bash
bash scripts/setup-linux.sh -v
```

---

## 🔐 環境変数管理

### `.env` ファイルは Git から除外
既に `.gitignore` に設定済み：
```gitignore
.env
.env.local
```

### `.env.example` で構造を共有
チームメンバーが何を設定すべきか理解できるよう、  
`.env.example` に必要な変数の構造を記載：

```examples
# API キー
CLAUDE_API_KEY=your_api_key_here
GITHUB_TOKEN=your_token_here

# 開発環境パス
PYTHON_PATH=/usr/bin/python3
NODE_PATH=/usr/local/bin/node

# プロジェクト設定
PROJECT_NAME=VideCoding
DEBUG_MODE=false
```

---

## 🚀 開発環境起動

### プロジェクト開く
```bash
code .
```

### VS Code で開く
```bash
# または
open -a "Visual Studio Code" .
```

### ワークスペース設定の確認
```bash
# VideCoding.code-workspace を VS Code で開く
code VideCoding.code-workspace
```

---

## ✅ セットアップ完了の確認

以下のすべてが満たされたら、セットアップ完了です：

- [ ] Git が正常に動作
- [ ] VS Code が正常に起動
- [ ] 拡張機能がインストール済み
- [ ] 環境ファイル（.env）が作成済み
- [ ] エディタでコードが開ける
- [ ] ターミナルで git コマンドが実行可能

---

## 🆘 トラブルシューティング

### Git コマンドが認識されない
```powershell
# 再起動を試してみてください
# または PATH を確認
$env:PATH -split ';' | Select-String 'git'
```

### VS Code 拡張がインストールできない
```bash
# 拡張マーケットプレイスを確認
# または 手動で VS Code > Extensions から検索・インストール
```

### 環境変数が読み込まれない
```bash
# .env ファイルの配置を確認
# プロジェクトルートにあるか確認
ls -la | grep .env

# ファイルのパーミッションを確認（Linux/macOS）
chmod 644 .env
```

---

## 📚 参考資料

- [Git Documentation](https://git-scm.com/doc)
- [VS Code Documentation](https://code.visualstudio.com/docs)
- [Cursor Documentation](https://docs.cursor.com/)
- [GitHub Copilot Guide](https://github.com/features/copilot)

---

**最終更新**: 2026年3月28日  
**バージョン**: 1.0
