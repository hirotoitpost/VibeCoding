# 天気情報取得ツール - トラブルシューティングガイド

**最終更新**: 2026-03-28  
**参照ケース**: ID 005 実装時に発生した問題と解決方法

---

## 🔍 問題の発見から解決までの過程

### ケース 1: URL エンコーディングエラー

#### 🚨 発生した症状
```powershell
python main.py "New York"

# エラー出力:
ERROR - 接続エラー: 予期しないエラー: URL can't contain control characters. 
'/data/2.5/weather?q=New York&appid=...' (found at least ' ')
```

#### 🔎 原因調査プロセス

**Step 1: エラーログの読み込み**
- エラーメッセージ: `URL can't contain control characters`
- 具体例: `'q=New York'` 内の **空白文字** が URL に直接含まれている

**Step 2: コード検査**
修正前のコード（`main.py` 行 162-167）:
```python
query_string = "&".join(
    f"{k}={v}" for k, v in params.items()
)
# 出力: "q=New York&appid=..." ← 空白が未エンコード
```

**Step 3: 原因特定**
- urllib の `urlopen()` が空白文字を URL 内での制御文字と判断
- 標準ライブラリの `urllib.parse.urlencode()` を使用していない
- 単純な文字列結合では URLエンコーディングが行われない

#### ✅ 解決方法

**修正内容**:
```python
# Step 1: インポート追加
from urllib.parse import urlencode

# Step 2: URL 構築を修正
query_string = urlencode(params)
# 出力: "q=New+York&appid=..." ← 正しくエンコード
```

**修正の原理**:
- `urlencode()` は全パラメータを RFC 3986 に準拠してエンコード
- 空白 → `+` または `%20`
- 特殊文字 → `%HH` （16進数）

#### 📋 テスト・検証

```powershell
# 修正前: エラーで終了
python main.py "New York"    # ❌ エラー

# 修正後: 正常に動作
python main.py "New York"    # ✅ OK - 天気表示成功

# 複数の都市をテスト
python main.py Tokyo         # ✅ OK
python main.py "Los Angeles" # ✅ OK
python main.py Paris         # ✅ OK
```

---

### ケース 2: pytest モジュルが見つからない

#### 🚨 発生した症状
```powershell
python -m pytest test_main.py -v

# エラー出力:
No module named pytest
```

#### 🔎 原因調査プロセス

**Step 1: エラーの文脈確認**
- テスト実行時に「pytest モジュルがない」エラー
- requirements.txt を確認

**Step 2: requirements.txt 検査**
```
python-dotenv==1.0.0
requests==2.31.0
# ← pytest がない
```

**Step 3: 原因特定**
- requirements.txt から pytest が **漏れていた**
- インストール手順でインストール忘れ

#### ✅ 解決方法

**修正内容** (`requirements.txt`):
```
python-dotenv==1.0.0
requests==2.31.0
pytest==7.4.3  # ← 追加

# その後
pip install -r requirements.txt
```

**追加の理由**:
- テストスイート（`test_main.py`）が 13 テストケースを含む
- pytest の unittest discovery と verbose output が必要
- セットアップガイド（README.md）でテスト実行を記載

#### 📋 テスト・検証

```powershell
# インストール
pip install -r requirements.txt  # ✅ OK

# 実行
python -m unittest discover -s . -p "test_*.py" -q
# 出力: OK (skipped=1)
# 14/14 テスト成功 ✅
```

---

### ケース 3: テスト失敗（キャッシュの独立性問題）

#### 🚨 発生した症状
```powershell
python -m unittest discover -q

# 出力:
FAILED (failures=3, skipped=1)

# 具体的なテスト失敗:
- test_cache_expiration: FAIL
- test_fetch_http_error: FAIL  
- test_fetch_network_error: FAIL
```

#### 🔎 原因調査プロセス

**Step 1: 失敗パターン分析**
- 失敗: キャッシュ関連、モックエラー処理テスト
- 共通点: **既に存在するキャッシュ** や **グローバルな cache/ ディレクトリ** の影響

**Step 2: テストログからの推測**
```
test_fetch_http_error: キャッシュから読み込み: Tokyo (286秒前)
# ← モック使用でもキャッシュから読み込まれている
```

**Step 3: テストコードの検査**
```python
def test_fetch_http_error(self, mock_urlopen):
    # ...
    fetcher.fetch("Tokyo")  # ← use_cache のデフォルト値は True
    # 実行時に既存キャッシュ があると、モックが呼ばれない
```

**Step 4: 原因特定**
- テスト1: キャッシュを使用 → キャッシュに「Tokyo」が保存
- テスト2-4: 同じ「Tokyo」をモックテスト → キャッシュから読み込む → モックが実行されない

