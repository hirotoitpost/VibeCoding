# Git/GitHub ワークフロー

本ドキュメントは、VideoCoding プロジェクトにおける Git/GitHub の運用ガイドです。

詳細なマージ競合解消手順は [MERGE_CONFLICT_GUIDE.md](MERGE_CONFLICT_GUIDE.md) を参照。

## 🔀 ブランチ戦略

### ブランチ名の形式
```
feature/作業ID_主な作業内容のタイトル

例:
  feature/001_プロジェクト初期化
  feature/002_基礎プロジェクト実装
  feature/003_ツール調査ドキュメント
```

**作業IDについて**:
- 本来は Redmine チケット番号を使用
- 現状では AI エージェントが連番で発行（001, 002, 003...）
- 全作業で一意の ID を付与

### ブランチ作成手順
```bash
# デフォルトブランチを最新に
git fetch origin
git checkout master
git pull origin master

# 作業ブランチを master から生成
git checkout -b feature/作業ID_タイトル
```

---

## 💬 コミットメッセージの書式

### テンプレート
```
refs #作業ID コミット内容のサマリー

詳細説明（複数行可）
- 変更点1
- 変更点2
```

### 記入ルール
- 1行目: `refs #作業ID` + スペース + サマリー（50文字程度）
- 2行目: 空行
- 3行目以降: 詳細（何を、なぜ、どう変わったか）
- リンク: GitHub Issue/PR へ自動リンク

### 例
```
refs #002 天気情報取得ツールの実装

- OpenWeatherMap API との連携
- エラーハンドリングの追加
- 5分キャッシング機能を実装
```

---

## 📤 プルリクエスト（PR）の投稿

### PR 投稿タイミング
- **区切りの良いタイミング**: 各フェーズ完了時、大きな機能単位
- **推奨**: 1 PR = 1 論理的単位（複数ファイルの更新は OK）

### PR タイトルの書式
```
refs #作業ID マージする作業内容のサマリー

例:
  refs #002 基礎プロジェクト（天気情報ツール）実装完了
```

### PR 本文の書式
```
refs #作業ID マージする作業内容のサマリー

## 概要
この PR では[作業内容]を実装しました。

## 含まれる変更
[コミットID] コミットタイトル
[コミットID] コミットタイトル

例:
[a1b2c3d] refs #002 天気情報取得ツールの実装
[d4e5f6g] refs #002 テストケースの追加
[h7i8j9k] refs #002 README.md にセットアップ手順を追記

## レビューポイント
- [確認事項1]
- [確認事項2]

## テスト
- [ ] ローカルテスト成功
- [ ] エラーケーステスト成功
```

### PR 本文更新時の課題と解決方法（Session 4 トライ & エラー）

**発生した問題**:
1. `gh pr edit` でダイレクト文字列渡しでエラー発生
   - ❌ `gh pr edit 2 --body "..."`
   - 原因: 改行やクォートのエスケープが複雑化

2. `--body "..."` フラグで GraphQL エラー
   - ❌ `gh pr edit 2 --body "..."`
   - エラー: `Projects (classic) is being deprecated...`

3. `--body-file` フラグでファイル読み込み試行
   - ⚠️ `gh pr edit 2 --body-file pr_body.md`
   - 再度 GraphQL エラー発生

**最終的な解決方法**:
```bash
# テンポラリでPR本文ファイルを作成
cat > pr_body.md << 'EOF'
refs #007 Vibe Coding 指示設計パターン・ガイド完成

## 概要
このPRでは...
EOF

# REST API 経由で更新（GraphQL の classic projects 問題を回避）
$body = Get-Content pr_body.md -Raw
gh api repos/hirotoitpost/VideCoding/pulls/2 -X PATCH -f body=`"$body`"
```

**ベストプラクティス**:
- 複雑な PR 本文は **ファイルで管理** する
- GitHub CLI の GraphQL エラー時は **REST API 経由で更新**
- テンポラリファイルは使用後に削除

---

## ✅ PR マージ後の作業

### ステップ 1: ユーザーがマージを宣言
ユーザーから「PR マージ完了」の通知を受ける

### ステップ 2: フェッチとリベース
```bash
# リモートを最新に
git fetch origin

# master ブランチを最新に
git checkout master
git pull origin master

# 作業ブランチへ戻る
git checkout feature/作業ID_タイトル

# master に対してリベース
git rebase origin/master
# 競合があれば解決して
# git add .
# git rebase --continue
```

### ステップ 3: リモートブランチ削除後の処理
ユーザーがリモートブランチを削除した後：

```bash
# ローカルブランチを最新に
git fetch origin

# master を最新に
git checkout master
git pull origin master

# 作業ブランチを削除（ファストフォワード完了のため不要に）
git branch -d feature/作業ID_タイトル

# 次の作業へ
# 新しいブランチを作成して作業継続
```

---

## 関連ドキュメント

- [MERGE_CONFLICT_GUIDE.md](MERGE_CONFLICT_GUIDE.md) - マージ競合の詳細手順
- [DEVELOPMENT_PROCESS.md](DEVELOPMENT_PROCESS.md) - 開発・デバッグプロセス
