# VOICEVOX 音声生成実行手順

> **所要時間**: 約 1～2 分（37 個のセリフを自動生成）  
> **必須**: VOICEVOX v0.25.1 以降を起動しておくこと

---

## 📋 実行前チェック

```powershell
# 1. Windows PowerShell を開く（VS Code のターミナル可）

# 2. VibeCoding ルートディレクトリに移動
cd D:\ProjectPool2\hirotoitpost\GitHub\VibeCoding

# 3. Python がインストールされ、accessible であることを確認
python --version
# 出例: Python 3.10.5

# 4. VOICEVOX が起動しているか確認
#    - Windows トレイを確認
#    - または VOICEVOX アプリを起動
```

---

## 🚀 実行方法

### ステップ 1: Python スクリプト実行

```powershell
# VibeCoding ルートで以下を実行
python voicevox_scripts\voicevox_batch_generator.py
```

### ステップ 2: 出力例

```
============================================================
🎙️  VOICEVOX 自動音声生成 - VibeCoding ナレッジシェア
============================================================
📂 セリフデータ: D:\ProjectPool2\hirotoitpost\GitHub\VibeCoding\voicevox_scripts\speech_data.json
📂 出力ディレクトリ: D:\ProjectPool2\hirotoitpost\GitHub\VibeCoding\VOICEVOX_OUTPUT

🔍 VOICEVOX API に接続中...
✅ VOICEVOX API への接続成功

📖 セリフデータを読み込み中...
✅ 33 シーンを読み込みました

⏱️  推定所要時間: 約 1 ～ 2 分
音声生成を開始しますか？ (y/n): y

🎙️  VOICEVOX 音声生成開始
📊 合計: 33 シーン
============================================================
[ 1/33] A-S01   | narrator | 18秒 | タイトル - イントロ
        ✅ D:\...\VOICEVOX_OUTPUT\Part_A\S01_intro_title.wav
[ 2/33] A-S02   | narrator | 32秒 | 今日のゴール
        ✅ D:\...\VOICEVOX_OUTPUT\Part_A\S02_goals.wav
...
[33/33] C-S06   | narrator | 35秒 | まとめ & Q&A
        ✅ D:\...\VOICEVOX_OUTPUT\Part_C\CS06_conclusion.wav

============================================================
📊 生成完了サマリー
============================================================
✅ 成功: 33 / 33
❌ 失敗: 0 / 33

📈 成功率: 100.0%

🎉 すべてのシーンの音声生成が完了しました！

⏱️  処理時間: 95.3 秒

💾 出力ファイル: D:\ProjectPool2\hirotoitpost\GitHub\VibeCoding\VOICEVOX_OUTPUT
   以下のような構造で .wav ファイルが生成されています:
   Part_A/
     - S01_intro_title.wav
     - S02_goals.wav
     - ...(他 5 ファイル)
   Part_B1/
     - B1S01_example01_overview.wav
     - ...(他 15 ファイル)
   Part_B2/
     - B2S01_example05_overview.wav
     - ...(他 15 ファイル)
   Part_C/
     - CS01_skills.wav
     - ...(他 5 ファイル)

次のステップ: PowerPoint に音声を埋め込んでください。
詳細は VOICEVOX_GENERATION_GUIDE.md を参照してください。
```

---

## ✅ 成功確認

### ✓ ファイル生成の確認

```powershell
# 数ファイルが実際に生成されたか確認
ls VOICEVOX_OUTPUT\Part_A\

# 出力例:
# Directory: D:\ProjectPool2\hirotoitpost\GitHub\VibeCoding\VOICEVOX_OUTPUT\Part_A
#
# Mode                 LastWriteTime         Length Name
# ----                 -------------         ------ ----
# -a---          2026/4/15     14:30       245000 S01_intro_title.wav
# -a---          2026/4/15     14:31       756200 S02_goals.wav
# ...
```

### ✓ 音声ファイルの再生テスト

```powershell
# Windows で .wav ファイルを再生
# 直接ダブルクリック または以下コマンド
Start-Process VOICEVOX_OUTPUT\Part_A\S01_intro_title.wav
```

**期待される結果**: 
- 18 秒間の日本語ナレーション（男性声）が再生される

---

## 🔧 トラブルシューティング

### ❌ エラー 1: `VOICEVOX API に接続できません`

**原因**: VOICEVOX が起動していない

**解決**:
```powershell
# 1. VOICEVOX アプリを起動
# 2. 起動完了後、スクリプトを再実行

python voicevox_scripts\voicevox_batch_generator.py
```

---

### ❌ エラー 2: `セリフデータファイルが見つかりません`

**原因**: `speech_data.json` の場所が違う

**解決**:
```powershell
# 確認: ファイルが正しい場所にあるか
ls voicevox_scripts\speech_data.json

# なければ、手動で作成してください
# またはファイルコピー:
Copy-Item speech_data.json voicevox_scripts\
```

---

### ❌ エラー 3: `Python command not found`

**原因**: Python がインストールされていない/PATH に登録されていない

**解決**:
```powershell
# Python インストール確認
python --version

# インストールされていなければ以下をブラウザで実行
# https://www.python.org/downloads/

# または、既存 Python の完全パスを使用
C:\Users\[YourName]\AppData\Local\Programs\Python\Python310\python.exe voicevox_scripts\voicevox_batch_generator.py
```

