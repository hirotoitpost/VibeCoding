# ========================================
# 春日部つむぎ システム 環境自動セットアップスクリプト
# ========================================
# 機能:
#   1. ユーザー入力でツールパスを取得
#   2. フォルダを自動作成
#   3. 環境変数を永続化 (User レベル)
#   4. 起動ランチャーを生成
# ========================================

param(
    [string]$VOICEVOXPath = "",
    [string]$TsumugiAssetDir = "",
    [string]$ShoostPath = "",
    [string]$ゆかりねっとPath = ""
)

# ロゴ表示
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "春日部つむぎ 立ち絵解説動画システム" -ForegroundColor Cyan
Write-Host "環境自動セットアップスクリプト" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# ========== Step 1: ユーザー入力 ==========
Write-Host "[Step 1] インストールパスの入力" -ForegroundColor Yellow
Write-Host ""

# VOICEVOX パス
if (-not $VOICEVOXPath) {
    Write-Host "VOICEVOX のインストール先パスを入力してください。"
    Write-Host "例: C:\Program Files\VOICEVOX"
    Write-Host "（未入力の場合はスキップ）"
    $VOICEVOXPath = Read-Host "VOICEVOX パス"
}

# 春日部つむぎ立ち絵資産ディレクトリ
if (-not $TsumugiAssetDir) {
    Write-Host ""
    Write-Host "春日部つむぎ立ち絵資産フォルダのパスを入力してください。"
    Write-Host "例: C:\Users\YourName\Tsumugi\Assets"
    Write-Host "（このフォルダにPSDファイルを格納します）"
    $TsumugiAssetDir = Read-Host "資産フォルダ パス"
}

# Shoost パス
if (-not $ShoostPath) {
    Write-Host ""
    Write-Host "Shoost のインストール先パスを入力してください。"
    Write-Host "例: C:\Program Files\Shoost"
    Write-Host "（未入力の場合はスキップ）"
    $ShoostPath = Read-Host "Shoost パス"
}

# ゆかりねっとコネクターNEO パス（オプション）
if (-not $ゆかりねっとPath) {
    Write-Host ""
    Write-Host "ゆかりねっとコネクターNEO のインストール先パス（オプション）"
    Write-Host "例: C:\Program Files\ゆかりねっとコネクターNEO"
    Write-Host "（未入力の場合はスキップ）"
    $ゆかりねっとPath = Read-Host "ゆかりねっと パス"
}

Write-Host ""

# ========== Step 2: フォルダ作成 ==========
Write-Host "[Step 2] フォルダを作成中..." -ForegroundColor Yellow
Write-Host ""

$pathsToCreate = @()
if ($VOICEVOXPath) { $pathsToCreate += $VOICEVOXPath }
if ($TsumugiAssetDir) { $pathsToCreate += $TsumugiAssetDir }
if ($ShoostPath) { $pathsToCreate += $ShoostPath }
if ($ゆかりねっとPath) { $pathsToCreate += $ゆかりねっとPath }

foreach ($path in $pathsToCreate) {
    if (-not (Test-Path $path)) {
        try {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
            Write-Host "  ✅ 作成しました: $path"
        } catch {
            Write-Host "  ❌ 作成に失敗しました: $path" -ForegroundColor Red
            Write-Host "     エラー: $_"
        }
    } else {
        Write-Host "  ℹ️  既存: $path"
    }
}

Write-Host ""

# ========== Step 3: 環境変数を永続化 ==========
Write-Host "[Step 3] 環境変数を設定中..." -ForegroundColor Yellow
Write-Host ""

try {
    # 固定値
    [Environment]::SetEnvironmentVariable("VOICEVOX_ENGINE_URL", "http://localhost:50021", "User")
    Write-Host "  ✅ VOICEVOX_ENGINE_URL = http://localhost:50021"

    # ユーザー入力値
    if ($VOICEVOXPath) {
        [Environment]::SetEnvironmentVariable("VOICEVOX_PATH", $VOICEVOXPath, "User")
        Write-Host "  ✅ VOICEVOX_PATH = $VOICEVOXPath"
    }

    if ($TsumugiAssetDir) {
        [Environment]::SetEnvironmentVariable("TSUMUGI_ASSET_DIR", $TsumugiAssetDir, "User")
        Write-Host "  ✅ TSUMUGI_ASSET_DIR = $TsumugiAssetDir"
    }

    if ($ShoostPath) {
        [Environment]::SetEnvironmentVariable("SHOOST_PATH", $ShoostPath, "User")
        Write-Host "  ✅ SHOOST_PATH = $ShoostPath"
    }

    if ($ゆかりねっとPath) {
        [Environment]::SetEnvironmentVariable("YUKARINETTO_PATH", $ゆかりねっとPath, "User")
        Write-Host "  ✅ YUKARINETTO_PATH = $ゆかりねっとPath"
    }

    # 固定値: 春日部つむぎ (Speaker ID: 14)
    [Environment]::SetEnvironmentVariable("VOICE_CHARACTER_ID", "14", "User")
    Write-Host "  ✅ VOICE_CHARACTER_ID = 14 (春日部つむぎ)"

    Write-Host ""
    Write-Host "  環境変数を User レベルで永続化しました。" -ForegroundColor Green

} catch {
    Write-Host "  ❌ 環境変数の設定に失敗しました。" -ForegroundColor Red
    Write-Host "     エラー: $_"
    Write-Host "     管理者権限が必要な場合があります。"
}

Write-Host ""

# ========== Step 4: ランチャー生成 ==========
Write-Host "[Step 4] 起動ランチャーを生成中..." -ForegroundColor Yellow
Write-Host ""

