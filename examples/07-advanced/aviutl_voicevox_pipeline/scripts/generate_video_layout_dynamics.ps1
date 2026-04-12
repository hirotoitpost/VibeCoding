# VibeCoding 動的映像レイアウト生成スクリプト (ID 023 Phase 5.2)
# 役割: 立ち絵トランジション、テロップ動的表示タイミングを定義し、JSON で出力

<#
.SYNOPSIS
    動的映像レイアウト要素（トランジション・タイミング）を定義・生成します

.DESCRIPTION
    Phase 5.1 の video_layout.json を読み込み、以下の動的要素を追加生成:
    - セグメント定義（各話者の発話区間）
    - 立ち絵の表示/非表示タイミング
    - フェードイン/アウト効果
    - テロップ表示時間の動的計算

.PARAMETER OutputPath
    出力 JSON ファイルのパス（デフォルト: video_layout_dynamics.json）

.PARAMETER LayoutConfigPath
    入力 video_layout.json のパス（デフォルト: video_layout.json）

.PARAMETER SegmentInfoFile
    セグメント情報ファイルのパス（デフォルト: output/segments.json）

.EXAMPLE
    .\generate_video_layout_dynamics.ps1
    .\generate_video_layout_dynamics.ps1 -OutputPath "dynamics.json"

.NOTES
    出力 JSON は後の generate_exo.ps1 Step 2.7 で使用されます
#>

param(
    [string]$OutputPath = "video_layout_dynamics.json",
    [string]$LayoutConfigPath = "video_layout.json",
    [string]$SegmentInfoFile = "output/segments.json"
)

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host " 動的映像レイアウト生成 (ID 023 Phase 5.2)" -ForegroundColor Cyan
Write-Host " 立ち絵トランジション・テロップタイミング" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# ========================================
# ステップ 1: 入力ファイル確認
# ========================================

Write-Host "[ 1/5 ] 入力ファイル確認..." -ForegroundColor Yellow

if (-not (Test-Path $LayoutConfigPath)) {
    Write-Host "  ❌ Layout config が見つかりません: $LayoutConfigPath" -ForegroundColor Red
    Write-Host "     先に generate_video_elements.ps1 を実行してください" -ForegroundColor Gray
    exit 1
}

Write-Host "  ✅ Layout config: $LayoutConfigPath" -ForegroundColor Green

# video_layout.json 読み込み
$layoutConfig = Get-Content $LayoutConfigPath -Raw | ConvertFrom-Json
Write-Host "  ✅ レイアウト定義 読み込み完了: $($layoutConfig.layers.Count) layer" -ForegroundColor Green
Write-Host ""

# ========================================
# ステップ 2: セグメント情報（話者別タイミング）の抽出
# ========================================

Write-Host "[ 2/5 ] セグメント情報抽出..." -ForegroundColor Yellow

$voiceDir = "output/voice"
$wavFiles = @(Get-ChildItem -Path $voiceDir -Filter "*.wav" -ErrorAction SilentlyContinue | Sort-Object Name)

if ($wavFiles.Count -eq 0) {
    Write-Host "  ⚠️  voice ディレクトリに .wav ファイルがありません" -ForegroundColor Yellow
    Write-Host "     デモデータで生成を続行します..." -ForegroundColor Gray
}

Write-Host "  ✅ 検出ファイル数: $($wavFiles.Count)" -ForegroundColor Green

# セグメント情報を生成
$segments = @()
$currentTime = 0

foreach ($wav in $wavFiles) {
    # WAV ファイルのメタデータを取得
    try {
        $fileStream = [System.IO.File]::OpenRead($wav.FullName)
        $reader = New-Object System.IO.BinaryReader($fileStream)
        
        # WAV ヘッダー解析
        $fileStream.Seek(24, [System.IO.SeekOrigin]::Begin) | Out-Null
        $sampleRate = $reader.ReadInt32()
        
        $fileStream.Seek(40, [System.IO.SeekOrigin]::Begin) | Out-Null
        $dataSize = $reader.ReadInt32()
        
        $reader.Close()
        $fileStream.Close()
        
        # 音声長を計算（ミリ秒）
        $bytesPerSample = 2  # 16-bit
        $duration = [System.Math]::Round(($dataSize / $bytesPerSample / $sampleRate) * 1000)
        
        # ファイル名からスピーカーID を抽出（例: 001_speaker_8_...wav）
        $fileName = $wav.BaseName
        $parts = $fileName -split "_"
        
        # Speaker ID を抽出（環境変数から推定）
        $speakerId = if ($parts.Count -ge 3 -and [int]::TryParse($parts[1], [ref]0)) {
            $parts[2]
        } else {
            if ($segments.Count % 2 -eq 0) { $env:SPEAKER_1_ID } else { $env:SPEAKER_2_ID }
        }
        
        $speakerName = if ($speakerId -eq $env:SPEAKER_1_ID) {
            "つむぎ"
        } elseif ($speakerId -eq $env:SPEAKER_2_ID) {
            "ずんだ"
        } else {
            "Speaker_$speakerId"
        }
        
        $segment = @{
            id             = $segments.Count + 1
            speaker_id     = $speakerId
            speaker_name   = $speakerName
            start_time     = $currentTime
            end_time       = $currentTime + $duration
            duration       = $duration
            visible_layers = @(
                0
                if ($speakerId -eq $env:SPEAKER_1_ID) { 1 } else { 2 }
                3
                4
            )
            transitions    = @{
                fade_in     = 300
                fade_out    = 300
                duration    = $duration
            }
            telop          = @{
                text         = "${speakerName}: ...（テロップ自動生成予定）"
                display_time = $currentTime
                duration     = $duration
                x            = 960
                y            = 120
                width        = 1800
                height       = 120
            }
        }
        
        $segments += $segment
        $currentTime += $duration
        
        Write-Host "  ✅ Segment #$($segment.id): Speaker $speakerId ($speakerName) - $duration ms" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠️  $($wav.Name) 処理エラー: $_" -ForegroundColor Yellow
    }
}

