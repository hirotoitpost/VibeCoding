# AviUtl + PSDToolKit + VOICEVOX 動画自動生成システム
# セットアップガイド

## 概要

このガイドでは、VibeCoding 解説動画を自動生成するための環境セットアップ手順を説明します。

---

## 前提条件

| ツール | 確認方法 | 入手先 |
|-------|---------|-------|
| **AviUtl** | `AVIUTL_ROOT` 環境変数 | http://spring-fragrance.mints.ne.jp/ |
| **PSDToolKit** | `$AVIUTL_ROOT\plugins\PSDToolKit.auf` | https://oov.github.io/aviutl_psdtoolkit/ |
| **VOICEVOX** | `http://localhost:50021/version` | https://voicevox.hiroshiba.jp/ |
| **PowerShell** | `$PSVersionTable.PSVersion` | 5.1 以上 |

---

## Step 1: 環境変数の確認

`.env` ファイルに以下が設定されていることを確認してください:

```dotenv
AVIUTL_ROOT=C:\AviUtl
PSDTOOLKIT_ROOT=C:\AviUtl\plugins\PSDToolKit
VOICEVOX_ROOT=C:\Program Files\VOICEVOX
VOICEVOX_PORT=50021

# 話し手設定（2人体制）
SPEAKER_1_ID=8          # 進行役
SPEAKER_1_STYLE_ID=8
SPEAKER_2_ID=3          # 相槌役
SPEAKER_2_STYLE_ID=3

# 立ち絵 PSD ファイル
PSD_CHARACTER_1=C:\PSD_Assets\character_1.psd
PSD_CHARACTER_2=C:\PSD_Assets\character_2.psd
```

PowerShell で確認:
```powershell
$env:SPEAKER_1_ID        # => 8
$env:SPEAKER_2_ID        # => 3
$env:PSD_CHARACTER_1      # => C:\PSD_Assets\character_1.psd
$env:PSD_CHARACTER_2      # => C:\PSD_Assets\character_2.psd
```

---

## Step 2: PSDToolKit の導入

1. [PSDToolKit 公式](https://oov.github.io/aviutl_psdtoolkit/) からダウンロード
2. `$AVIUTL_ROOT\plugins\` フォルダに配置:
   ```
   C:\AviUtl\plugins\PSDToolKit.auf
   C:\AviUtl\plugins\PSDToolKit\
   ```
3. AviUtl を起動して「フィルタ」メニューに PSDToolKit が表示されることを確認

---

## Step 3: VOICEVOX の起動

1. VOICEVOX を起動する
2. 疎通確認:
   ```powershell
   Invoke-RestMethod http://localhost:50021/version
   # 出力例: "0.14.7"
   ```

---

## Step 4: 環境チェックスクリプト実行

```powershell
cd examples/07-advanced/aviutl_voicevox_pipeline
.\scripts\check_env.ps1
```

全ての項目が ✅ になれば準備完了です。

---

## Step 5: サンプル音声生成テスト

```powershell
# VOICEVOX を起動状態で実行
.\scripts\generate_voice.ps1

# output/voice/ に .wav ファイルが生成されます
```

---

## ディレクトリ構成

```
aviutl_voicevox_pipeline/
├── scripts/
│   ├── check_env.ps1        # 環境チェック
│   ├── generate_voice.ps1   # 音声一括生成
│   ├── generate_exo.ps1     # Exoファイル生成（予定）
│   └── run_all.ps1          # 全工程一括実行（予定）
├── scenarios/               # 台本テキストファイル
│   └── 01_intro.txt
├── output/
│   ├── voice/               # 生成された .wav ファイル
│   └── video/               # 出力動画
└── SETUP_GUIDE.md           # このファイル
```

---

## トラブルシューティング

### VOICEVOX に接続できない
- VOICEVOX アプリを起動してください（タスクトレイを確認）
- ファイアウォールで `50021` ポートが許可されているか確認

### PSDToolKit が見つからない
- `$AVIUTL_ROOT\plugins\` に `PSDToolKit.auf` を配置してください

### 音声生成でエラーが出る
- テキストが空でないか確認
- 日本語テキストが正しく UTF-8 で保存されているか確認
