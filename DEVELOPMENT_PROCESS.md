# 開発・デバッグプロセス

## 🔧 トラブルシューティング・デバッグワークフロー

実装中に問題が発生した場合の標準的な対応プロセス：

### Step 1: エラーメッセージの読み込みと分類
```
発生した症状を記録:
- エラーメッセージの正確なテキスト
- スタックトレース（最後の行が重要）
- 実行したコマンド
- 入力値・パラメータ
- 環境情報（OS、バージョン、ライブラリ）
```

**エラーの分類**:
- URLエラー（入力値の形式）
- インポート・依存関係エラー（環境）
- ロジックエラー（実装）
- テスト環境エラー（独立性）

### Step 2: 原因の仮説立て
```
推定される原因:
- コード内の具体的な箇所
- 関連ライブラリのドキュメント確認
- 同様の問題の先例検索
- 外部 API やシステムの動作確認
```

### Step 3: 問題の再現
```
最小限の再現例を作成:
- 単純なテストケース
- print やログでの値の追跡
- デバッグモードでの実行
```

### Step 4: 原因の確定と修正
```
修正実装:
- 根本原因に対する修正
- 関連する他の箇所への波及確認
- エッジケース（複数単語、特殊文字など）への対応
```

### Step 5: テスト・検証
```
修正の検証:
- 修正前後での動作比較
- 関連テストの実行
- エッジケースのテスト
- 本番環境での動作確認
```

### Step 6: 学習と記録
```
今後への活用:
- 具体例をトラブルシューティングガイドに記録
  → examples/[プロジェクト]/TROUBLESHOOTING.md
- ベストプラクティスを docs/ に記録
- git commit で履歴に残す
```

## 📋 トラブルシューティング例

各プロジェクトで発生したトラブルシューティングドキュメント：

| プロジェクト | ドキュメント | 主な問題 |
|-----------|-----------|--------|
| 天気情報取得ツール | [TROUBLESHOOTING.md](examples/01-basic/weather-tool/TROUBLESHOOTING.md) | URL エンコーディング、依存関係、テスト環境独立性 |
| Web 家計簿 | [ID_010_DNS_GATEWAY_GUIDE.md - Troubleshooting](examples/02-intermediate/web-accounting-app/ID_010_DNS_GATEWAY_GUIDE.md#-トラブルシューティング) | xdg-open エラー（Vite）、API 接続問題（VITE_API_URL） |

### 具体例: Session 8 - Docker + Vite トラブルシューティング

**Issue 1: xdg-open エラー**
```
Error: cannot open display
```
**原因**: Vite が Docker コンテナ内でブラウザを起動しようとしたが、表示環境がない  
**修正**: `vite.config.js` で `open: false` を設定  
**学習ポイント**: Docker の UI 無しコンテナではブラウザ自動起動は不可  

**Issue 2: API 接続失敗**
```
GET http://server:5000/api/... net::ERR_NAME_NOT_RESOLVED
```
**原因**: ブラウザがコンテナ内部の hostname `server:5000` を解決できない  
**修正**: `docker-compose.yml` で `VITE_API_URL=localhost:5000` に変更  
**学習ポイント**: Docker internal network と host network は別。クライアントは host network からアクセス  

## 💡 Vibe Coding でのデバッグ時のエージェント指示

### 推奨される指示パターン

```markdown
# エラーが発生しました

症状:
- [エラーメッセージの正確なテキスト]
- [実行コマンド]
- [入力値]

原因の推測:
- [自分の仮説]

対応:
- [何を確認すべきか]
- [どのように修正すべきか]
```

### 逆に避けるべき指示

```markdown
❌ 「エラーが出ました。修正してください」
✅ 「URL encoding エラーが出ました: 'URL can't contain control characters'
    パラメータに空白を含む都市名（'New York'）を渡した時です。
    urllib.parse.urlencode を使用して修正してください」
```

---

**参考**: [GIT_WORKFLOW.md](GIT_WORKFLOW.md) - Git/GitHub ワークフロー詳細
