# ========================================
# VOICEVOX テスト実行スクリプト
# ========================================
# 機能: 
#   1. VOICEVOX API (http://localhost:50021) に接続
#   2. 春日部つむぎ（Speaker ID: 14）に音声合成させる
#   3. 「準備完了だよ！」と喋らせる
#   4. 音声ファイル (.wav) を保存・再生
# ========================================

param(
    [string]$VoiceText = "準備完了だよ！",
    [int]$SpeakerId = 14,
    [string]$VoicevoxUrl = "http://localhost:50021",
    [string]$OutputFile = ""
)

# ロゴ表示
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "VOICEVOX テストスクリプト" -ForegroundColor Cyan
Write-Host "春日部つむぎ (Speaker ID: 14)" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 環境変数から URL を取得（パラメータで上書き可）
if (-not $VoicevoxUrl -and $env:VOICEVOX_ENGINE_URL) {
    $VoicevoxUrl = $env:VOICEVOX_ENGINE_URL
}

# デフォルト URL
if (-not $VoicevoxUrl) {
    $VoicevoxUrl = "http://localhost:50021"
}

Write-Host "設定:" -ForegroundColor Yellow
Write-Host "  テキスト: $VoiceText"
Write-Host "  Speaker ID: $SpeakerId"
Write-Host "  VOICEVOX URL: $VoicevoxUrl"
Write-Host ""

# ========== Step 1: VOICEVOX の接続確認 ==========
Write-Host "[Step 1] VOICEVOX に接続中..." -ForegroundColor Yellow

try {
    $healthUrl = "$VoicevoxUrl/health"
    $response = Invoke-WebRequest -Uri $healthUrl -Method Get -ErrorAction Stop
    
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✅ VOICEVOX は起動しています" -ForegroundColor Green
        Write-Host "     URL: $VoicevoxUrl"
    } else {
        Write-Host "  ❌ VOICEVOX からの応答が異常です (Status: $($response.StatusCode))" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  ❌ VOICEVOX に接続できません" -ForegroundColor Red
    Write-Host "     エラー: $_"
    Write-Host ""
    Write-Host "  対処方法:" -ForegroundColor Yellow
    Write-Host "    1. VOICEVOX がインストールされているか確認"
    Write-Host "    2. VOICEVOX が起動しているか確認"
    Write-Host "    3. ポート 50021 が使用可能か確認"
    Write-Host "    4. URL が正しいか確認: $VoicevoxUrl"
    Write-Host ""
    exit 1
}

Write-Host ""

# ========== Step 2: 音声クエリを生成 ==========
Write-Host "[Step 2] 音声クエリを生成中..." -ForegroundColor Yellow

$audioQueryUrl = "$VoicevoxUrl/audio_query"
$audioQueryParams = @{
    text = $VoiceText
    speaker = $SpeakerId
}

# クエリ文字列を構築
$queryString = "text=$([Uri]::EscapeDataString($VoiceText))&speaker=$SpeakerId"

try {
    $audioQueryResponse = Invoke-WebRequest `
        -Uri "$audioQueryUrl`?$queryString" `
        -Method Post `
        -ErrorAction Stop

    if ($audioQueryResponse.StatusCode -eq 200) {
        $audioQueryJson = $audioQueryResponse.Content | ConvertFrom-Json
        Write-Host "  ✅ 音声クエリ生成成功" -ForegroundColor Green
        Write-Host "     応答サイズ: $($audioQueryResponse.Content.Length) bytes"
    } else {
        Write-Host "  ❌ 音声クエリ生成に失敗 (Status: $($audioQueryResponse.StatusCode))" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  ❌ 音声クエリ生成エラー" -ForegroundColor Red
    Write-Host "     エラー: $_"
    exit 1
}

Write-Host ""

# ========== Step 3: 音声合成 ==========
Write-Host "[Step 3] 音声合成中..." -ForegroundColor Yellow

$synthesisUrl = "$VoicevoxUrl/synthesis"

try {
    # JSON ボディを準備
    $bodyJson = $audioQueryJson | ConvertTo-Json
    
    $synthesisResponse = Invoke-WebRequest `
        -Uri "$synthesisUrl`?speaker=$SpeakerId" `
        -Method Post `
        -Body $bodyJson `
        -ContentType "application/json" `
        -ErrorAction Stop

    if ($synthesisResponse.StatusCode -eq 200) {
        Write-Host "  ✅ 音声合成成功" -ForegroundColor Green
        Write-Host "     音声データサイズ: $($synthesisResponse.Content.Length) bytes"
    } else {
        Write-Host "  ❌ 音声合成に失敗 (Status: $($synthesisResponse.StatusCode))" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  ❌ 音声合成エラー" -ForegroundColor Red
    Write-Host "     エラー: $_"
    exit 1
}

Write-Host ""

# ========== Step 4: 音声ファイルを保存 ==========
Write-Host "[Step 4] 音声ファイルを保存中..." -ForegroundColor Yellow

# 出力ファイルパスを決定
if (-not $OutputFile) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $outputDir = Join-Path $env:USERPROFILE "Desktop"
    $OutputFile = Join-Path $outputDir "tsumugi_test_${timestamp}.wav"
}

try {
    # WAV ファイルとして保存
    $synthesisResponse.Content | Set-Content -Path $OutputFile -AsByteStream -ErrorAction Stop
    
    Write-Host "  ✅ 音声ファイルを保存しました" -ForegroundColor Green
    Write-Host "     パス: $OutputFile"
} catch {
    Write-Host "  ❌ 音声ファイルの保存に失敗" -ForegroundColor Red
    Write-Host "     エラー: $_"
    exit 1
}

Write-Host ""

# ========== Step 5: 音声ファイルを再生（オプション） ==========
Write-Host "[Step 5] 音声ファイルを再生中..." -ForegroundColor Yellow
Write-Host ""

try {
    # メディアプレイヤーで再生
    $player = New-Object System.Media.SoundPlayer
    $player.SoundLocation = $OutputFile
    $player.PlaySync()
    
    Write-Host "  ✅ 再生完了" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  再生エラー: $_" -ForegroundColor Yellow
    Write-Host "     ファイルのみ保存しました: $OutputFile"
}

Write-Host ""

# ========== 完了メッセージ ==========
Write-Host "=====================================" -ForegroundColor Green
Write-Host "✅ テスト完了！" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "生成されたファイル:" -ForegroundColor Cyan
Write-Host "  $OutputFile"
Write-Host ""
Write-Host "次のステップ:" -ForegroundColor Cyan
Write-Host "  1. Shoost で春日部つむぎのPSDを読み込む"
Write-Host "  2. ゆかりねっとコネクターNEO で音声入力をセットアップ"
Write-Host "  3. launch_tsumugi_system.bat で全ツールを起動"
Write-Host ""
Write-Host "詳細は SETUP_INSTRUCTIONS.md を参照してください。" -ForegroundColor Yellow
Write-Host ""
