# AviUtl + PSDToolKit + VOICEVOX 動画自動生成システム
# 環境チェック・セットアップスクリプト

<#
.SYNOPSIS
    動画生成パイプラインの環境確認スクリプト

.DESCRIPTION
    以下のコンポーネントの存在を検証します:
    - AviUtl (AVIUTL_ROOT 環境変数確認)
    - VOICEVOX (APIサーバー疎通確認)
    - 必要なディレクトリ構造

.EXAMPLE
    .\scripts\check_env.ps1
#>

$ErrorCount = 0

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " VibeCoding 動画生成パイプライン 環境チェック" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# ========================================
# 1. AviUtl チェック
# ========================================
Write-Host "[ 1/3 ] AviUtl チェック..." -ForegroundColor Yellow

if ([string]::IsNullOrEmpty($env:AVIUTL_ROOT)) {
    Write-Host "  ❌ 環境変数 AVIUTL_ROOT が設定されていません" -ForegroundColor Red
    Write-Host "     .env ファイルに AVIUTL_ROOT=C:\AviUtl を設定してください" -ForegroundColor Gray
    $ErrorCount++
}
elseif (-not (Test-Path $env:AVIUTL_ROOT)) {
    Write-Host "  ❌ AVIUTL_ROOT のパスが存在しません: $env:AVIUTL_ROOT" -ForegroundColor Red
    $ErrorCount++
}
else {
    $aviutlExe = Join-Path $env:AVIUTL_ROOT "aviutl.exe"
    if (Test-Path $aviutlExe) {
        Write-Host "  ✅ AviUtl: $aviutlExe" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠️  AviUtl ディレクトリ存在: $env:AVIUTL_ROOT" -ForegroundColor Yellow
        Write-Host "     ただし aviutl.exe が見つかりません" -ForegroundColor Gray
    }

    # PSDToolKit チェック
    $psdToolKit = Join-Path $env:AVIUTL_ROOT "plugins\PSDToolKit.auf"
    if (Test-Path $psdToolKit) {
        Write-Host "  ✅ PSDToolKit プラグイン: 導入済み" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠️  PSDToolKit プラグイン: 未導入" -ForegroundColor Yellow
        Write-Host "     SETUP_GUIDE.md の手順でインストールしてください" -ForegroundColor Gray
    }
}

Write-Host ""

# ========================================
# 2. VOICEVOX チェック
# ========================================
Write-Host "[ 2/3 ] VOICEVOX チェック..." -ForegroundColor Yellow

# VOICEVOX_ROOT チェック
if ([string]::IsNullOrEmpty($env:VOICEVOX_ROOT)) {
    Write-Host "  ⚠️  環境変数 VOICEVOX_ROOT が設定されていません" -ForegroundColor Yellow
    Write-Host "     .env ファイルに VOICEVOX_ROOT=C:\\Program Files\\VOICEVOX を設定してください" -ForegroundColor Gray
} elseif (-not (Test-Path $env:VOICEVOX_ROOT)) {
    Write-Host "  ⚠️  VOICEVOX_ROOT のパスが存在しません: $env:VOICEVOX_ROOT" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ VOICEVOX Root: $env:VOICEVOX_ROOT" -ForegroundColor Green
}

# VOICEVOX API 疎通確認
$voicevoxPort = if ($env:VOICEVOX_PORT) { $env:VOICEVOX_PORT } else { 50021 }

try {
    $response = Invoke-WebRequest -Uri "http://localhost:$voicevoxPort/version" -TimeoutSec 3 -ErrorAction Stop
    $version = $response.Content.Trim('"')
    Write-Host "  ✅ VOICEVOX API 接続成功 (バージョン: $version、ポート: $voicevoxPort)" -ForegroundColor Green
}
catch {
    Write-Host "  ❌ VOICEVOX API に接続できません (http://localhost:$voicevoxPort)" -ForegroundColor Red
    Write-Host "     VOICEVOX を起動してから再実行してください" -ForegroundColor Gray
    $ErrorCount++
}

Write-Host ""

# ========================================
# 3. 出力ディレクトリチェック
# ========================================
Write-Host "[ 3/3 ] 出力ディレクトリ チェック..." -ForegroundColor Yellow

$dirs = @("output/voice", "output/video", "scripts", "scenarios")
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  📁 作成: $dir" -ForegroundColor Cyan
    }
    else {
        Write-Host "  ✅ 存在: $dir" -ForegroundColor Green
    }
}

Write-Host ""

# ========================================
# 結果サマリー
# ========================================
Write-Host "=============================================" -ForegroundColor Cyan

if ($ErrorCount -eq 0) {
    Write-Host " ✅ 環境チェック完了！パイプライン実行準備OK" -ForegroundColor Green
    Write-Host ""
    Write-Host " 次のステップ:" -ForegroundColor Cyan
    Write-Host "   1. シナリオファイル作成: scenarios\01_intro.txt"
    Write-Host "   2. 音声生成: .\scripts\generate_voice.ps1"
    Write-Host "   3. Exo 生成: .\scripts\generate_exo.ps1"
}
else {
    Write-Host " ❌ $ErrorCount 個の問題を解決してください" -ForegroundColor Red
    Write-Host " SETUP_GUIDE.md を参照してください" -ForegroundColor Gray
}

Write-Host "=============================================" -ForegroundColor Cyan