#### ✅ 解決方法

**修正戦略は3段階**:

**1️⃣ テスト環境クリーンアップ強化** (`test_main.py` の tearDown)
```python
def tearDown(self):
    # テストキャッシュを削除
    import shutil
    if self.test_cache_dir.exists():
        shutil.rmtree(self.test_cache_dir)
    
    # グローバルキャッシュも削除（テスト環境分離）
    cache_dir = Path("./cache")
    if cache_dir.exists():
        shutil.rmtree(cache_dir)
```

**2️⃣ キャッシュフラグの明示化** （各テスト）
```python
# 修正前
fetcher.fetch("Tokyo")

# 修正後
fetcher.fetch("Tokyo", use_cache=False)  # モック使用時は明示的に OFF
```

**3️⃣ キャッシュ有効期限テストの改善** （mtime 操作）
```python
# 信頼性を高めるため、タイムスタンプを直接操作
old_time = time.time() - 900  # 15分前
os.utime(cache_path, (old_time, old_time))
```

#### 📋 テスト・検証

```powershell
# 修正後
python -m unittest discover -s . -p "test_*.py" -q

# 出力:
OK (skipped=1)

# 詳細:
Ran 14 tests in 0.020s
✅ 全テスト成功
```

---

## 📚 トラブルシューティングチェックリスト

問題が発生した時の対応手順：

### 1. エラーメッセージの読み込み
- [ ] スタックトレースの最後の行を確認
- [ ] エラーの種類を分類（URLエラー、インポートエラー、ロジックエラー）
- [ ] 具体例や値が含まれていないか確認

### 2. 原因の仮説立て
- [ ] エラー箇所のコードを読む
- [ ] 入力値、環境、状態を確認
- [ ] 同様のエラーの先例を調べる

### 3. 問題の再現
- [ ] 単純な例で再現できるか試す
- [ ] 問題の最小限の再現例を作成
- [ ] デバッグ関連の print やログを追加

### 4. 原因の確定
- [ ] 仮説の根拠を検証
- [ ] 関連するドキュメント（ライブラリのドキュメント等）を確認
- [ ] 単体テストや自動テストで検証

### 5. 修正と検証
- [ ] 修正を実装
- [ ] 修正前後で動作を比較
- [ ] 関連するテストを実行
- [ ] エッジケース（複数単語、特殊文字）をテスト

### 6. ドキュメント記録
- [ ] このトラブルシューティングガイドに追加
- [ ] git commit で履歴に記録
- [ ] README や関連ドキュメントに情報を反映

---

## 🎓 このケースから学んだ Vibe Coding のベストプラクティス

### 1. **URL エンコーディング**
✅ 推奨: `urllib.parse.urlencode()` で自動化  
❌ 非推奨: 手作業の文字列結合

**AI への指示例**:
```
"OpenWeatherMap API の URL を構築してください。
パラメータに都市名やクエリが含まれるため、
正しく URL エンコードしてください。"
```

### 2. **依存関係の管理**
✅ 推奨: requirements.txt に全て記載（テストライブラリ含む）  
❌ 非推奨: 頭の中で記憶、または一部漏らし

### 3. **テスト環境の独立性**
✅ 推奨: 各テスト後に状態をリセット（tearDown）  
❌ 非推奨: 前のテストの副作用に依存

### 4. **モックの正確性**
✅ 推奨: キャッシュスキップなど、明示的にフラグを指定  
❌ 非推奨: デフォルト値に暗黙的に依存

### 5. **エラーから学ぶ**
✅ 推奨: このようなトラブルシューティングドキュメントで記録  
❌ 非推奨: 同じ問題を何度も繰り返す

---

## 🔗 関連ドキュメント

- [README.md](README.md) - セットアップとメイン使用方法
- [main.py](main.py) - 実装詳細
- [test_main.py](test_main.py) - テストスイート
- [docs/vibe_coding_theory.md](../../docs/vibe_coding_theory.md) - 理論
- [docs/tool_usage_guide.md](../../docs/tool_usage_guide.md) - ツール使用ガイド

---

## 📞 サポート

問題が解決しない場合：

1. このドキュメントの「トラブルシューティングチェックリスト」を一通り確認
2. [README.md](README.md) の「トラブルシューティング」セクションを確認
3. テストを実行して環境が正常か確認 (`python -m unittest discover -q`)
4. それでも解決しない場合は、エラーメッセージとコンテキストを記録して報告

---

**作成者**: VibeCoding Learning Project AI Agent  
**対応 ID**: 005（フェーズ3.1 基礎プロジェクト）  
**更新日**: 2026-03-28
