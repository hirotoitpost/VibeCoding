# VibeCoding 開発環境セットアップスクリプト（Windows PowerShell 5.1+）
# 用途: 初回セットアップ時に実行
# 機能:
#   1. PowerShell プロフィールの自動設定
#   2. .env ファイルの初期化
#   3. Python 仮想環境の作成（オプション）

param(
    [switch]$SkipProfile,    # プロフィール設定をスキップ
    [switch]$SkipVenv        # Python 仮想環境作成をスキップ
)

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "🚀 VibeCoding 開発環境セットアップ" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# ========================================
# 1. PowerShell プロフィール設定
# ========================================

if (-not $SkipProfile) {
    Write-Host "📋 ステップ 1: PowerShell プロフィール設定" -ForegroundColor Yellow
    
    $ProfileDir = Split-Path -Parent $PROFILE
    $ProfilePath = $PROFILE
    
    # プロフィールディレクトリがなければ作成
    if (-not (Test-Path $ProfileDir)) {
        New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
        Write-Host "   ✅ プロフィールディレクトリを作成: $ProfileDir"
    }
    
    # VibeCoding セクションを追加
    $VibeCodingRoot = Get-Location
    $ProfileContent = @"
# =====================================================
# VibeCoding プロジェクト - 環境変数読み込み
# =====================================================

# VibeCoding ルートディレクトリ
`$VibeCodingRoot = "$VibeCodingRoot"

# 作業ディレクトリが VibeCoding なら、自動で .env を読み込む
`$CurrentLocation = Get-Location
if (`$CurrentLocation.Path -eq `$VibeCodingRoot -or `$CurrentLocation.Path -like "`$VibeCodingRoot*") {
    `$LoadEnvScript = Join-Path `$VibeCodingRoot "scripts\load-env.ps1"
    if (Test-Path `$LoadEnvScript) {
        Write-Host "🚀 VibeCoding 環境変数を読み込んでいます..." -ForegroundColor Cyan
        & `$LoadEnvScript
    }
}
"@
    
    # プロフィールが存在すればバックアップ
    if (Test-Path $ProfilePath) {
        $BackupPath = "$ProfilePath.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item -Path $ProfilePath -Destination $BackupPath -Force
        Write-Host "   ✅ プロフィールをバックアップ: $BackupPath"
    }
    
    # VibeCoding セクションが既存なら上書き、なければ追加
    if (Test-Path $ProfilePath) {
        $CurrentContent = Get-Content $ProfilePath -Raw
        if ($CurrentContent -match "VibeCoding プロジェクト") {
            # 既に VibeCoding セクションが存在
            Write-Host "   ℹ️  VibeCoding セクションが既に存在します"
        }
        else {
            Add-Content -Path $ProfilePath -Value "`n$ProfileContent"
            Write-Host "   ✅ プロフィールに VibeCoding 設定を追加"
        }
    }
    else {
        Set-Content -Path $ProfilePath -Value $ProfileContent
        Write-Host "   ✅ 新規プロフィール作成: $ProfilePath"
    }
    
    Write-Host ""
}

# ========================================
# 2. .env ファイル初期化
# ========================================

Write-Host "📋 ステップ 2: 環境変数ファイル (.env) の初期化" -ForegroundColor Yellow

$EnvExamplePath = "$(Get-Location)\.env.example"
$EnvPath = "$(Get-Location)\.env"

if (-not (Test-Path $EnvPath) -and (Test-Path $EnvExamplePath)) {
    Copy-Item -Path $EnvExamplePath -Destination $EnvPath
    Write-Host "   ✅ .env ファイルを作成: $EnvPath"
    Write-Host "   ℹ️  .env.example をコピーしました"
    Write-Host "   📝 必要に応じて .env を編集してください"
}
elseif (Test-Path $EnvPath) {
    Write-Host "   ℹ️  .env ファイルは既に存在します"
}
else {
    Write-Host "   ⚠️  .env.example が見つかりません"
}

Write-Host ""

# ========================================
# 3. Python 仮想環境（オプション）
# ========================================

if (-not $SkipVenv) {
    Write-Host "📋 ステップ 3: Python 仮想環境の作成（オプション）" -ForegroundColor Yellow
    
    $python = Get-Command python -ErrorAction SilentlyContinue
    if ($python) {
        $venvPath = "$(Get-Location)\.venv"
        if (-not (Test-Path $venvPath)) {
            Write-Host "   🔨 仮想環境を作成しています..."
            python -m venv .venv
            Write-Host "   ✅ 仮想環境を作成: $venvPath"
            Write-Host "   📝 有効化: .\.venv\Scripts\Activate.ps1"
        }
        else {
            Write-Host "   ℹ️  仮想環境は既に存在します"
        }
    }
    else {
        Write-Host "   ⚠️  Python がインストールされていません（スキップ）"
    }
}

Write-Host ""

# ========================================
# 完了
# ========================================

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "✅ セットアップ完了！" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎯 次のステップ:" -ForegroundColor Cyan
Write-Host "  1. PowerShell を再起動する"
Write-Host "  2. VibeCoding ディレクトリで新しいターミナルを開く"
Write-Host "  3. 環境変数が読み込まれたか確認："
Write-Host "     `$env:AVIUTL_ROOT"
Write-Host ""
