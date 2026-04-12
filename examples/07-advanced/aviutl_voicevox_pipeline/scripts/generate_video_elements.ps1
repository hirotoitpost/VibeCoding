# VibeCoding 映像要素生成スクリプト (ID 022 Phase 5.1)
# 役割: 背景、立ち絵、テロップ、字幕などの映像レイアウトを定義し、JSON で出力

<#
.SYNOPSIS
    映像レイアウト要素を定義・生成します

.DESCRIPTION
    パターン A（シンプル対話型）で以下のレイヤー構成を生成:
    - Layer 0: 背景（薄紫グラデーション）
    - Layer 1: 立ち絵 1（左側）
    - Layer 2: 立ち絵 2（右側）
    - Layer 3: テロップ（上部）
    - Layer 4: 字幕（下部）

.PARAMETER OutputPath
    出力 JSON ファイルのパス（デフォルト: video_layout.json）

.PARAMETER Pattern
    レイアウトパターン（デフォルト: A）
    A: シンプル対話型（推奨）
    B: スライド統合型
    C: フォーカス切り替え型

.EXAMPLE
    .\generate_video_elements.ps1
    .\generate_video_elements.ps1 -Pattern "A" -OutputPath "layout_config.json"

.NOTES
    出力 JSON は後の generate_exo.ps1 で使用されます
#>

param(
    [string]$OutputPath = "video_layout.json",
    [ValidateSet("A", "B", "C")]
    [string]$Pattern = "A"
)

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host " 映像要素生成 (ID 022 Phase 5.1)" -ForegroundColor Cyan
Write-Host " パターン: $Pattern （シンプル対話型）" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# ========================================
# 画面基本設定
# ========================================

$screenConfig = @{
    width       = 1920
    height      = 1080
    fps         = 30
    aspectRatio = "16:9"
}

Write-Host "[ 1/4 ] 画面基本設定..." -ForegroundColor Yellow
Write-Host "  ✅ 解像度: $($screenConfig.width)x$($screenConfig.height)" -ForegroundColor Green
Write-Host "  ✅ フレームレート: $($screenConfig.fps) fps" -ForegroundColor Green
Write-Host ""

# ========================================
# レイアウト定義: パターン A
# ========================================

Write-Host "[ 2/4 ] レイアウト定義 (パターン $Pattern)..." -ForegroundColor Yellow

$layers = @()

# ===== Layer 0: 背景 =====
$backgroundLayer = @{
    layer        = 0
    name         = "背景"
    type         = "color_gradient"
    x            = 960
    y            = 540
    width        = 1920
    height       = 1080
    visible      = $true
    locked       = $true
    alpha        = 255
    color_top    = "#E8D9F0"              # 薄紫（上）
    color_bottom = "#F5E6F0"            # より薄い紫（下）
    description  = "グラデーション背景（将来: スライド背景対応予定）"
}
$layers += $backgroundLayer
Write-Host "  ✅ Layer 0: 背景（薄紫グラデーション）" -ForegroundColor Green

# ===== Layer 1: 立ち絵 1 (左) =====
$characterLeft = @{
    layer           = 1
    name            = "立ち絵_左"
    type            = "psd_image"
    psdFile         = $env:PSD_CHARACTER_1
    x               = 300                            # 左配置
    y               = 540                            # 中央縦
    width           = 600
    height          = 800
    visible         = $true
    locked          = $false
    alpha           = 255
    scale_x         = 1.0
    scale_y         = 1.0
    rotate          = 0
    speaker         = "SPEAKER_1"
    characterName   = "つむぎ"
    characterId     = $env:SPEAKER_1_ID
    description     = "進行役の立ち絵"
    visibility_sync = @{
        show_when = "speaker_1_active"
        fade_in   = 0.3
        fade_out  = 0.3
    }
}
$layers += $characterLeft
Write-Host "  ✅ Layer 1: 立ち絵 1 (左側, 600x800px) - つむぎ" -ForegroundColor Green

# ===== Layer 2: 立ち絵 2 (右) =====
$characterRight = @{
    layer           = 2
    name            = "立ち絵_右"
    type            = "psd_image"
    psdFile         = $env:PSD_CHARACTER_2
    x               = 1620                           # 右配置（1920 - 300）
    y               = 540                            # 中央縦
    width           = 600
    height          = 800
    visible         = $true
    locked          = $false
    alpha           = 255
    scale_x         = 1.0
    scale_y         = 1.0
    rotate          = 0
    speaker         = "SPEAKER_2"
    characterName   = "ずんだもん"
    characterId     = $env:SPEAKER_2_ID
    description     = "相槌役の立ち絵"
    visibility_sync = @{
        show_when = "speaker_2_active"
        fade_in   = 0.3
        fade_out  = 0.3
    }
}
$layers += $characterRight
Write-Host "  ✅ Layer 2: 立ち絵 2 (右側, 600x800px) - ずんだもん" -ForegroundColor Green