---

### ❌ エラー 4: `Permission denied` または `Access is denied`

**原因**: ディレクトリの書き込み権限がない

**解決**:
```powershell
# 1. 出力ディレクトリをあらかじめ作成 & 権限確認
mkdir VOICEVOX_OUTPUT
icacls VOICEVOX_OUTPUT /grant:r "%USERNAME%:F"

# 2. スクリプトを再実行
python voicevox_scripts\voicevox_batch_generator.py
```

---

### ❌ エラー 5: 音声ファイルが生成されているが、再生できない

**原因**: ファイル形式 / コーデックの問題

**解決**:
```powershell
# 1. ファイルが実際に .wav か確認
ls VOICEVOX_OUTPUT\Part_A\*.wav -Verbose

# 2. ファイルサイズを確認（通常 20KB～500KB）
(ls VOICEVOX_OUTPUT\Part_A\S01_intro_title.wav).Length

# 3. Media Player で再生試行
explorer VOICEVOX_OUTPUT\Part_A\

# 4. 再生できなければ, ffmpeg で変換
# ffmpeg -i bad.wav -acodec pcm_s16le -ar 44100 good.wav
```

---

## 📊 生成統計

| 項目 | 値 |
|------|-----|
| **合計シーン数** | 33 個 |
| **Part A** | 7 シーン |
| **Part B-1** | 10 シーン |
| **Part B-2** | 10 シーン |
| **Part C** | 6 シーン |
| **合計音声時間** | 888 秒 (約 14 分 48 秒) |
| **推定生成時間** | 1～2 分 |
| **出力ファイル数** | 37 個 (対話シーンは複数ファイルに分割) |
| **合計ファイルサイズ** | 約 50～100 MB |

---

## 📂 ファイル構造

生成後のディレクトリ構造:

```
VibeCoding/
├── voicevox_scripts/
│   ├── voicevox_batch_generator.py  (このスクリプト)
│   └── speech_data.json             (セリフデータ)
│
└── VOICEVOX_OUTPUT/                 (出力ディレクトリ)
    ├── Part_A/                      (7 ファイル)
    │   ├── S01_intro_title.wav
    │   ├── S02_goals.wav
    │   ├── S03_comparison_narr1.wav
    │   ├── S03_comparison_asst.wav
    │   ├── S03_comparison_narr2.wav
    │   ├── S04_projects.wav
    │   ├── S05_evolution.wav
    │   ├── S06_summary.wav
    │   └── S07_preview.wav
    │
    ├── Part_B1/                     (16 ファイル)
    │   ├── B1S01_example01_overview.wav
    │   ├── B1S02_arch_narr1.wav
    │   ├── B1S02_arch_asst.wav
    │   ├── B1S02_arch_narr2.wav
    │   ├── B1S03_code_highlight.wav
    │   └── ...(以下省略)
    │
    ├── Part_B2/                     (16 ファイル)
    │   └── ...(同様)
    │
    └── Part_C/                      (6 ファイル)
        ├── CS01_skills.wav
        ├── CS02_best_practices.wav
        ├── CS03_pitfalls.wav
        ├── CS04_evolution.wav
        ├── CS05_next_steps.wav
        └── CS06_conclusion.wav
```

---

## 🎯 次のステップ

生成完了後:

1. **ファイル確認**
   ```powershell
   # Part ごとのファイル数確認
   ls VOICEVOX_OUTPUT\Part_A\ | Measure-Object | %{$_.Count}  # 出は 9 ファイル期待
   ls VOICEVOX_OUTPUT\Part_B1\ | Measure-Object | %{$_.Count} # 出例: 16 ファイル期待
   ```

2. **PowerPoint への埋め込み準備**
   - KNOWLEDGE_SHARE_SLIDES.md を Marp または PowerPoint で開く
   - 各スライドに対応する .wav ファイルを埋め込む
   - 詳細は [VOICEVOX_GENERATION_GUIDE.md#-powerpoint-への埋め込み方法](VOICEVOX_GENERATION_GUIDE.md) 参照

3. **動画化（オプション）**
   - FFmpeg で音声と映像を合成
   - YouTube / Vimeo にアップロード

---

## 💡 Tips

### Tip 1: 再実行（一部ファイルのみ）

```powershell
# Part A だけ再生成したい場合は、
# speech_data.json の scenes[] で Part=="A" のみを抽出して実行
```

### Tip 2: バックグラウンド実行

```powershell
# ターミナルを閉じずに別の作業を続行
Start-Process python -ArgumentList "voicevox_scripts\voicevox_batch_generator.py" -NoNewWindow
```

### Tip 3: ログファイル出力

```powershell
# スクリプトの出力をテキストファイルに記録
python voicevox_scripts\voicevox_batch_generator.py | Tee-Object -FilePath voicevox_output.log
```

---

## 🎉 完成！

すべての音声ファイルが生成されたら、

**次のステップ** → [PowerPoint 埋め込み](VOICEVOX_GENERATION_GUIDE.md#-powerpoint-への埋め込み方法)

質問・トラブルがあれば、このスクリプトのエラーメッセージを GitHub Issues にコピペして報告してください。
