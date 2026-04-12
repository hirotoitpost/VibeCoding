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

## Step 6: Phase 4 - AviUtl CUI エンコード実行

Phase 3 で生成された Exo ファイルを、AviUtl CUI を使用して動画にエンコードします：

```powershell
# 単独実行
.\scripts\aviutl_runner.ps1 -ExoFilePath "project.exo" -OutputFormat "mp4"

# MP4 形式で動画を生成
# 出力: output/video/output_YYYYMMDD_HHMMSS.mp4
```

**出力形式設定 (`output_config.json`)**:
```json
{
  "profiles": {
    "hd_mp4": {
      "name": "HD MP4（標準）",
      "bitrate": "5000k",
      "fps": 30,
      "resolution": "1280x720"
    },
    "full_hd_mp4": {
      "name": "Full HD MP4（高品質）",
      "bitrate": "10000k",
      "fps": 30,
      "resolution": "1920x1080"
    }
  }
}
```

---

## 統合実行: 全フェーズ一括実行

Phase 2 → 3 → 4 を自動実行する統合スクリプト：

```powershell
# 全フェーズ自動実行
.\run_all.ps1 -FastMode $true

# 各フェーズ実行後に一時停止
.\run_all.ps1 -FastMode $false

# 特定フェーズをスキップ
.\run_all.ps1 -SkipPhase2 $true    # Phase 2（音声）をスキップ
.\run_all.ps1 -SkipPhase3 $true    # Phase 3（Exo）をスキップ
.\run_all.ps1 -SkipPhase4 $true    # Phase 4（エンコード）をスキップ
```

**出力ディレクトリ構成**:
```
output/
├── voice/   # Phase 2 出力: WAV 音声ファイル
├── exo/     # Phase 3 出力: Exo ファイル
└── video/   # Phase 4 出力: MP4/AVI 動画ファイル
```

---

## ディレクトリ構成

```
aviutl_voicevox_pipeline/
├── scripts/
│   ├── check_env.ps1            # 環境チェック
│   ├── generate_voice.ps1       # Phase 2: 音声一括生成（VOICEVOX）
│   ├── generate_video_elements.ps1  # Phase 2.5: 映像要素生成（新規）
│   ├── generate_exo.ps1         # Phase 3: Exo ファイル生成（拡張版）
│   ├── aviutl_runner.ps1        # Phase 4: AviUtl CUI 動画エンコード
│   └── run_all.ps1              # 統合実行: Phase 2-2.5-3-4 一括実行（拡張版）
├── scenarios/                   # 台本テキストファイル
│   └── 01_intro.txt
├── output/
│   ├── voice/                   # Phase 2 出力: 生成された .wav ファイル
│   ├── exo/                     # Phase 3 出力: Exo ファイル
│   └── video/                   # Phase 4 出力: 動画ファイル
├── output_config.json           # エンコード出力形式設定
├── video_layout.json            # Phase 5.1 出力: レイアウト設定（新規）
├── project.exo                  # AviUtl プロジェクトファイル（生成）
└── SETUP_GUIDE.md               # このファイル
```

---

## パイプラインフロー

```
┌─────────────────────────────────────┐
│  入力: 台本テキスト (scenarios/)    │
└────────────────┬────────────────────┘
                 │
                 ▼
    ┌────────────────────────────┐
    │  Phase 2: VOICEVOX 音声生成 │
    │  - 複数スピーカー対応       │
    │  - 出力: voice/*.wav        │
    └────────────┬────────────────┘
                 │
                 ▼
    ┌────────────────────────────┐
    │ Phase 2.5: 映像要素生成 ✨ │
    │ - 背景レイアウト            │
    │ - 立ち絵配置                │
    │ - テロップ・字幕定義        │
    │ - 出力: video_layout.json   │
    └────────────┬────────────────┘
                 │
                 ▼
      ┌──────────────────────────┐
      │  Phase 3: Exo 生成       │
      │ - 音声 + 映像レイヤー    │
      │ - メタデータ → Exo XML   │
      │ - 出力: project.exo      │
      └────────┬─────────────────┘
               │
               ▼
      ┌──────────────────────────┐
      │  Phase 4: 動画エンコード  │
      │ - AviUtl CUI 実行        │
      │ - 出力: video/*.mp4      │
      └────────┬─────────────────┘
               │
               ▼
    ┌────────────────────────────┐
    │  最終出力: 完成した解説動画 │
    │  - 背景 + 立ち絵           │
    │  - 音声 + テロップ         │
    │  - テキスト字幕            │
    └────────────────────────────┘
```

---

## Step 7: Phase 5.1 - 映像要素生成（背景・立ち絵・テロップ）

