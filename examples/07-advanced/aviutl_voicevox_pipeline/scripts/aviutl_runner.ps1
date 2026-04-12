# AviUtl CUI 動画エンコード実行スクリプト
# 役割: Exo ファイルを受け取り、AviUtl CUI で動画をエンコードする

<#
.SYNOPSIS
    AviUtl CUI を使用して、Exo ファイルを動画にエンコードします

.DESCRIPTION
    以下の処理を実行します:
    1. Exo ファイルの存在確認
    2. AviUtl CUI の起動 (/export フラグ)
    3. エンコード進捗の監視
    4. 出力ファイルの検証
    5. エラーハンドリング

.PARAMETER ExoFilePath
    Exo ファイルのパス。デフォルトは project.exo

.PARAMETER OutputFormat
    出力形式。デフォルトは 'mp4'. 可能な値: mp4, avi

.PARAMETER ConfigPath
    output_config.json のパス

.EXAMPLE
    .\scripts\aviutl_runner.ps1 -ExoFilePath "project.exo" -OutputFormat "mp4"

.NOTES
    環境変数:
    - AVIUTL_ROOT: AviUtl のインストールディレクトリ (C:\AviUtl など)
    - PSDTOOLKIT_ROOT: PSDToolKit のパス（オプション）
#>

param(
    [string]$ExoFilePath = "project.exo",
    [string]$OutputFormat = "mp4",
    [string]$ConfigPath = "output_config.json"
)

$ErrorCount = 0
$WarningCount = 0

# スクリプトの場所からプロジェクトルートを計算
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptRoot
$outputDir = Join-Path $projectRoot "output" "video"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " AviUtl CUI 動画エンコード実行" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# ========================================
# 1. Exo ファイル検証
# ========================================
Write-Host "[ 1/4 ] Exo ファイル検証..." -ForegroundColor Yellow

# Exo パスが相対パスの場合、プロジェクトルート基準に
if (-not [System.IO.Path]::IsPathRooted($ExoFilePath)) {
    $ExoFilePath = Join-Path $projectRoot $ExoFilePath
}

if (-not (Test-Path $ExoFilePath)) {
    Write-Host "  ❌ Exo ファイルが見つかりません: $ExoFilePath" -ForegroundColor Red
    exit 1
}

$exoFileSize = (Get-Item $ExoFilePath).Length
Write-Host "  ✅ Exo ファイル: $ExoFilePath ($($exoFileSize / 1KB)KB)" -ForegroundColor Green
Write-Host ""

# ========================================
# 2. AviUtl CUI 環境検証
# ========================================
Write-Host "[ 2/4 ] AviUtl CUI 環境検証..." -ForegroundColor Yellow

# AVIUTL_ROOT チェック
if ([string]::IsNullOrEmpty($env:AVIUTL_ROOT)) {
    Write-Host "  ❌ 環境変数 AVIUTL_ROOT が設定されていません" -ForegroundColor Red
    Write-Host "     .env ファイルに AVIUTL_ROOT を設定してください" -ForegroundColor Gray
    exit 1
}

$aviutlExe = Join-Path $env:AVIUTL_ROOT "aviutl.exe"
if (-not (Test-Path $aviutlExe)) {
    Write-Host "  ❌ AviUtl が見つかりません: $aviutlExe" -ForegroundColor Red
    exit 1
}

Write-Host "  ✅ AviUtl: $aviutlExe" -ForegroundColor Green

# 出力ディレクトリ作成
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    Write-Host "  ✅ 出力ディレクトリ作成: $outputDir" -ForegroundColor Green
}
else {
    Write-Host "  ✅ 出力ディレクトリ: $outputDir" -ForegroundColor Green
}

Write-Host ""

# ========================================
# 3. 出力形式・設定読込
# ========================================
Write-Host "[ 3/4 ] 出力形式・設定読込..." -ForegroundColor Yellow

# Config パスが相対パスの場合、プロジェクトルート基準に
if (-not [System.IO.Path]::IsPathRooted($ConfigPath)) {
    $ConfigPath = Join-Path $projectRoot $ConfigPath
}

$outputFile = ""
$outputExt = ""

