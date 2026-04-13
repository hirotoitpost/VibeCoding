#Requires -Version 5.1
<#
.SYNOPSIS
    AviUtl Exo ファイル生成スクリプト（Session 27 Phase 5.5.2 - INI形式）

.DESCRIPTION
    voice/ の .wav をタイムラインに配置し INI 形式 Exo を生成

.EXAMPLE
    .\generate_exo.ps1
#>

param(
    [string]$OutputPath = "./project.exo",
    [string]$LayoutConfigPath = "./video_layout.json"
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptRoot
$voiceDir = Join-Path $projectRoot "output\voice"

Write-Host "AviUtl INI形式 Exo 生成`n" -ForegroundColor Cyan

# ステップ 1: INI ファイル確認
Write-Host "[ 1/3 ] WAV ファイル確認..." -ForegroundColor Yellow

if (-not (Test-Path $voiceDir)) {
    Write-Host "  ❌ voice ディレクトリ: $voiceDir" -ForegroundColor Red
    exit 1
}

$wavFiles = @(Get-ChildItem -Path $voiceDir -Filter "*.wav" -ErrorAction SilentlyContinue | Sort-Object Name)

if ($wavFiles.Count -eq 0) {
    Write-Host "  ⚠️  WAV ファイルなし" -ForegroundColor Yellow
    exit 1
}

Write-Host "  ✅ $($wavFiles.Count) ファイル" -ForegroundColor Green

# ステップ 2: メタデータ取得
Write-Host "`n[ 2/3 ] メタデータ取得..." -ForegroundColor Yellow

$audioData = @()
$totalDuration = 0

foreach ($wav in $wavFiles) {
    try {
        $fs = [System.IO.File]::OpenRead($wav.FullName)
        $br = New-Object System.IO.BinaryReader($fs)
        
        $br.ReadBytes(4)
        $riff_size = $br.ReadInt32()
        $br.ReadBytes(4)
        $br.ReadBytes(4)
        $br.ReadInt32()
        $br.ReadInt16()
        $br.ReadInt16()
        $br.ReadInt32()
        $byte_rate = $br.ReadInt32()
        $br.ReadInt16()
        $br.ReadInt16()
        
        $duration = [double]($riff_size - 36) / $byte_rate
        
        $br.Close()
        $fs.Close()
        
        $audioData += @{
            File          = $wav.Name
            FullPath      = $wav.FullName
            Duration      = $duration
            TimelineStart = $totalDuration
        }
        
        $totalDuration += $duration
        Write-Host "  ✅ $($wav.Name): $([math]::Round($duration, 2))s" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠️  $($wav.Name): エラー" -ForegroundColor Yellow
    }
}

Write-Host "  📊 合計: $([math]::Round($totalDuration, 2))s" -ForegroundColor Cyan

# ステップ 3: INI 生成
Write-Host "`n[ 3/3 ] INI 生成..." -ForegroundColor Yellow

$width = 1920
$height = 1080
$videoRate = 30
$audioRate = 44100
$totalFrames = [int]($totalDuration * $videoRate)

$iniLines = @()

# [exedit] ヘッダー
$iniLines += "[exedit]"
$iniLines += "width=$width"
$iniLines += "height=$height"
$iniLines += "rate=$videoRate"
$iniLines += "scale=1"
$iniLines += "length=$totalFrames"
$iniLines += "audio_rate=$audioRate"
$iniLines += "audio_ch=2"
$iniLines += ""

# 音声レイヤー
foreach ($audio in $audioData) {
    $startFr = [int]($audio.TimelineStart * $videoRate)
    $endFr = [int](($audio.TimelineStart + $audio.Duration) * $videoRate)
    
    $iniLines += "[0]"
    $iniLines += "start=$startFr"
    $iniLines += "end=$endFr"
    $iniLines += "layer=0"
    $iniLines += ""
    
    $iniLines += "[0.0]"
    $iniLines += "_name=$($audio.File)"
    $iniLines += "type=0"
    $iniLines += "filter=0"
    $audioEsc = $audio.FullPath -replace '\\', '\\'
    $iniLines += "file=`"$audioEsc`""
    $iniLines += ""
    
    Write-Host "  ✅ 音声 layer" -ForegroundColor Green
}

# ファイル出力
$outDir = Split-Path -Parent $OutputPath
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$iniContent = $iniLines -join [System.Environment]::NewLine
$utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($iniContent)
$iniBytes = [System.Text.Encoding]::Convert([System.Text.Encoding]::UTF8, [System.Text.Encoding]::GetEncoding("shift_jis"), $utf8Bytes)
[System.IO.File]::WriteAllBytes($OutputPath, $iniBytes)

if (Test-Path $OutputPath) {
    $fileSize = (Get-Item $OutputPath).Length
    Write-Host "  ✅ 完了: $fileSize bytes" -ForegroundColor Green
    Write-Host "  📄 $OutputPath`n" -ForegroundColor Cyan
}
else {
    Write-Host "  ❌ 失敗`n" -ForegroundColor Red
    exit 1
}
#Requires -Version 5.1
<#
.SYNOPSIS
    AviUtl Exo ファイル生成スクリプト（ID 027 Phase 5.5.2 - INI形式実装）

.DESCRIPTION
    voice/ ディレクトリの .wav ファイルをタイムラインに配置し、
    AviUtl 互換の INI 形式で Exo ファイルを生成する。

.PARAMETER OutputPath
    生成する Exo ファイルの出力パス（デフォルト: ./project.exo）

.PARAMETER LayoutConfigPath
    レイアウト設定 JSON ファイルのパス（デフォルト: ./video_layout.json）
#>

param(
    [string]$OutputPath = "./project.exo",
    [string]$LayoutConfigPath = "./video_layout.json"
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptRoot
$voiceDir = Join-Path $projectRoot "output\voice"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " AviUtl INI形式 Exo ファイル生成" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: 入力ファイル確認
Write-Host "[ 1/4 ] 入力ファイル確認..." -ForegroundColor Yellow

if (-not (Test-Path $voiceDir)) {
    Write-Host "  ❌ voice ディレクトリ: $voiceDir" -ForegroundColor Red
    exit 1
}

$wavFiles = @(Get-ChildItem -Path $voiceDir -Filter "*.wav" -ErrorAction SilentlyContinue | Sort-Object Name)

if ($wavFiles.Count -eq 0) {
    Write-Host "  ⚠️  WAV ファイル無し" -ForegroundColor Yellow
    exit 1
}

Write-Host "  ✅ WAV: $($wavFiles.Count) 個" -ForegroundColor Green

# Step 2: WAV メタデータ取得
Write-Host "`n[ 2/4 ] メタデータ取得..." -ForegroundColor Yellow

$audioData = @()
$totalDuration = 0

foreach ($wav in $wavFiles) {
    try {
        $fs = [System.IO.File]::OpenRead($wav.FullName)
        $br = New-Object System.IO.BinaryReader($fs)
        
        $br.ReadBytes(4)    # RIFF
        $riff_size = $br.ReadInt32()
        $br.ReadBytes(4)    # WAVE
        $br.ReadBytes(4)    # fmt
        $br.ReadInt32()     # fmt size
        $br.ReadInt16()     # format
        $br.ReadInt16()     # channels
        $br.ReadInt32()     # sample_rate
        $byte_rate = $br.ReadInt32()
        $br.ReadInt16()     # block align
        $br.ReadInt16()     # bits per sample
        
        $data_size = $riff_size - 36
        $duration = [double]$data_size / $byte_rate
        
        $br.Close()
        $fs.Close()
        
        $audioData += @{
            File          = $wav.Name
            FullPath      = $wav.FullName
            Duration      = $duration
            TimelineStart = $totalDuration
        }
        
        $totalDuration += $duration
        Write-Host "  ✅ $($wav.Name): $([math]::Round($duration, 2))s" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠️  エラー: $($wav.Name)" -ForegroundColor Yellow
    }
}

Write-Host "  📊 合計: $([math]::Round($totalDuration, 2))s" -ForegroundColor Cyan

# Step 2.5: レイアウト JSON 読込
Write-Host "`n[ 2.5/4 ] レイアウト読込..." -ForegroundColor Yellow

if (-not [System.IO.Path]::IsPathRooted($LayoutConfigPath)) {
    $LayoutConfigPath = Join-Path $projectRoot $LayoutConfigPath
}

$layoutLayers = @()
if (Test-Path $LayoutConfigPath) {
    try {
        $layoutConfig = Get-Content $LayoutConfigPath | ConvertFrom-Json
        $layoutLayers = $layoutConfig.layers
        Write-Host "  ✅ $($layoutLayers.Count) レイヤー" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠️  読込失敗" -ForegroundColor Yellow
    }
}

# Step 3: INI 生成
Write-Host "`n[ 3/4 ] INI生成..." -ForegroundColor Yellow

$width = 1920
$height = 1080
$videoRate = 30
$audioRate = 44100
$totalFrames = [int]($totalDuration * $videoRate)

$iniLines = @()

# [exedit] ヘッダー
$iniLines += "[exedit]"
$iniLines += "width=$width"
$iniLines += "height=$height"
$iniLines += "rate=$videoRate"
$iniLines += "scale=1"
$iniLines += "length=$totalFrames"
$iniLines += "audio_rate=$audioRate"
$iniLines += "audio_ch=2"
$iniLines += ""

# 映像レイヤー
Write-Host "  📊 映像レイヤー..." -ForegroundColor Cyan
$layerIdx = 0
foreach ($layer in $layoutLayers) {
    $iniLines += "[$layerIdx]"
    $iniLines += "start=0"
    $iniLines += "end=$totalFrames"
    $iniLines += "layer=$layerIdx"
    $iniLines += ""
    
    if ($layer.type -eq "psd_image" -and -not [string]::IsNullOrEmpty($layer.psdFile)) {
        $psdPath = $layer.psdFile
        
        if (-not [System.IO.Path]::IsPathRooted($psdPath)) {
            $psdPath = $psdPath -replace '/', '\'
            $psdPath = "$projectRoot\$psdPath"
        }
        
        while ($psdPath -match '\\\\') {
            $psdPath = $psdPath -replace '\\\\', '\'
        }
        
        if (Test-Path $psdPath) {
            $iniLines += "[$layerIdx.0]"
            $iniLines += "_name=$($layer.name)"
            $iniLines += "type=0"
            $iniLines += "filter=2"
            $iniLines += "name=PSDToolKit"
            $psdEsc = $psdPath -replace '\\', '\\'
            $iniLines += "param=file=`"$psdEsc`""
            $iniLines += ""
            
            Write-Host "  ✅ Layer $layerIdx [PSD]" -ForegroundColor Green
        }
    }
    
    $layerIdx++
}

# 音声レイヤー
Write-Host "  📊 音声レイヤー..." -ForegroundColor Cyan
foreach ($audio in $audioData) {
    $startFr = [int]($audio.TimelineStart * $videoRate)
    $endFr = [int](($audio.TimelineStart + $audio.Duration) * $videoRate)
    
    $iniLines += "[$layerIdx]"
    $iniLines += "start=$startFr"
    $iniLines += "end=$endFr"
    $iniLines += "layer=$layerIdx"
    $iniLines += ""
    
    $iniLines += "[$layerIdx.0]"
    $iniLines += "_name=$($audio.File)"
    $iniLines += "type=0"
    $iniLines += "filter=0"
    $audioEsc = $audio.FullPath -replace '\\', '\\'
    $iniLines += "file=`"$audioEsc`""
    $iniLines += ""
    
    Write-Host "  ✅ 音声 $layerIdx" -ForegroundColor Green
    $layerIdx++
}

# Step 4: ファイル出力
Write-Host "`n[ 4/4 ] 出力..." -ForegroundColor Yellow

$outDir = Split-Path -Parent $OutputPath
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$iniContent = $iniLines -join [System.Environment]::NewLine
$utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($iniContent)
$iniBytes = [System.Text.Encoding]::Convert([System.Text.Encoding]::UTF8, [System.Text.Encoding]::GetEncoding("shift_jis"), $utf8Bytes)
[System.IO.File]::WriteAllBytes($OutputPath, $iniBytes)

if (Test-Path $OutputPath) {
    $fileSize = (Get-Item $OutputPath).Length
    Write-Host "  ✅ 完了: $($fileSize) bytes" -ForegroundColor Green
    Write-Host "  📄 $OutputPath" -ForegroundColor Cyan
    Write-Host "`n  🎉 INI Exo 生成成功" -ForegroundColor Green
}
else {
    Write-Host "  ❌ 失敗" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
#Requires -Version 5.1
<#
.SYNOPSIS
    AviUtl Exo ファイル生成スクリプト（ID 027 Phase 5.5.2 - INI形式完全実装）

.DESCRIPTION
    voice/ ディレクトリの .wav ファイルをタイムラインに配置し、
    AviUtl 互換の INI 形式で Exo ファイルを生成する。
    
    ✅ Session 27 INI形式完全書き直し版
    - 形式: AviUtl標準 INI形式 ([exedit], [N], [N.M] セクション)
    - PSDToolKit対応: filter=2
    - 参考: C:\AviUtl\1.tutorial\exo\Layer4.exo

.PARAMETER OutputPath
    生成する Exo ファイルの出力パス（デフォルト: ./project.exo）

.PARAMETER LayoutConfigPath
    レイアウト設定 JSON ファイルのパス（デフォルト: ./video_layout.json）

.PARAMETER DynamicsLayoutPath
    動的レイアウト設定 JSON ファイルのパス（デフォルト: ./video_layout_dynamics.json）

.EXAMPLE
    .\generate_exo.ps1
    .\generate_exo.ps1 -OutputPath "./output/timeline.exo"
#>

param(
    [string]$OutputPath = "./project.exo",
    [string]$LayoutConfigPath = "./video_layout.json",
    [string]$DynamicsLayoutPath = "./video_layout_dynamics.json"
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptRoot
$voiceDir = Join-Path $projectRoot "output\voice"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " AviUtl INI形式 Exo ファイル生成" -ForegroundColor Cyan
Write-Host " (Phase 5.5.2: Session 27)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ========================================
# ステップ 1: 入力ファイル確認
# ========================================

Write-Host "[ 1/4 ] 入力ファイル確認..." -ForegroundColor Yellow

if (-not (Test-Path $voiceDir)) {
    Write-Host "  ❌ voice ディレクトリ未検出: $voiceDir" -ForegroundColor Red
    exit 1
}

$wavFiles = @(Get-ChildItem -Path $voiceDir -Filter "*.wav" -ErrorAction SilentlyContinue | Sort-Object Name)

if ($wavFiles.Count -eq 0) {
    Write-Host "  ⚠️  WAV ファイル未検出" -ForegroundColor Yellow
    exit 1
}

Write-Host "  ✅ WAV ファイル: $($wavFiles.Count) 個" -ForegroundColor Green

# ========================================
# ステップ 2: WAV メタデータ取得
# ========================================

Write-Host "`n[ 2/4 ] オーディオメタデータ取得..." -ForegroundColor Yellow

$audioData = @()
$totalDuration = 0

foreach ($wav in $wavFiles) {
    try {
        $fs = [System.IO.File]::OpenRead($wav.FullName)
        $br = New-Object System.IO.BinaryReader($fs)
        
        # WAV ヘッダー解析
        $riff = $br.ReadBytes(4)
        $riff_size = $br.ReadInt32()
        $wave = $br.ReadBytes(4)
        
        # fmt チャンク
        $fmt = $br.ReadBytes(4)
        $fmt_size = $br.ReadInt32()
        $audio_fmt = $br.ReadInt16()
        $channels = $br.ReadInt16()
        $sample_rate = $br.ReadInt32()
        $byte_rate = $br.ReadInt32()
        $block_align = $br.ReadInt16()
        $bits_psample = $br.ReadInt16()
        
        # メタデータ計算
        $data_size = $riff_size - 36
        $duration = [double]$data_size / $byte_rate
        
        $br.Close()
        $fs.Close()
        
        $audioData += @{
            File          = $wav.Name
            FullPath      = $wav.FullName
            Duration      = $duration
            TimelineStart = $totalDuration
        }
        
        $totalDuration += $duration
        
        Write-Host "  ✅ $($wav.Name): $([math]::Round($duration, 2))s" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠️  解析エラー: $($wav.Name)" -ForegroundColor Yellow
    }
}

Write-Host "  📊 合計時間: $([math]::Round($totalDuration, 2))s" -ForegroundColor Cyan

# ========================================
# ステップ 2.5: レイアウト JSON 読込
# ========================================

Write-Host "`n[ 2.5/4 ] レイアウト設定読込..." -ForegroundColor Yellow

if (-not [System.IO.Path]::IsPathRooted($LayoutConfigPath)) {
    $LayoutConfigPath = Join-Path $projectRoot $LayoutConfigPath
}

$layoutLayers = @()

if (Test-Path $LayoutConfigPath) {
    try {
        $layoutConfig = Get-Content $LayoutConfigPath | ConvertFrom-Json
        $layoutLayers = $layoutConfig.layers
        Write-Host "  ✅ レイアウト: $($layoutLayers.Count) レイヤー" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠️  レイアウト JSON 読込失敗" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  ⚠️  レイアウト JSON 未検出" -ForegroundColor Yellow
}

# ========================================
# ステップ 3: INI ファイル生成
# ========================================

Write-Host "`n[ 3/4 ] INI ファイル生成..." -ForegroundColor Yellow

$width = 1920
$height = 1080
$videoRate = 30
$audioRate = 44100
$totalFrames = [int]($totalDuration * $videoRate)

$iniLines = @()

# [exedit] ヘッダーセクション
$iniLines += "[exedit]"
$iniLines += "width=$width"
$iniLines += "height=$height"
$iniLines += "rate=$videoRate"
$iniLines += "scale=1"
$iniLines += "length=$totalFrames"
$iniLines += "audio_rate=$audioRate"
$iniLines += "audio_ch=2"
$iniLines += ""

# ========== レイアウトレイヤー処理
Write-Host "  📊 映像レイヤー処理中..." -ForegroundColor Cyan

$layerIdx = 0

foreach ($layer in $layoutLayers) {
    $iniLines += "[$layerIdx]"
    $iniLines += "start=0"
    $iniLines += "end=$totalFrames"
    $iniLines += "layer=$layerIdx"
    $iniLines += ""
    
    if ($layer.type -eq "psd_image" -and -not [string]::IsNullOrEmpty($layer.psdFile)) {
        $psdPath = $layer.psdFile
        
        if (-not [System.IO.Path]::IsPathRooted($psdPath)) {
            $psdPath = $psdPath -replace '/', '\'
            $psdPath = "$projectRoot\$psdPath"
        }
        
        # パス正規化
        while ($psdPath -match '\\\\') {
            $psdPath = $psdPath -replace '\\\\', '\'
        }
        
        if (Test-Path $psdPath) {
            $iniLines += "[$layerIdx.0]"
            $iniLines += "_name=$($layer.name)"
            $iniLines += "type=0"
            $iniLines += "filter=2"
            $iniLines += "name=PSDToolKit"
            $psdEsc = $psdPath -replace '\\', '\\'
            $iniLines += "param=file=`"$psdEsc`""
            $iniLines += ""
            
            Write-Host "  ✅ レイヤー $layerIdx [PSD] ($($layer.name))" -ForegroundColor Green
        }
    }
    
    $layerIdx++
}

# ========== 音声レイヤー
Write-Host "  📊 音声レイヤー処理中..." -ForegroundColor Cyan

foreach ($audio in $audioData) {
    $startFr = [int]($audio.TimelineStart * $videoRate)
    $endFr = [int](($audio.TimelineStart + $audio.Duration) * $videoRate)
    
    $iniLines += "[$layerIdx]"
    $iniLines += "start=$startFr"
    $iniLines += "end=$endFr"
    $iniLines += "layer=$layerIdx"
    $iniLines += ""
    
    $iniLines += "[$layerIdx.0]"
    $iniLines += "_name=$($audio.File)"
    $iniLines += "type=0"
    $iniLines += "filter=0"
    $audioEsc = $audio.FullPath -replace '\\', '\\'
    $iniLines += "file=`"$audioEsc`""
    $iniLines += ""
    
    Write-Host "  ✅ 音声 $layerIdx ($($audio.File))" -ForegroundColor Green
    $layerIdx++
}

# ========================================
# ステップ 4: ファイル出力
# ========================================

Write-Host "`n[ 4/4 ] ファイル出力..." -ForegroundColor Yellow

$outDir = Split-Path -Parent $OutputPath
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$iniContent = $iniLines -join [System.Environment]::NewLine
$utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($iniContent)
$iniBytes = [System.Text.Encoding]::Convert([System.Text.Encoding]::UTF8, [System.Text.Encoding]::GetEncoding("shift_jis"), $utf8Bytes)
[System.IO.File]::WriteAllBytes($OutputPath, $iniBytes)

Write-Host "  ✅ ファイル出力完了" -ForegroundColor Green

if (Test-Path $OutputPath) {
    $fileSize = (Get-Item $OutputPath).Length
    Write-Host "  📄 出力先: $OutputPath" -ForegroundColor Cyan
    Write-Host "  📊 ファイルサイズ: $fileSize bytes" -ForegroundColor Cyan
    Write-Host "  🎉 INI形式 Exo ファイル生成成功！" -ForegroundColor Green
}
else {
    Write-Host "  ❌ ファイル生成失敗" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " 完了" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
#Requires -Version 5.1
<#
.SYNOPSIS
    AviUtl Exo ファイル生成スクリプト（ID 017 Phase 3 → Phase 5.4 拡張版）

.DESCRIPTION
    voice/ ディレクトリの .wav ファイルをタイムラインに配置し、
    映像要素（背景、立ち絵、テロップ、字幕）を追加し、
    トランジション効果（Phase 5.3 effect_config）を適用した AviUtl 互換の Exo ファイルを生成する。

.PARAMETER OutputPath
    生成する Exo ファイルの出力パス（デフォルト: ./project.exo）

.PARAMETER LayoutConfigPath
    レイアウト設定 JSON ファイルのパス（デフォルト: ./video_layout.json）
    generate_video_elements.ps1 で生成されるファイル

.PARAMETER DynamicsLayoutPath
    動的レイアウト設定 JSON ファイルのパス（デフォルト: ./video_layout_dynamics.json）
    generate_video_layout_dynamics.ps1 で生成されるファイル (Phase 5.2)
    selected_effect フィールド含む (Phase 5.3)

.PARAMETER EffectConfigPath
    トランジション効果設定 JSON ファイルのパス（デフォルト: ../effect_config.json）
    effect_config.json で生成されるファイル (Phase 5.3)

.EXAMPLE
    .\generate_exo.ps1
    .\generate_exo.ps1 -OutputPath "./output/timeline.exo" -EffectConfigPath "../effect_config.json"

.NOTES
    - AVIUTL_ROOT, VOICEVOX_PORT が設定されている必要があります
    - voice/ ディレクトリ内の .wav ファイルを時間順に配置します
    - video_layout.json を使用して映像レイアウトを反映します (Phase 5.1)
    - video_layout_dynamics.json でセグメント情報とトランジション効果を反映します (Phase 5.2-5.3)
    - effect_config.json でトランジション効果定義を参照します (Phase 5.3)
#>

param(
    [string]$OutputPath = "./project.exo",
    [string]$LayoutConfigPath = "./video_layout.json",
    [string]$DynamicsLayoutPath = "./video_layout_dynamics.json",
    [string]$EffectConfigPath = "../effect_config.json"
)

# ========================================
# 環境セットアップ
# ========================================

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptRoot  # aviutl_voicevox_pipeline ディレクトリ
$voiceDir = Join-Path $projectRoot "output\voice"
$videoDir = Join-Path $projectRoot "output\video"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " AviUtl Exo ファイル生成 (Phase 5.4)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
Write-Host "実装: ID 025 Phase 5.4 - トランジション効果統合" -ForegroundColor Green
Write-Host "  ✅ Phase 5.1: 映像レイヤー (video_layout.json)" -ForegroundColor Gray
Write-Host "  ✅ Phase 5.2: 動的レイアウト (video_layout_dynamics.json)" -ForegroundColor Gray
Write-Host "  ✅ Phase 5.3: エフェクト定義 (effect_config.json)" -ForegroundColor Gray
Write-Host "  🆕 Phase 5.4: トランジション統合 (selected_effect → Exo)" -ForegroundColor Green
Write-Host ""

# ========================================
# ステップ 1: 入力ファイル確認
# ========================================

Write-Host "[ 1/4 ] 入力ファイル確認..." -ForegroundColor Yellow

if (-not (Test-Path $voiceDir)) {
    Write-Host "  ❌ voice ディレクトリが見つかりません: $voiceDir" -ForegroundColor Red
    exit 1
}

$wavFiles = @(Get-ChildItem -Path $voiceDir -Filter "*.wav" -ErrorAction SilentlyContinue | Sort-Object Name)

if ($wavFiles.Count -eq 0) {
    Write-Host "  ⚠️  voice ディレクトリに .wav ファイルがありません" -ForegroundColor Yellow
    Write-Host "     先に generate_voice.ps1 を実行してください" -ForegroundColor Gray
    exit 1
}

Write-Host "  ✅ 検出ファイル数: $($wavFiles.Count)" -ForegroundColor Green
foreach ($wav in $wavFiles) {
    Write-Host "     - $($wav.Name)" -ForegroundColor Cyan
}

# ========================================
# ステップ 2: .wav メタデータ取得
# ========================================

Write-Host "`n[ 2/4 ] オーディオメタデータ取得..." -ForegroundColor Yellow

$audioMetadata = @()
$totalDuration = 0

foreach ($wav in $wavFiles) {
    try {
        # .wav ファイルからメタデータを取得
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.Namespace($wav.Directory.FullName)
        $file = $folder.ParseName($wav.Name)
        
        # 代替: PowerShell で直接 .wav ヘッダーを読む
        $fileStream = [System.IO.File]::OpenRead($wav.FullName)
        $reader = New-Object System.IO.BinaryReader($fileStream)
        
        # WAV ヘッダー解析
        $riff = $reader.ReadBytes(4) | ForEach-Object { [char]$_ } -Begin { $s = "" } { $s += $_ } -End { $s }
        $fileSize = $reader.ReadInt32()
        $wave = $reader.ReadBytes(4) | ForEach-Object { [char]$_ } -Begin { $s = "" } { $s += $_ } -End { $s }
        
        # fmt サブチャンク探索
        $fmt = $reader.ReadBytes(4) | ForEach-Object { [char]$_ } -Begin { $s = "" } { $s += $_ } -End { $s }
        $fmtSize = $reader.ReadInt32()
        $audioFormat = $reader.ReadInt16()
        $channels = $reader.ReadInt16()
        $sampleRate = $reader.ReadInt32()
        $byteRate = $reader.ReadInt32()
        $blockAlign = $reader.ReadInt16()
        $bitsPerSample = $reader.ReadInt16()
        
        # data サイズ計算
        $audioDataSize = $fileSize - 36
        $durationSeconds = [double]($audioDataSize) / $byteRate
        
        $reader.Close()
        $fileStream.Close()
        
        $metadata = @{
            File          = $wav.Name
            FullPath      = $wav.FullName
            Duration      = $durationSeconds
            Channels      = $channels
            SampleRate    = $sampleRate
            BitsPerSample = $bitsPerSample
            TimelineStart = $totalDuration
        }
        
        $audioMetadata += $metadata
        $totalDuration += $durationSeconds
        
        Write-Host "  ✅ $($wav.Name): ${durationSeconds}s (SR: $sampleRate Hz, Ch: $channels)" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠️  メタデータ取得エラー ($($wav.Name)): $_" -ForegroundColor Yellow
    }
}

Write-Host "  📊 合計時間: ${totalDuration}s" -ForegroundColor Cyan

# ========================================
# ステップ 2.5: レイアウト JSON 読込 (Phase 5.1)
# ========================================

Write-Host "`n[ 2.5/5 ] レイアウト設定読込 (Phase 5.1)..." -ForegroundColor Yellow

# LayoutConfig パスが相対パスの場合、projectRoot 基準に
if (-not [System.IO.Path]::IsPathRooted($LayoutConfigPath)) {
    $LayoutConfigPath = Join-Path $projectRoot $LayoutConfigPath
}

$layoutLayers = @()

if (Test-Path $LayoutConfigPath) {
    try {
        $layoutConfig = Get-Content $LayoutConfigPath | ConvertFrom-Json
        $layoutLayers = $layoutConfig.layers
        Write-Host "  ✅ レイアウト設定読込成功" -ForegroundColor Green
        Write-Host "     パターン: $($layoutConfig.pattern) - $($layoutConfig.description)" -ForegroundColor Cyan
        Write-Host "     総レイヤー数: $($layoutLayers.Count)" -ForegroundColor Cyan
    }
    catch {
        Write-Host "  ⚠️  レイアウト JSON 読込エラー: $_" -ForegroundColor Yellow
        Write-Host "     映像レイヤーなしで Exo を生成します" -ForegroundColor Gray
    }
}
else {
    Write-Host "  ⚠️  レイアウト JSON ファイルが見つかりません: $LayoutConfigPath" -ForegroundColor Yellow
    Write-Host "     generate_video_elements.ps1 を先に実行してください" -ForegroundColor Gray
}

# ========================================
# ステップ 2.7: 動的レイアウト JSON 読込 (Phase 5.2)
# ========================================

Write-Host "`n[ 2.7/5 ] 動的レイアウト読込 (Phase 5.2)..." -ForegroundColor Yellow

$dynamicLayout = $null
$segments = @()

# DynamicsLayoutPath が相対パスの場合、projectRoot 基準に
if (-not [System.IO.Path]::IsPathRooted($DynamicsLayoutPath)) {
    $DynamicsLayoutPath = Join-Path $projectRoot $DynamicsLayoutPath
}

if (Test-Path $DynamicsLayoutPath) {
    try {
        $dynamicLayout = Get-Content $DynamicsLayoutPath | ConvertFrom-Json
        $segments = $dynamicLayout.segments
        Write-Host "  ✅ 動的レイアウト読込成功" -ForegroundColor Green
        Write-Host "     総セグメント数: $($segments.Count)" -ForegroundColor Cyan
        Write-Host "     合計時間: $([System.Math]::Round($dynamicLayout.metadata.total_duration / 1000, 2))秒" -ForegroundColor Cyan
        
        # セグメント情報をログ出力
        foreach ($segment in $segments) {
            Write-Host "     Segment #$($segment.id): Speaker $($segment.speaker_name) ($($segment.duration)ms)" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "  ⚠️  動的レイアウト JSON 読込エラー: $_" -ForegroundColor Yellow
        Write-Host "     トランジション効果なしで Exo を生成します" -ForegroundColor Gray
    }
}
else {
    Write-Host "  ⚠️  動的レイアウト JSON ファイルが見つかりません: $DynamicsLayoutPath" -ForegroundColor Yellow
    Write-Host "     generate_video_layout_dynamics.ps1 を先に実行してください（オプション）" -ForegroundColor Gray
}

# ========================================
# ステップ 2.8: エフェクト設定読込 (Phase 5.4)
# ========================================

Write-Host "`n[ 2.8/5 ] エフェクト設定読込 (Phase 5.3 Effect Config)..." -ForegroundColor Yellow

$effectConfig = $null
$effectDefinitions = @{}

# EffectConfigPath が相対パスの場合、projectRoot 基準に
if (-not [System.IO.Path]::IsPathRooted($EffectConfigPath)) {
    $EffectConfigPath = Join-Path $projectRoot $EffectConfigPath
}

if (Test-Path $EffectConfigPath) {
    try {
        $effectConfig = Get-Content $EffectConfigPath | ConvertFrom-Json
        
        # 利用可能なエフェクト定義をマップ化
        if ($effectConfig.available_effects) {
            foreach ($effect in $effectConfig.available_effects) {
                $effectDefinitions[$effect.name] = $effect
            }
        }
        
        Write-Host "  ✅ エフェクト設定読込成功" -ForegroundColor Green
        Write-Host "     利用可能エフェクト: $($effectDefinitions.Keys.Count) 種類" -ForegroundColor Cyan
        foreach ($effectName in $effectDefinitions.Keys) {
            $effect = $effectDefinitions[$effectName]
            Write-Host "     - $effectName : $($effect.duration_ms)ms, $($effect.easing)" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  ⚠️  エフェクト設定読込エラー: $_" -ForegroundColor Yellow
        Write-Host "     デフォルトトランジション（フェード）で処理します" -ForegroundColor Gray
    }
}
else {
    Write-Host "  ⚠️  エフェクト設定ファイルが見つかりません: $EffectConfigPath" -ForegroundColor Yellow
    Write-Host "     generate_video_layout_dynamics.ps1 (Phase 5.3) を先に実行してください（推奨）" -ForegroundColor Gray
}


Write-Host "`n[ 3/5 ] Exo ファイル生成..." -ForegroundColor Yellow

# ========================================
# ユーティリティ関数: トランジション変換 (Phase 5.4)
# ========================================

function Get-AviUtlTransitionCommand {
    <#
    .SYNOPSIS
        Phase 5.3 selected_effect → AviUtl トランジションコマンド変換
    
    .PARAMETER SelectedEffect
        selected_effect オブジェクト { name, duration_ms, easing, ... }
    
    .PARAMETER EffectDefinitions
        effect_config.json から読み込んだエフェクト定義マップ
    
    .OUTPUT
        AviUtl互換の<transition>タグ内容
    #>
    param(
        [PSObject]$SelectedEffect,
        [hashtable]$EffectDefinitions
    )
    
    if (-not $SelectedEffect) {
        # デフォルト: フェード（300ms）
        return @{
            type      = "fade"
            duration  = 300
            intensity = 100
        }
    }
    
    $effectName = $SelectedEffect.name
    $duration = $SelectedEffect.duration_ms
    
    # エフェクト定義に基づいて AviUtl コマンド生成
    if ($EffectDefinitions.ContainsKey($effectName)) {
        $effectDef = $EffectDefinitions[$effectName]
        
        # AviUtl エフェクト名マッピング
        $aviutlName = switch ($effectName) {
            "fade" { "フェード" }
            "dissolve" { "ディゾルブ" }
            "slide_left" { "スライド" }
            "slide_right" { "スライド" }
            "fade_through_color" { "色を通して フェード" }
            default { "フェード" }
        }
        
        # スライド効果の方向設定
        $params = @{}
        if ($effectName -like "slide_*") {
            $direction = if ($effectName -eq "slide_left") { 90 } else { 270 }
            $params["direction"] = $direction
        }
        
        return @{
            type      = $aviutlName
            duration  = $duration
            easing    = $effectDef.easing
            intensity = 100
            params    = $params
        }
    }
    else {
        # デフォルト: フェード
        return @{
            type      = "フェード"
            duration  = $duration
            intensity = 100
        }
    }
}

function Format-TransitionXml {
    <#
    .SYNOPSIS
        トランジション情報を Exo XML フォーマットに変換
    
    .PARAMETER Transition
        トランジション情報オブジェクト
    
    .PARAMETER StartFrame
        トランジション開始フレーム
    #>
    param(
        [PSObject]$Transition,
        [int]$StartFrame
    )
    
    if (-not $Transition) { return "" }
    
    $xml = "        <!-- Transition: $($Transition.type) ($($Transition.duration)ms) -->`n" +
    "        <transition`n" +
    "          type=`"$($Transition.type)`"`n" +
    "          frame=`"$StartFrame`"`n" +
    "          duration=`"$($Transition.duration)`"`n" +
    "          intensity=`"$($Transition.intensity)`"`n"
    
    if ($Transition.easing) {
        $xml += "          easing=`"$($Transition.easing)`"`n"
    }
    
    $xml += "        />`n"
    
    return $xml
}



# デフォルト設定（1920x1080, 30fps）
$width = 1920
$height = 1080
$videoRate = 30
$audioRate = 44100

# フレーム数計算
$totalFrames = [int]($totalDuration * $videoRate)

# ========================================
# セグメント処理と トランジション情報構築 (Phase 5.4)
# ========================================

Write-Host "  📊 セグメント情報処理中..." -ForegroundColor Cyan

$segmentTransitions = @()  # トランジション情報リスト

if ($segments.Count -gt 1) {
    for ($i = 0; $i -lt $segments.Count - 1; $i++) {
        $currentSeg = $segments[$i]
        $nextSeg = $segments[$i + 1]
        
        $transitionStartTime = ($currentSeg.start + $currentSeg.duration) / 1000  # ミリ秒を秒に変換
        $transitionStartFrame = [int]($transitionStartTime * $videoRate)
        
        # selected_effect を取得
        $selectedEffect = if ($currentSeg.selected_effect) { $currentSeg.selected_effect } else { $null }
        
        # トランジション情報生成
        $transition = Get-AviUtlTransitionCommand -SelectedEffect $selectedEffect -EffectDefinitions $effectDefinitions
        
        $segmentTransitions += @{
            segment_from = $currentSeg.id
            segment_to   = $nextSeg.id
            start_frame  = $transitionStartFrame
            transition   = $transition
            effect_name  = if ($selectedEffect) { $selectedEffect.name } else { "default_fade" }
        }
        
        Write-Host "    ✅ Transition $($currentSeg.id)→$($nextSeg.id): $($transition.type) @ frame $transitionStartFrame" -ForegroundColor Green
    }
}
else {
    Write-Host "    ℹ️  セグメント1個のみ: トランジションなし" -ForegroundColor Gray
}

# XML ドキュメント作成
$xmlDeclaration = '<?xml version="1.0" encoding="utf-8"?>'
$exoContent = @"
$xmlDeclaration
<aviutl>
  <project
    width="$width"
    height="$height"
    video_rate="$videoRate"
    video_scale="1"
    audio_rate="$audioRate"
    audio_ch="2"
    sample_rate="$audioRate"
    length="$totalFrames"
  >
    <!-- Phase 5.4 実装: トランジション効果統合 -->
    <!-- セグメント間トランジション定義 -->
"@

# ========================================
# 映像レイヤー追加 (Phase 5.1)
# ========================================

if ($layoutLayers.Count -gt 0) {
    Write-Host "  📊 映像レイヤー追加中..." -ForegroundColor Cyan
    
    foreach ($layer in $layoutLayers) {
        switch ($layer.type) {
            "color_gradient" {
                # 背景レイヤー（グラデーション）
                $exoContent += @"

    <!-- Layer $($layer.layer): $($layer.name) (背景) -->
    <object
      index="$($layer.layer)"
      name="$($layer.name)"
      type="color_gradient"
      colorTop="$($layer.color_top)"
      colorBottom="$($layer.color_bottom)"
      x="$($layer.x)"
      y="$($layer.y)"
      width="$($layer.width)"
      height="$($layer.height)"
      alpha="$($layer.alpha)"
      start="0"
      end="$totalFrames"
      locked="$($layer.locked)"
    />
"@
                Write-Host "    ✅ Layer $($layer.layer): $($layer.name) (グラデーション背景)" -ForegroundColor Green
            }
            "psd_image" {
                # PSD 立ち絵レイヤー (PSDToolKit XML/Lua フォーマット)
                if (-not [string]::IsNullOrEmpty($layer.psdFile)) {
                    $psdPath = $layer.psdFile
                    
                    # 相対パスの場合、プロジェクトルートをベースに完全パスに変換
                    if (-not [System.IO.Path]::IsPathRooted($psdPath)) {
                        # 相対パスを正規化（スラッシュをバックスラッシュに）
                        $psdPath = $psdPath -replace '/', '\'
                        # プロジェクトルートと結合
                        $psdPath = "$projectRoot\$psdPath"
                    }
                    
                    # パス正規化: 重複したセパレータを削除
                    while ($psdPath -match '\\\\') {
                        $psdPath = $psdPath -replace '\\\\', '\'
                    }
                    $psdPath = $psdPath -replace '\\\.\\', '\'
                    $psdPath = $psdPath -replace '\.\\', '\'
                    
                    if (Test-Path $psdPath) {
                        # PSDToolKit 用に Windows パスをエスケープ（\\ に変換）
                        $psdPathEscaped = $psdPath -replace '\\', '\\'
                        $psdFilename = Split-Path -Leaf $psdPath
                        
                        # XML/Lua ハイブリッド形式で生成（PSDToolKit 公式パターン）
                        $exoContent += @"

    <!-- Layer $($layer.layer): $($layer.name) (PSD 立ち絵 - $($layer.characterName)) -->
    <!-- PSDToolKit XML/Lua フォーマット Integration (Phase 5.5.1) -->
`<?-- $psdFilename
o={
  lipsync=2,
  ptkf=`"$psdPathEscaped`",
  ptkl=`"L.0 V._BAAaYw`"
}PSD,subobj=require(`"PSDToolKit`").PSDState.init(obj,o)?>
"@
                        Write-Host "    ✅ Layer $($layer.layer): $($layer.name) ($($layer.characterName)) [PSDToolKit XML/Lua]" -ForegroundColor Green
                        Write-Host "       PSD Path: $psdPath" -ForegroundColor Gray
                    }
                    else {
                        Write-Host "    ⚠️  PSD ファイルが見つかりません: $psdPath" -ForegroundColor Yellow
                    }
                }
            }
            "text_box" {
                # テキストレイヤー
                $exoContent += @"

    <!-- Layer $($layer.layer): $($layer.name) (テキスト) -->
    <object
      index="$($layer.layer)"
      name="$($layer.name)"
      type="text"
      text=""
      x="$($layer.x)"
      y="$($layer.y)"
      width="$($layer.width)"
      height="$($layer.height)"
      fontSize="$($layer.text_config.fontSize)"
      fontFamily="$($layer.text_config.fontFamily)"
      fontColor="$($layer.text_config.fontColor)"
      fontBold="$($layer.text_config.fontBold)"
      alignment="$($layer.text_config.alignment)"
      backgroundColor="$($layer.backgroundColor)"
      borderColor="$($layer.borderColor)"
      borderWidth="$($layer.borderWidth)"
      start="0"
      end="$totalFrames"
      locked="$($layer.locked)"
    />
"@
                Write-Host "    ✅ Layer $($layer.layer): $($layer.name) (テキスト)" -ForegroundColor Green
            }
        }
    }
}

# ========================================
# トランジション情報追加 (Phase 5.4)
# ========================================

Write-Host "  📊 トランジション情報追加中..." -ForegroundColor Cyan

if ($segmentTransitions.Count -gt 0) {
    $exoContent += "`n"
    $exoContent += "    <!-- Transitions (Phase 5.4: selected_effect 統合) -->`n"
    
    foreach ($trans in $segmentTransitions) {
        $transXml = Format-TransitionXml -Transition $trans.transition -StartFrame $trans.start_frame
        $exoContent += $transXml
        Write-Host "    ✅ Transition XML 追加: $($trans.effect_name) @ frame $($trans.start_frame)" -ForegroundColor Green
    }
}
else {
    Write-Host "    ℹ️  トランジション情報なし（セグメント1個 or selected_effect 未設定）" -ForegroundColor Gray
}

# ========================================
# 音声トラック追加
# ========================================

Write-Host "  📊 音声トラック追加中..." -ForegroundColor Cyan

$trackId = $layoutLayers.Count
$currentFrame = 0

foreach ($audio in $audioMetadata) {
    $startFrame = [int]($audio.TimelineStart * $videoRate)
    $endFrame = [int](($audio.TimelineStart + $audio.Duration) * $videoRate)
    $duration = $endFrame - $startFrame
    
    $exoContent += @"

    <!-- Audio Track: $($audio.File) -->
    <object
      index="$trackId"
      name="$($audio.File)"
      src="$($audio.FullPath)"
      start="$startFrame"
      end="$endFrame"
      layer="$($layoutLayers.Count)"
      time="0"
      x="0"
      y="0"
      scale_x="1"
      scale_y="1"
      alpha="255"
      rotate="0"
    />
"@
    Write-Host "    ✅ 音声: $($audio.File) (${startFrame}f - ${endFrame}f)" -ForegroundColor Green
    
    $trackId++
}

$exoContent += @"

  </project>
</aviutl>
"@

# ファイル出力
$outputDir = Split-Path -Parent $OutputPath
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$exoContent | Out-File -FilePath $OutputPath -Encoding UTF8 -NoNewline

Write-Host "  ✅ Exo ファイル生成完了" -ForegroundColor Green
Write-Host "     出力先: $OutputPath" -ForegroundColor Cyan

# ========================================
# ステップ 5: 確認
# ========================================

Write-Host "`n[ 5/5 ] 出力確認..." -ForegroundColor Yellow

if (Test-Path $OutputPath) {
    $fileSize = (Get-Item $OutputPath).Length
    Write-Host "  ✅ ファイルサイズ: $fileSize bytes" -ForegroundColor Green
    Write-Host "  📄 プロジェクト設定:" -ForegroundColor Cyan
    Write-Host "     - 解像度: ${width}x${height}" -ForegroundColor Gray
    Write-Host "     - フレームレート: ${videoRate} fps" -ForegroundColor Gray
    Write-Host "     - 長さ: $totalFrames フレーム (${totalDuration}s)" -ForegroundColor Gray
    Write-Host "     - 音声レート: $audioRate Hz" -ForegroundColor Gray
    Write-Host "  🎨 映像レイヤー: $($layoutLayers.Count) レイヤー" -ForegroundColor Gray
    foreach ($layer in $layoutLayers) {
        Write-Host "     - Layer $($layer.layer): $($layer.name)" -ForegroundColor Gray
    }
    Write-Host "`n  🎉 Exo ファイル生成成功！" -ForegroundColor Green
    Write-Host "     AviUtl で 'ファイル → 開く' で $OutputPath を選択してください" -ForegroundColor Cyan
}
else {
    Write-Host "  ❌ Exo ファイル生成失敗" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " 実行完了 (Phase 5.4: トランジション効果統合)===================================`n" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