Phase 5 では、背景、立ち絵、テロップ、字幕などの映像要素を追加します。

### パターン A: シンプル対話型（推奨）

```
テロップ（上部）
┌─────────────────────────────────────┐
│  つむぎ: 「これは解説です」         │
└─────────────────────────────────────┘

┌─────────────┐  ┌─────────────┐
│             │  │             │
│   立ち絵 1  │  │   立ち絵 2  │
│  (つむぎ)   │  │  (ずんだ)   │
│             │  │             │
└─────────────┘  └─────────────┘
   背景（薄紫グラデーション）

字幕（下部）
┌─────────────────────────────────────┐
│  ← つむぎ | ずんだもん →            │
└─────────────────────────────────────┘
```

### 映像要素生成スクリプト

```powershell
# Step 5.1: 映像要素の定義
.\scripts\generate_video_elements.ps1

# 出力: video_layout.json（レイアウト設定）
# - 背景: 薄紫グラデーション (#E8D9F0 → #F5E6F0)
# - 立ち絵: PSD ファイル (600×800px)
# - テロップ: 話者セリフ表示エリア
# - 字幕: 補足情報・キャラ名表示
```

### レイアウト設定（video_layout.json）

```json
{
  "layers": [
    {
      "layer": 0,
      "name": "背景",
      "type": "color_gradient",
      "color_top": "#E8D9F0",
      "color_bottom": "#F5E6F0"
    },
    {
      "layer": 1,
      "name": "立ち絵_左",
      "type": "psd_image",
      "psdFile": "PSD_CHARACTER_1",
      "x": 300,
      "y": 540,
      "width": 600,
      "height": 800
    },
    {
      "layer": 2,
      "name": "立ち絵_右",
      "type": "psd_image",
      "psdFile": "PSD_CHARACTER_2",
      "x": 1620,
      "y": 540,
      "width": 600,
      "height": 800
    },
    {
      "layer": 3,
      "name": "テロップ",
      "type": "text_box",
      "x": 960,
      "y": 140,
      "fontSize": 48
    },
    {
      "layer": 4,
      "name": "字幕",
      "type": "text_box",
      "x": 960,
      "y": 1000,
      "fontSize": 20
    }
  ]
}
```

### 統合実行（推奨）

```powershell
# 全フェーズ自動実行（Phase 2 → 2.5 → 2.6 → 3 → 4）
.\run_all.ps1 -FastMode $true

# または段階的実行
.\run_all.ps1 -FastMode $false
```

---

## Step 8: Phase 5.2 - 動的トランジション・テロップタイミング

Phase 5.2 では、立ち絵の動的な表示/非表示切り替え、トランジション効果、テロップ表示タイミングを追加します。

### 動的レイアウト生成スクリプト

```powershell
# Phase 5.1 レイアウト定義から、動的要素（トランジション・タイミング）を生成
.\scripts\generate_video_layout_dynamics.ps1

# 出力: video_layout_dynamics.json（トランジション・セグメント設定）
# - セグメント: 各話者の発話区間
# - 立ち絵表示/非表示タイミング
# - フェード効果（300ms）
# - テロップ自動タイミング計算
```

### 動的レイアウト設定（video_layout_dynamics.json）

```json
{
  "segments": [
    {
      "id": 1,
      "speaker_id": 8,
      "speaker_name": "つむぎ",
      "start_time": 0,
      "end_time": 5000,
      "visible_layers": [0, 1, 3, 4],
      "transitions": {
        "fade_in": 300,
        "fade_out": 300,
        "duration": 5000
      },
      "telop": {
        "text": "これは解説です",
        "display_time": 0,
        "duration": 5000
      }
    }
  ],
  "transitions": {
    "default_type": "fade",
    "default_duration": 300
  }
}
```

### パイプラインフロー（更新版）

```
Phase 2: 音声生成 (VOICEVOX)
    ↓
Phase 2.5: 映像レイアウト定義 (video_layout.json)
    ↓
Phase 2.6: ⭐ 動的トランジション定義 (video_layout_dynamics.json) [NEW]
    ↓
Phase 3: Exo ファイル生成 (レイアウト + トランジション統合)
    ↓
Phase 4: AviUtl CUI エンコード
    ↓
✅ 動画ファイル完成
```

### 実行方法

```powershell
# 単一スクリプト実行
.\scripts\generate_video_layout_dynamics.ps1

# または統合パイプライン実行
.\run_all.ps1 -FastMode $true

# 結果確認
Get-Content video_layout_dynamics.json | ConvertFrom-Json | Format-List

# Exo 生成実行時、動的トランジションが自動適用される
.\scripts\generate_exo.ps1
```

### ディレクトリ構成（Phase 5.2 後）

