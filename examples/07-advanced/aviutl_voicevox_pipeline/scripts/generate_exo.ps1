#Requires -Version 5.1
<#
.SYNOPSIS
    AviUtl Exo ファイル生成スクリプト（ID 017 Phase 3）

.DESCRIPTION
    voice/ ディレクトリの .wav ファイルをタイムラインに配置し、
    AviUtl 互換の Exo ファイルを生成する。

.PARAMETER OutputPath
    生成する Exo ファイルの出力パス（デフォルト: ./project.exo）

.EXAMPLE
    .\generate_exo.ps1
    .\generate_exo.ps1 -OutputPath "./output/timeline.exo"

.NOTES
    - AVIUTL_ROOT, VOICEVOX_PORT が設定されている必要があります
    - voice/ ディレクトリ内の .wav ファイルを時間順に配置します
#>

param(
    [string]$OutputPath = "./project.exo"
)

# ========================================
# 環境セットアップ
# ========================================

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptRoot  # aviutl_voicevox_pipeline ディレクトリ
$voiceDir = Join-Path $projectRoot "output\voice"
$videoDir = Join-Path $projectRoot "output\video"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " AviUtl Exo ファイル生成 (ID 017 Phase 3)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

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
        $riff = $reader.ReadBytes(4) | ForEach-Object { [char]$_ } -Begin {$s=""} {$s += $_} -End {$s}
        $fileSize = $reader.ReadInt32()
        $wave = $reader.ReadBytes(4) | ForEach-Object { [char]$_ } -Begin {$s=""} {$s += $_} -End {$s}
        
        # fmt サブチャンク探索
        $fmt = $reader.ReadBytes(4) | ForEach-Object { [char]$_ } -Begin {$s=""} {$s += $_} -End {$s}
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
            File = $wav.Name
            FullPath = $wav.FullName
            Duration = $durationSeconds
            Channels = $channels
            SampleRate = $sampleRate
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
# ステップ 3: Exo XML 生成
# ========================================

Write-Host "`n[ 3/4 ] Exo ファイル生成..." -ForegroundColor Yellow

# デフォルト設定（1920x1080, 30fps）
$width = 1920
$height = 1080
$videoRate = 30
$audioRate = 44100

# フレーム数計算
$totalFrames = [int]($totalDuration * $videoRate)

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
"@

# オブジェクト追加（簡易版：音声トラック）
$trackId = 0
$currentFrame = 0

foreach ($audio in $audioMetadata) {
    $startFrame = [int]($audio.TimelineStart * $videoRate)
    $endFrame = [int](($audio.TimelineStart + $audio.Duration) * $videoRate)
    $duration = $endFrame - $startFrame
    
    $exoContent += @"

    <!-- Track: $($audio.File) -->
    <object
      index="$trackId"
      name="$($audio.File)"
      src="$($audio.FullPath)"
      start="$startFrame"
      end="$endFrame"
      layer="0"
      time="0"
      x="0"
      y="0"
      scale_x="1"
      scale_y="1"
      alpha="255"
      rotate="0"
    />
"@
    
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
# ステップ 4: 確認
# ========================================

Write-Host "`n[ 4/4 ] 出力確認..." -ForegroundColor Yellow

if (Test-Path $OutputPath) {
    $fileSize = (Get-Item $OutputPath).Length
    Write-Host "  ✅ ファイルサイズ: $fileSize bytes" -ForegroundColor Green
    Write-Host "  📄 プロジェクト設定:" -ForegroundColor Cyan
    Write-Host "     - 解像度: ${width}x${height}" -ForegroundColor Gray
    Write-Host "     - フレームレート: ${videoRate} fps" -ForegroundColor Gray
    Write-Host "     - 長さ: $totalFrames フレーム (${totalDuration}s)" -ForegroundColor Gray
    Write-Host "     - 音声レート: $audioRate Hz" -ForegroundColor Gray
    Write-Host "`n  🎉 Exo ファイル生成成功！" -ForegroundColor Green
    Write-Host "     AviUtl で 'ファイル → 開く' で $OutputPath を選択してください" -ForegroundColor Cyan
} else {
    Write-Host "  ❌ Exo ファイル生成失敗" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " 実行完了" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