$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$launcherPath = [System.IO.Path]::Combine($desktopPath, "launch_tsumugi_system.bat")

# launch_tools.bat の内容
$launcherContent = @"@echo off
REM ========================================
REM 春日部つむぎ システム 自動起動ランチャー
REM ========================================
REM 機能: VOICEVOX, Shoost, ゆかりねっとコネクターNEO を
REM       環境変数から自動検出して起動

chcp 65001 > nul
setlocal enabledelayedexpansion

echo ===============================================
echo   春日部つむぎ 立ち絵解説動画システム
echo   自動起動ランチャー
echo ===============================================
echo.

REM 環境変数から各パスを取得
set VOICEVOX_PATH=%VOICEVOX_PATH%
set VOICEVOX_ENGINE_URL=%VOICEVOX_ENGINE_URL%
set SHOOST_PATH=%SHOOST_PATH%
set YUKARINETTO_PATH=%YUKARINETTO_PATH%
set VOICE_CHARACTER_ID=%VOICE_CHARACTER_ID%

REM ========== VOICEVOX の起動 ==========
if NOT "!VOICEVOX_PATH!"=="" (
    if exist "!VOICEVOX_PATH!\VOICEVOX.exe" (
        echo [1/3] VOICEVOXを起動中...
        echo       パス: !VOICEVOX_PATH!
        start "" "!VOICEVOX_PATH!\VOICEVOX.exe"
        timeout /t 3 /nobreak
        echo       ✅ VOICEVOX 起動完了 (!VOICEVOX_ENGINE_URL!)
        echo.
    ) else (
        echo [WARNING] VOICEVOXが見つかりません
        echo           パス: !VOICEVOX_PATH!\VOICEVOX.exe
        echo.
    )
) else (
    echo [SKIP] VOICEVOX パスが設定されていません
    echo.
)

REM ========== Shoost の起動 ==========
if NOT "!SHOOST_PATH!"=="" (
    if exist "!SHOOST_PATH!\Shoost.exe" (
        echo [2/3] Shoost を起動中...
        echo       パス: !SHOOST_PATH!
        start "" "!SHOOST_PATH!\Shoost.exe"
        timeout /t 2 /nobreak
        echo       ✅ Shoost 起動完了
        echo.
    ) else (
        echo [WARNING] Shoost が見つかりません
        echo           パス: !SHOOST_PATH!\Shoost.exe
        echo.
    )
) else (
    echo [SKIP] Shoost パスが設定されていません
    echo.
)

REM ========== ゆかりねっとコネクターNEO の起動 ==========
if NOT "!YUKARINETTO_PATH!"=="" (
    if exist "!YUKARINETTO_PATH!\ゆかりねっとコネクターNEO.exe" (
        echo [3/3] ゆかりねっとコネクターNEO を起動中...
        echo       パス: !YUKARINETTO_PATH!
        start "" "!YUKARINETTO_PATH!\ゆかりねっとコネクターNEO.exe"
        timeout /t 2 /nobreak
        echo       ✅ ゆかりねっとコネクターNEO 起動完了
        echo.
    ) else (
        echo [WARNING] ゆかりねっとコネクターNEO が見つかりません
        echo           パス: !YUKARINETTO_PATH!\ゆかりねっとコネクターNEO.exe
        echo.
    )
) else (
    echo [INFO] ゆかりねっとコネクターNEO は手動で起動してください
    echo.
)

REM ========== 完了メッセージ ==========
echo ===============================================
echo すべてのツール起動処理が完了しました！
echo.
echo 次のステップ:
echo   1. VOICEVOX が APIサーバー (http://localhost:50021) として起動
echo   2. Shoost で春日部つむぎのPSDを読み込む
echo   3. ゆかりねっとコネクターNEO で音声入力をセットアップ
echo.
echo 詳細は SETUP_INSTRUCTIONS.md を参照してください。
echo ===============================================
echo.
pause
"@

try {
    $launcherContent | Out-File -FilePath $launcherPath -Encoding UTF8
    Write-Host "  ✅ ランチャー生成: $launcherPath"
} catch {
    Write-Host "  ❌ ランチャー生成に失敗しました。" -ForegroundColor Red
    Write-Host "     エラー: $_"
}

Write-Host ""

# ========== 完了メッセージ ==========
Write-Host "[完了] セットアップが完了しました！" -ForegroundColor Green
Write-Host ""
Write-Host "次のステップ:" -ForegroundColor Cyan
Write-Host "  1. デスクトップの 'launch_tsumugi_system.bat' をダブルクリック"
Write-Host "  2. VOICEVOXが APIサーバー (http://localhost:50021) として起動する"
Write-Host "  3. Shoost で春日部つむぎのPSDを読み込む"
Write-Host "  4. ゆかりねっとコネクターNEO で音声入力をセットアップ"
Write-Host ""
Write-Host "詳細は SETUP_INSTRUCTIONS.md を参照してください。" -ForegroundColor Yellow
Write-Host ""

# オプション: アセットフォルダをエクスプローラーで開く
if ($TsumugiAssetDir -and (Test-Path $TsumugiAssetDir)) {
    Write-Host "アセットフォルダをエクスプローラーで開きますか? (Y/n): " -ForegroundColor Cyan -NoNewline
    $response = Read-Host
    if ($response -ne "n" -and $response -ne "N") {
        try {
            Invoke-Item $TsumugiAssetDir
            Write-Host "✅ エクスプローラーを開きました。"
        } catch {
            Write-Host "⚠️  エクスプローラーの起動に失敗: $_"
        }
    }
}

Write-Host ""
Write-Host "セットアップスクリプトを終了します。" -ForegroundColor Gray