```
aviutl_voicevox_pipeline/
├── scripts/
│   ├── generate_voice.ps1
│   ├── generate_video_elements.ps1             # Phase 5.1
│   ├── generate_video_layout_dynamics.ps1      # Phase 5.2 [NEW]
│   ├── generate_exo.ps1
│   └── aviutl_runner.ps1
├── output/
│   ├── voice/
│   │   └── *.wav
│   ├── video/
│   ├── video_layout.json                       # Phase 5.1 出力
│   ├── video_layout_dynamics.json              # Phase 5.2 出力 [NEW]
│   └── project.exo
├── SETUP_GUIDE.md                              # このファイル
├── run_all.ps1
└── ...
```

---

## Step 9: Phase 5.3-5.4 - トランジション効果最適化と Exo 統合

Phase 5.3-5.4 では、複数のトランジション効果（フェード、ディゾルブ、スライド等）を定義し、セグメント間の効果をインテリジェントに選択・適用します。

### Phase 5.3: トランジション効果定義

トランジション効果設定ファイル（effect_config.json）:

```powershell
# Phase 5.3: エフェクト定義スクリプト実行
# effect_config.json に 5種類のトランジション効果を定義

# ファイル内容例（自動生成 or 既存）:
Get-Content effect_config.json | ConvertFrom-Json | Format-List
```

### effect_config.json 構造

```json
{
  "available_effects": [
    {
      "name": "fade",
      "duration_ms": 300,
      "easing": "linear",
      "aviutl_effect": "フェード",
      "use_case": "デフォルト、スムーズな切り替え"
    },
    {
      "name": "dissolve",
      "duration_ms": 500,
      "easing": "ease-in-out",
      "aviutl_effect": "ディゾルブ",
      "use_case": "スピーカー変化時、または類似内容の連続"
    },
    {
      "name": "slide_left",
      "duration_ms": 400,
      "easing": "ease-in-out",
      "aviutl_effect": "スライド (90°)",
      "use_case": "左スピーカー → 右スピーカーへの視点移動"
    },
    {
      "name": "slide_right",
      "duration_ms": 400,
      "easing": "ease-in-out",
      "aviutl_effect": "スライド (270°)",
      "use_case": "右スピーカー → 左スピーカーへの視点移動"
    },
    {
      "name": "fade_through_color",
      "duration_ms": 350,
      "easing": "linear",
      "aviutl_effect": "色を通してフェード",
      "use_case": "場面転換、トピック切り替え時"
    }
  ],
  "quality_profiles": {
    "fast": {
      "name": "高速処理モード",
      "available_effects": ["fade"],
      "use_case": "プレビュー、テスト用"
    },
    "normal": {
      "name": "バランス型（推奨）",
      "available_effects": ["fade", "dissolve"],
      "use_case": "実制作、標準品質"
    },
    "high": {
      "name": "フル機能モード",
      "available_effects": ["fade", "dissolve", "slide_left", "slide_right", "fade_through_color"],
      "use_case": "最高品質、全効果対応"
    }
  },
  "effect_selection_rules": {
    "same_speaker": "fade",
    "speaker_change_left_to_right": "slide_left",
    "speaker_change_right_to_left": "slide_right",
    "different_topic": "dissolve",
    "default": "fade"
  }
}
```

### Phase 5.4: Exo ファイル生成工程（トランジション統合）

#### 動作フロー

```
video_layout_dynamics.json (Phase 5.2)
  ├─ segment[1]: speaker_1
  ├─ segment[2]: speaker_2
  ├─ selected_effect: { name: "slide_left", duration_ms: 400, easing: "ease-in-out" }
  │   ↓
generate_exo.ps1 (Phase 5.4 拡張)
  ├─ effect_config.json 読み込み
  ├─ selected_effect 抽出
  ├─ AviUtl形式に変換
  │   └─ "slide_left" → <transition type="スライド" ... />
  │
  └─ project.exo に<transition>タグ挿入
        ↓
AviUtl CUI エンコード
        ↓
✅ トランジション効果が適用された動画生成
```

#### generate_exo.ps1 実行（Phase 5.4 拡張版）

```powershell
# Phase 5.4: Exo 生成（自動的にトランジション効果を統合）
.\scripts\generate_exo.ps1

# 詳細オプション
.\scripts\generate_exo.ps1 `
  -OutputPath "./output/project.exo" `
  -LayoutConfigPath "./video_layout.json" `
  -DynamicsLayoutPath "./video_layout_dynamics.json" `
  -EffectConfigPath "../effect_config.json"

# 実行結果
# - Phase 2.8: effect_config.json 読込確認
# - セグメント間トランジション自動生成
# - <transition> XML タグ挿入
# - project.exo に最終的なトランジション情報が反映される
```

