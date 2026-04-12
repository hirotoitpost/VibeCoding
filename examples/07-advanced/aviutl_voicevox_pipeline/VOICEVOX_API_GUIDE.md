# VOICEVOX API ドキュメント & スピーカー情報

**最終更新**: 2026年4月12日  
**API バージョン**: 0.25.1

## API エンドポイント一覧

| エンドポイント | メソッド | 目的 | パラメータ |
|-------------|---------|------|-----------|
| `/version` | GET | API バージョン取得 | - |
| `/speakers` | GET | スピーカー・スタイル一覧 | - |
| `/audio_query` | POST | テキスト→音声合成クエリ | `speaker`, `style_id`, `text` |
| `/synthesis` | POST | クエリ→音声生成 | `speaker`, `style_id` |
| `/docs` | GET | Swagger UI ドキュメント | - |

## 使用中のスピーカー情報

### 🎤 デフォルト: 四国めたん (Speaker ID: 2)

| スタイル | Style ID | タイプ | 説明 |
|--------|---------|-------|------|
| **ノーマル** | **2** | talk | 標準的な話し方 ✅ 使用中 |
| あまあま | 0 | talk | 甘えた話し方 |
| ツンツン | 6 | talk | つっけんどんな話し方 |
| セクシー | 4 | talk | セクシーな話し方 |
| ささやき | 36 | talk | ささやき |
| ヒソヒソ | 37 | talk | こっそり話す感じ |

## ID 017 で使用中の API パラメータ

### generate_voice.ps1

```powershell
# 初期設定
$SpeakerId = 2          # 四国めたん
$StyleId = 2            # ノーマル

# audio_query エンドポイント（テキスト→クエリ）
$url = "/audio_query?speaker=$SpeakerId&style_id=$StyleId&text=$text"
Invoke-RestMethod -Uri $url -Method Post -ContentType "application/json"

# synthesis エンドポイント（クエリ→音声）
$url = "/synthesis?speaker=$SpeakerId&style_id=$StyleId"
Invoke-WebRequest -Uri $url -Method Post -Body $queryJson
```

## 利用可能なスピーカー一覧（全 53 スピーカー）

### 統計
- **スピーカー数**: 53
- **総スタイル数**: 160+
- **標準スタイル**: ほぼ全員が「ノーマル」スタイルを持つ

### スピーカー別スタイル数

| スピーカー | スタイル数 | ノーマル Style ID |
|--------|---------|-----------------|
| 四国めたん | 6 | 2 ✅ |
| ずんだもん | 8 | 3 |
| 春日部つむぎ | 1 | 8 |
| 雨晴はう | 1 | 10 |
| 波音リツ | 2 | 9 |
| 玄野武宏 | 4 | 11 |
| 白上虎太郎 | 5 | 12 |
| 青山龍星 | 7 | 13 |
| 冥鳴ひまり | 1 | 14 |
| 九州そら | 5 | 16 |
| ...他 35 スピーカー | 1-3 | - |

## 修正履歴

### 2026年4月12日 - Speaker ID 修正

**問題**:
- スクリプトで Speaker ID 14 を使用（冥鳴ひまり）
- コメントが誤っていた（「春日部つむぎ」と表記）

**解決**:
- ✅ DeaultspX Speaker ID を 2 に変更（四国めたん）
- ✅ Style ID を明示的に設定（2 = ノーマル）
- ✅ API 呼び出しに `style_id` パラメータを追加
- ✅ テスト完了：音声生成確認、Exo ファイル生成確認

## API 呼び出し例

### 例 1: 四国めたんの標準音声生成

```powershell
# Step 1: Query 生成
$text = "こんにちは、世界！"
$url = "http://localhost:50021/audio_query?speaker=2&style_id=2&text=$($text | UrlEncode)"
$query = Invoke-RestMethod -Uri $url -Method Post -ContentType "application/json"

# Step 2: 音声合成
$url = "http://localhost:50021/synthesis?speaker=2&style_id=2"
$audio = Invoke-WebRequest -Uri $url -Method Post `
    -Body ($query | ConvertTo-Json) -ContentType "application/json"

# Step 3: ファイル保存
[System.IO.File]::WriteAllBytes("output.wav", $audio.Content)
```

### 例 2: 他のスピーカーを使用

```powershell
# ずんだもんのツンツンスタイル
$SpeakerId = 3    # ずんだもん
$StyleId = 7      # ツンツン

# 同じ流れで API 呼び出し
```

## 推奨設定

| 設定 | 値 | 理由 |
|-----|---|----|
| デフォルト Speaker | 2 (四国めたん) | VOICEVOX の公式デフォルト |
| デフォルト Style | 2 (ノーマル) | 最も標準的な話し方 |
| API ポート | 50021 | VOICEVOX デフォルトポート |
| 環境変数 | VOICEVOX_PORT | カスタムポート対応 |

## トラブルシューティング

### Q: 音声が生成されない
**A**: VOICEVOX が起動していることを確認
```powershell
Invoke-RestMethod -Uri "http://localhost:50021/version"  # 起動確認
```

### Q: "Speaker not found" エラー
**A**: speaker ID と style_id が有効か確認
```powershell
# スピーカー一覧を要求
$speakers = Invoke-RestMethod -Uri "http://localhost:50021/speakers"
$speakers[0]  # 最初のスピーカー確認
```

### Q: 音質が異なる
**A**: style_id が異なると音声特性が変わります。以下で確認：
```powershell
# 四国めたん: style_id 0 = あまあま, 2 = ノーマル, 6 = ツンツン
```

## 参考リンク

- CLI: `.\scripts\generate_voice.ps1` 実行
- API Swagger: http://127.0.0.1:50021/docs#/
- プロジェクト: `examples/07-advanced/aviutl_voicevox_pipeline/`
