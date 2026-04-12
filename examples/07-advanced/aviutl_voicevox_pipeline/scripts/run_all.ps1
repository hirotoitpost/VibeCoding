#Requires -Version 5.1
<#
.SYNOPSIS
    AviUtl 動画生成パイプライン統合実行スクリプト

.DESCRIPTION
    以下の処理を順序立てて実行します:
    1. 環境チェック (check_env.ps1)
    2. 音声生成 (generate_voice.ps1)
    3. Exo タイムライン生成 (generate_exo.ps1)
    4. AviUtl 実行（テンプレート）

.PARAMETER SkipEnvCheck
    環境チェックをスキップする

.PARAMETER SkipVoiceGeneration
    音声生成をスキップする

.PARAMETER SkipExoGeneration
    Exo 生成をスキップする

.EXAMPLE
    .\run_all.ps1
    .\run_all.ps1 -SkipEnvCheck
    .\run_all.ps1 -SkipVoiceGeneration -SkipExoGeneration

.NOTES
    このスクリプトは ID 017 Phase 4 用のマスターランナーです。
#>

param(
    [switch]$SkipEnvCheck = $false,
    [switch]$SkipVoiceGeneration = $false,
    [switch]$SkipExoGeneration = $false
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptRoot  # aviutl_voicevox_pipeline ディレクトリ

Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  AviUtl 動画生成パイプライン (ID 017)     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date

# ========================================
# ステップ 1: 環境チェック
# ========================================

if (-not $SkipEnvCheck) {
    Write-Host "[ 1/4 ] 環境チェック..." -ForegroundColor Yellow
    & "$scriptRoot\check_env.ps1"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n❌ 環境チェック失敗" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# ========================================
# ステップ 2: 音声生成
# ========================================

if (-not $SkipVoiceGeneration) {
    Write-Host "[ 2/4 ] 音声生成..." -ForegroundColor Yellow
    & "$scriptRoot\generate_voice.ps1"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n❌ 音声生成失敗" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# ========================================
# ステップ 3: Exo タイムライン生成
# ========================================

if (-not $SkipExoGeneration) {
    Write-Host "[ 3/4 ] Exo タイムライン生成..." -ForegroundColor Yellow
    $exoOutput = Join-Path $projectRoot "output\project.exo"
    & "$scriptRoot\generate_exo.ps1" -OutputPath $exoOutput
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n❌ Exo 生成失敗" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# ========================================
# ステップ 4: AviUtl 実行（テンプレート）
# ========================================

Write-Host "[ 4/4 ] AviUtl 実行..." -ForegroundColor Yellow
Write-Host "  📌 注: このステップは実装予定中です" -ForegroundColor Gray

if ($env:AVIUTL_ROOT) {
    $aviutlExe = Join-Path $env:AVIUTL_ROOT "aviutl.exe"
    if (Test-Path $aviutlExe) {
        $exoFile = Join-Path $projectRoot "output\project.exo"
        Write-Host "  💡 手動操作: $aviutlExe を起動し、作成した $exoFile を開いてください" -ForegroundColor Cyan
        Write-Host "     または以下を実行:" -ForegroundColor Gray
        Write-Host "     & `"$aviutlExe`" `"$exoFile`"" -ForegroundColor Gray
    }
}

# ========================================
# 完了
# ========================================

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🎉 パイプライン実行完了                 ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n📊 実行統計:" -ForegroundColor Cyan
Write-Host "   実行時間: $([int]$duration.TotalSeconds) 秒" -ForegroundColor Gray
Write-Host "   開始時刻: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
Write-Host "   終了時刻: $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray

Write-Host "`n📁 出力ファイル:" -ForegroundColor Cyan
$outputDir = Join-Path $projectRoot "output"
if (Test-Path $outputDir) {
    Get-ChildItem -Path $outputDir -Recurse -File | Select-Object -ExpandProperty FullName | ForEach-Object {
        $relativePath = $_ -replace [regex]::Escape($projectRoot), "."
        Write-Host "   $relativePath" -ForegroundColor Gray
    }
}

Write-Host "`n✅ 準備完了です。次のステップに進んでください:" -ForegroundColor Green
Write-Host "   1. output/project.exo を AviUtl で検証" -ForegroundColor Gray
Write-Host "   2. 必要に応じて手動編集" -ForegroundColor Gray
Write-Host "   3. AviUtl で出力（MP4/AVI）" -ForegroundColor Gray

Write-Host ""