if (Test-Path $ConfigPath) {
    try {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        
        if ($OutputFormat -eq "mp4") {
            $outputExt = ".mp4"
            $profile = $config.profiles.hd_mp4
            if ($profile) {
                Write-Host "  ✅ MP4 プロフィール: ビットレート=$($profile.bitrate), FPS=$($profile.fps)" -ForegroundColor Green
            }
        }
        elseif ($OutputFormat -eq "avi") {
            $outputExt = ".avi"
            $profile = $config.profiles.full_hd_mp4
            if ($profile) {
                Write-Host "  ✅ AVI プロフィール: ビットレート=$($profile.bitrate), FPS=$($profile.fps)" -ForegroundColor Green
            }
        }
        else {
            Write-Host "  ⚠️  不明な形式: $OutputFormat (デフォルト: mp4)" -ForegroundColor Yellow
            $outputExt = ".mp4"
        }
    }
    catch {
        Write-Host "  ⚠️  Config ファイルの読込エラー: $_" -ForegroundColor Yellow
        $outputExt = ".mp4"
    }
}
else {
    Write-Host "  ⚠️  Config ファイルが見つかりません: $ConfigPath (デフォルト: MP4)" -ForegroundColor Yellow
    $outputExt = ".mp4"
}

# 出力ファイル名を生成
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputFile = Join-Path $outputDir "output_${timestamp}${outputExt}"

Write-Host "  ✅ 出力ファイル: $outputFile" -ForegroundColor Green
Write-Host ""

# ========================================
# 4. AviUtl CUI 実行
# ========================================
Write-Host "[ 4/4 ] AviUtl CUI エンコード実行..." -ForegroundColor Yellow
Write-Host "  📽️  処理開始: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan

# AviUtl CUI コマンド構築
# /export フラグ: プロジェクトを開いてエクスポートモードで実行
$aviutlArgs = @(
    "/export",           # エクスポートモード
    "`"$ExoFilePath`"",  # Exo ファイルパス
    "`"$outputFile`""    # 出力ファイルパス
)

Write-Host "  コマンド: $aviutlExe $($aviutlArgs -join ' ')" -ForegroundColor Gray

# プロセス実行
try {
    $process = Start-Process -FilePath $aviutlExe -ArgumentList $aviutlArgs -PassThru -NoNewWindow
    
    # プロセス終了を待機（timeout: 1時間）
    $processCompleted = $process.WaitForExit(3600000)
    
    if (-not $processCompleted) {
        Write-Host "  ⚠️  処理がタイムアウトしました (1時間)" -ForegroundColor Yellow
        $process.Kill()
        $ErrorCount++
    }
    else {
        $exitCode = $process.ExitCode
        
        if ($exitCode -eq 0) {
            Write-Host "  ✅ AviUtl 処理完了 (Exit Code: $exitCode)" -ForegroundColor Green
        }
        else {
            Write-Host "  ⚠️  AviUtl 実行: Exit Code $exitCode" -ForegroundColor Yellow
            $WarningCount++
        }
    }
}
catch {
    Write-Host "  ❌ AviUtl 起動エラー: $_" -ForegroundColor Red
    $ErrorCount++
}

Write-Host ""

# ========================================
# 5. 出力ファイル検証
# ========================================
Write-Host "[ 5/5 ] 出力ファイル検証..." -ForegroundColor Yellow

if (Test-Path $outputFile) {
    $fileSize = (Get-Item $outputFile).Length
    Write-Host "  ✅ 出力ファイル作成成功: $outputFile" -ForegroundColor Green
    Write-Host "     ファイルサイズ: $([math]::Round($fileSize / 1MB, 2)) MB" -ForegroundColor Green
}
else {
    Write-Host "  ⚠️  出力ファイルが見つかりません: $outputFile" -ForegroundColor Yellow
    Write-Host "     AviUtl が正常に実行されたか確認してください" -ForegroundColor Gray
    $WarningCount++
}

Write-Host ""

# ========================================
# 完了サマリー
# ========================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " エンコード完了サマリー" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host "  入力 Exo:     $ExoFilePath" -ForegroundColor Gray
Write-Host "  出力形式:     $OutputFormat" -ForegroundColor Gray
Write-Host "  出力ファイル: $outputFile" -ForegroundColor Gray
Write-Host "  処理時間:     $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "  エラー数:     $ErrorCount" -ForegroundColor Gray
Write-Host "  警告数:       $WarningCount" -ForegroundColor Gray

if ($ErrorCount -eq 0) {
    Write-Host ""
    Write-Host "  ✅ エンコード完了！" -ForegroundColor Green
    exit 0
}
else {
    Write-Host ""
    Write-Host "  ❌ エラーがあります。詳細を確認してください" -ForegroundColor Red
    exit 1
}