#### トランジション効果の自動選択ロジック

```
セグメント間の遷移を検出:
  ├─ 同じスピーカー?
  │   └─ YES → fade（300ms、スムーズ）
  │
  ├─ スピーカー変化?（speaker_change）
  │   ├─ 左→右?
  │   │   └─ YES → slide_left（400ms、視点移動）
  │   │
  │   ├─ 右→左?
  │   │   └─ YES → slide_right（400ms、視点移動）
  │   │
  │   └─ デフォルト → dissolve（500ms）
  │
  └─ その他 → fade（デフォルト）

✨ 結果: セグメント毎に最適なトランジション自動配置
```

#### 品質プロファイルの選択（推奨: normal）

```powershell
# 法1: generate_exo.ps1内から制御
# ファイル内で QualityProfile パラメーターを指定
#   -QualityProfile "normal"  # fast | normal | high

# 法2: 環境変数設定
$env:QUALITY_PROFILE = "normal"

# 法3: run_all.ps1 パラメーター（今後の拡張）
# .\run_all.ps1 -QualityProfile "normal"

# QualityProfile 効果
# - fast  : フェードのみ（軽量、プレビュー向け）
# - normal: フェード + ディゾルブ（バランス型、推奨）✅
# - high  : 全効果（高品質、処理時間増加）
```

### 統合実行（Phase 2-2.5-2.6-2.7-2.8 → Phase 3-4）

```powershell
# 最も推奨: 全フェーズ自動実行
# (Phase 2 → 2.5 → 2.6 → 2.7チェック → 2.8読込 → Phase 3 → 4)
.\run_all.ps1 -FastMode $true

# 実行出力例
# ==============================================
#  VibeCoding 動画生成パイプライン 統合実行
# ==============================================
# [ Phase 2 ] 音声生成（VOICEVOX）
# [ Phase 2.5 ] 映像要素生成（レイアウト・背景・立ち絵）
# [ Phase 2.6 ] 動的レイアウト生成（トランジション・タイミング）
# [ Phase 2.7 ] トランジション効果統合チェック
# [ Phase 3 ] Exo ファイル生成（Phase 5.4: トランジション効果統合）✨
# [ Phase 4 ] AviUtl CUI 動画エンコード
# ==============================================
```

### トランジション効果の確認方法

```powershell
# 1. video_layout_dynamics.json で selected_effect を確認
Get-Content "video_layout_dynamics.json" | ConvertFrom-Json | ForEach-Object {
    $_.segments | ForEach-Object {
        Write-Host "Segment $($_.id): $($_.speaker_name) - Effect: $($_.selected_effect.name)"
    }
}

# 2. project.exo で<transition>タグを確認
Get-Content "project.exo" | Select-String "<transition" -Context 1,1

# 3. AviUtl で project.exo を開いて、タイムライン上のトランジション効果を視認
```

### カスタマイズ：effect_config.json 修正

効果の duration_ms や easing を変更する場合:

```json
{
  "available_effects": [
    {
      "name": "dissolve",
      "duration_ms": 600,      // デフォルト 500ms → 600ms に変更
      "easing": "ease-out"     // ease-in-out → ease-out に変更
    }
  ]
}
```

変更後、次回実行時に新しい設定が反映されます:

```powershell
.\scripts\generate_exo.ps1

# または全フェーズ実行
.\run_all.ps1 -FastMode $true
```

### よくある質問（FAQトランジション）

#### Q: トランジション効果が反映されていない
- A: 以下を確認してください
  1. effect_config.json が存在するか（ルートディレクトリ）
  2. video_layout_dynamics.json に selected_effect フィールドがあるか
  3. ✅ generate_exo.ps1 の出力メッセージで「トランジション情報追加中」が表示されたか

#### Q: スライド効果の方向を逆にしたい
- A: effect_config.json の effect_selection_rules を修正
  ```json
  {
    "speaker_change_left_to_right": "slide_right",  // 左右反転
    "speaker_change_right_to_left": "slide_left"
  }
  ```

#### Q: 特定のセグメント間だけトランジション効果を変更したい
- A: video_layout_dynamics.json の該当セグメントの selected_effect を直接修正
  ```json
  {
    "segments": [
      {
        "id": 5,
        "selected_effect": {
          "name": "fade_through_color",  // カスタム効果
          "duration_ms": 350
        }
      }
    ]
  }
  ```

#### Q: FastMode と Normal Mode の違いは?
- A: run_all.ps1 の実行パターン
  - FastMode true: 各フェーズ自動実行、一時停止なし
  - FastMode false: フェーズ毎に一時停止、確認後 Enter キーで続行

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