# ===== Layer 3: テロップ (上部) =====
$telop = @{
    layer           = 3
    name            = "テロップ"
    type            = "text_box"
    x               = 960                            # 中央
    y               = 140                            # 上部
    width           = 1800
    height          = 120
    visible         = $true
    locked          = $false
    backgroundColor = "rgba(0,0,0,0.7)"  # 半透明黒背景
    borderColor     = "#E8D9F0"             # 薄紫枠
    borderWidth     = 2
    text_config     = @{
        fontSize          = 48
        fontFamily        = "メイリオ"
        fontColor         = "#FFFFFF"           # 白テキスト
        fontBold          = $true
        alignment         = "center"
        verticalAlignment = "middle"
        lineHeight        = 1.4
        lineLimit         = 3
    }
    padding         = @{ top = 10; bottom = 10; left = 20; right = 20 }
    description     = "話者名＋セリフ表示"
    content_pattern = "{SPEAKER}: {TEXT}"
}
$layers += $telop
Write-Host "  ✅ Layer 3: テロップ (上部, 1800x120px)" -ForegroundColor Green

# ===== Layer 4: 字幕 (下部) =====
$subtitle = @{
    layer           = 4
    name            = "字幕"
    type            = "text_box"
    x               = 960                            # 中央
    y               = 1000                           # 下部
    width           = 1200
    height          = 60
    visible         = $true
    locked          = $false
    backgroundColor = "rgba(0,0,0,0.5)"  # 半透明黒背景
    borderColor     = "#F0F0F0"             # 淡色枠
    borderWidth     = 1
    text_config     = @{
        fontSize          = 20
        fontFamily        = "メイリオ"
        fontColor         = "#CCCCCC"           # グレーテキスト
        fontBold          = $false
        alignment         = "center"
        verticalAlignment = "middle"
        lineHeight        = 1.3
    }
    padding         = @{ top = 5; bottom = 5; left = 15; right = 15 }
    description     = "補足情報・キャラ名表示"
    content_pattern = "← {LEFT_CHARACTER} | {RIGHT_CHARACTER} →"
}
$layers += $subtitle
Write-Host "  ✅ Layer 4: 字幕 (下部, 1200x60px)" -ForegroundColor Green

Write-Host ""

# ========================================
# 色設定・デザイン設定
# ========================================

Write-Host "[ 3/4 ] 色・デザイン設定..." -ForegroundColor Yellow

$designConfig = @{
    colorScheme = @{
        background_top    = "#E8D9F0"
        background_bottom = "#F5E6F0"
        accent_primary    = "#6B4C8A"      # 紫（つむぎ）
        accent_secondary  = "#5BA3A3"    # 青緑（ずんだもん）
        text_primary      = "#FFFFFF"
        text_secondary    = "#CCCCCC"
        border_color      = "#E0D0E8"
    }
    typography  = @{
        fontFamily      = "メイリオ"
        fontSize_large  = 48
        fontSize_normal = 28
        fontSize_small  = 20
        fontWeight      = "bold"
    }
    animation   = @{
        transition_duration = 0.3
        fade_in_duration    = 0.5
        fade_out_duration   = 0.3
    }
}

Write-Host "  ✅ 背景: 薄紫グラデーション (#E8D9F0 → #F5E6F0)" -ForegroundColor Green
Write-Host "  ✅ アクセント: 紫 (つむぎ), 青緑 (ずんだもん)" -ForegroundColor Green
Write-Host "  ✅ フォント: メイリオ, 日本語対応" -ForegroundColor Green
Write-Host "  ✅ トランジション: 0.3秒フェード" -ForegroundColor Green
Write-Host ""

# ========================================
# レイアウト構成情報
# ========================================

Write-Host "[ 4/4 ] レイアウト構成情報..." -ForegroundColor Yellow

$layoutInfo = @{
    projectName  = "VibeCoding 解説動画"
    pattern      = $Pattern
    description  = "パターン A: シンプル対話型（2人対話レイアウト）"
    screenConfig = $screenConfig
    designConfig = $designConfig
    layers       = $layers
    totalLayers  = $layers.Count
    createdAt    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    notes        = @(
        "将来: スライド/埋込み動画を背景に配置可能"
        "Layer 構成は AviUtl Exo ファイルに反映されます"
        "各レイヤーは独立して追加/削除/編集可能です"
    )
}

Write-Host "  📊 総レイヤー数: $($layoutInfo.totalLayers)" -ForegroundColor Cyan
Write-Host "     - 背景: 1"
Write-Host "     - 立ち絵: 2"
Write-Host "     - テキスト: 2"
Write-Host "  📐 レイアウトパターン: $($layoutInfo.pattern) - $($layoutInfo.description)" -ForegroundColor Cyan
Write-Host ""

# ========================================
# JSON 出力
# ========================================

Write-Host "💾 JSON ファイル生成中..." -ForegroundColor Yellow

# 出力ディレクトリ処理（相対パスでも絶対パスでも対応）
$outputDir = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($outputDir)) {
    # 親ディレクトリが指定されている場合のみ作成
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
}

$layoutInfo | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8

if (Test-Path $OutputPath) {
    $fileSize = (Get-Item $OutputPath).Length
    Write-Host "  ✅ ファイル生成完了: $OutputPath" -ForegroundColor Green
    Write-Host "     ファイルサイズ: $fileSize bytes" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host " 映像要素生成完了！" -ForegroundColor Green
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "次のステップ:" -ForegroundColor Yellow
    Write-Host "  1. generate_exo.ps1 を実行（この JSON を使用）" -ForegroundColor Gray
    Write-Host "  2. project.exo にレイアウト反映" -ForegroundColor Gray
    Write-Host "  3. AviUtl CUI でエンコード実行" -ForegroundColor Gray
    Write-Host ""
    exit 0
}
else {
    Write-Host "  ❌ ファイル生成失敗" -ForegroundColor Red
    exit 1
}
