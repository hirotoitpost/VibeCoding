# ============================================
# VOICEVOX 音声一括生成スクリプト
# ============================================
# 用途: シナリオファイルから音声ファイルを一括生成する
# 使用例: .\scripts\generate_voice.ps1 -InputDir .\scenarios -OutputDir .\output\voice

param(
    [string]$InputDir = ".\scenarios",
    [string]$OutputDir = ".\output\voice",
    [int]$SpeakerId = 8,               # 8 = 春日部つむぎ (ノーマル, デフォルト)
    [int]$StyleId = 8,                 # Style: 8 = ノーマル
    [string]$VoicevoxPort = $null      # $null = $env:VOICEVOX_PORT から取得
)

# 環境変数から VOICEVOX_PORT を取得
if ([string]::IsNullOrEmpty($VoicevoxPort)) {
    $VoicevoxPort = if ($env:VOICEVOX_PORT) { $env:VOICEVOX_PORT } else { 50021 }
}

$VoicevoxUrl = "http://localhost:$VoicevoxPort"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " VOICEVOX 音声一括生成" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Input : $InputDir"
Write-Host "  Output: $OutputDir"
Write-Host "  Speaker: ID $SpeakerId - 春日部つむぎ (Style: $StyleId - ノーマル)"
Write-Host ""

# 出力ディレクトリ確認
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# VOICEVOX 疎通確認
try {
    Invoke-WebRequest -Uri "$VoicevoxUrl/version" -TimeoutSec 3 -ErrorAction Stop | Out-Null
}
catch {
    Write-Host "❌ VOICEVOX に接続できません。起動してから再実行してください。" -ForegroundColor Red
    exit 1
}

# シナリオファイルを順番に処理
$scenarioFiles = Get-ChildItem -Path $InputDir -Filter "*.txt" | Sort-Object Name

if ($scenarioFiles.Count -eq 0) {
    Write-Host "⚠️  $InputDir に .txt ファイルが見つかりません" -ForegroundColor Yellow
    exit 0
}

Write-Host "📄 $($scenarioFiles.Count) 個のシナリオファイルを処理します" -ForegroundColor Cyan
Write-Host ""

$successCount = 0

foreach ($file in $scenarioFiles) {
    $text = Get-Content $file.FullName -Raw -Encoding UTF8

    # 空行・コメント行を除去
    $text = ($text -split "`n" | Where-Object { $_ -notmatch "^#" -and $_.Trim() -ne "" }) -join ""

    if ([string]::IsNullOrWhiteSpace($text)) {
        Write-Host "  ⏭️  スキップ: $($file.Name) (内容なし)" -ForegroundColor Gray
        continue
    }

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $outputFile = Join-Path $OutputDir "$baseName.wav"

    Write-Host "  🎤 生成: $($file.Name) → $baseName.wav" -ForegroundColor Yellow

    try {
        # Step 1: audio_query (テキスト → クエリ)
        $queryBody = [System.Web.HttpUtility]::UrlEncode($text)
        $queryResponse = Invoke-RestMethod -Uri "$VoicevoxUrl/audio_query?speaker=$SpeakerId&style_id=$StyleId&text=$queryBody" `
            -Method Post -ContentType "application/json" -ErrorAction Stop

        # Step 2: synthesis (クエリ → 音声)
        $queryJson = $queryResponse | ConvertTo-Json -Depth 10
        $audioResponse = Invoke-WebRequest -Uri "$VoicevoxUrl/synthesis?speaker=$SpeakerId&style_id=$StyleId" `
            -Method Post -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($queryJson)) `
            -ErrorAction Stop

        [System.IO.File]::WriteAllBytes((Resolve-Path $OutputDir).Path + "\$baseName.wav", $audioResponse.Content)

        Write-Host "     ✅ 完了 ($([math]::Round($audioResponse.Content.Length / 1024, 1)) KB)" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "     ❌ エラー: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " 完了: $successCount / $($scenarioFiles.Count) ファイル生成" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