Write-Host "  ✅ 総セグメント数: $($segments.Count)" -ForegroundColor Green
Write-Host "  ✅ 合計時間: $currentTime ms ($([System.Math]::Round($currentTime / 1000, 2))秒)" -ForegroundColor Green
Write-Host ""

# ========================================
# ステップ 3: トランジション定義
# ========================================

Write-Host "[ 3/5 ] トランジション定義..." -ForegroundColor Yellow

$transitions = @{
    available_types = @(
        @{ name = "fade"; duration_ms = 300; description = "フェード効果" },
        @{ name = "dissolve"; duration_ms = 500; description = "ディゾルブ効果" },
        @{ name = "slide_left"; duration_ms = 400; description = "左スライド" },
        @{ name = "slide_right"; duration_ms = 400; description = "右スライド" }
    )
    default_type   = "fade"
    default_duration = 300
}

Write-Host "  ✅ トランジションタイプ設定: $($transitions.available_types.Count) 種類" -ForegroundColor Green

foreach ($type in $transitions.available_types) {
    Write-Host "     - $($type.name): $($type.duration_ms)ms ($($type.description))" -ForegroundColor Cyan
}

Write-Host ""

# ========================================
# ステップ 4: 動的レイアウト JSON 生成
# ========================================

Write-Host "[ 4/5 ] 動的レイアウト JSON 生成..." -ForegroundColor Yellow

$dynamicLayout = @{
    metadata = @{
        version        = "1.0"
        phase          = "5.2"
        created        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        source_layout  = $LayoutConfigPath
        total_duration = $currentTime
        segment_count  = $segments.Count
    }
    
    segments = $segments
    
    transitions = $transitions
    
    timing_rules = @{
        fade_in_duration  = 300
        fade_out_duration = 300
        min_display_time  = 500
        max_display_time  = 5000
    }
    
    layer_visibility = @{
        layer_0 = @{
            name           = "背景"
            always_visible = $true
            z_order        = 0
        }
        layer_1 = @{
            name      = "立ち絵_左 (Speaker 1)"
            z_order   = 10
            fade_time = 300
        }
        layer_2 = @{
            name      = "立ち絵_右 (Speaker 2)"
            z_order   = 10
            fade_time = 300
        }
        layer_3 = @{
            name           = "テロップ"
            always_visible = $true
            z_order        = 20
        }
        layer_4 = @{
            name           = "字幕"
            always_visible = $true
            z_order        = 15
        }
    }
}

Write-Host "  ✅ Metadata: Phase $($dynamicLayout.metadata.phase)" -ForegroundColor Green
Write-Host "  ✅ Segments: $($dynamicLayout.segments.Count)個定義" -ForegroundColor Green
Write-Host "  ✅ Total Duration: $([System.Math]::Round($dynamicLayout.metadata.total_duration / 1000, 2))秒" -ForegroundColor Green

Write-Host ""

# ========================================
# ステップ 5: JSON 出力＆ファイル保存
# ========================================

Write-Host "[ 5/5 ] JSON ファイル出力..." -ForegroundColor Yellow

$jsonOutput = $dynamicLayout | ConvertTo-Json -Depth 10

# ファイル保存
$jsonOutput | Out-File -FilePath $OutputPath -Encoding UTF8

if (Test-Path $OutputPath) {
    $fileSize = (Get-Item $OutputPath).Length
    Write-Host "  ✅ ファイル保存完了: $OutputPath" -ForegroundColor Green
    Write-Host "  ✅ ファイルサイズ: $([System.Math]::Round($fileSize / 1KB, 2)) KB" -ForegroundColor Green
}
else {
    Write-Host "  ❌ ファイル保存に失敗しました" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host " ✅ Phase 5.2 動的レイアウト生成完了" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "次のステップ:" -ForegroundColor Yellow
Write-Host "  1. generate_exo.ps1 を実行：$OutputPath を読み込んでトランジション適用" -ForegroundColor Cyan
Write-Host "  2. AviUtl でエンコード（aviutl_runner.ps1）" -ForegroundColor Cyan
Write-Host ""
Write-Host "出力ファイル: $OutputPath" -ForegroundColor Green
