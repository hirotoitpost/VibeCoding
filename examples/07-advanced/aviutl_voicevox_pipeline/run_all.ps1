# VibeCoding 動画生成パイプライン: 統合実行スクリプト
# 役割: Phase 2 → Phase 3 → Phase 4 を順次実行

<#
.SYNOPSIS
    VibeCoding 動画生成パイプライン全体を実行します

.DESCRIPTION
    以下のフェーズを順次実行して、テキスト入力から動画出力まで自動化します:
    1. Phase 2: generate_voice.ps1     - VOICEVOX で音声ファイル生成
    2. Phase 3: generate_exo.ps1       - 音声メタデータから Exo ファイル生成
    3. Phase 4: aviutl_runner.ps1      - AviUtl CUI で動画にエンコード

.PARAMETER ScriptPath
    スクリプトディレクトリのパス。デフォルトはスクリプト存在ディレクトリ

.PARAMETER FastMode
    True の場合、各フェーズ実行後に一時停止しない（自動実行）

.PARAMETER SkipPhase2
    Phase 2 (音声生成) をスキップ

.PARAMETER SkipPhase3
    Phase 3 (Exo 生成) をスキップ

.PARAMETER SkipPhase4
    Phase 4 (動画エンコード) をスキップ

.EXAMPLE
    .\run_sequence.ps1 -FastMode $true
    # 全フェーズを自動実行

.EXAMPLE
    .\run_sequence.ps1 -SkipPhase2 $true
    # Phase 2 をスキップ (既に音声ファイルが存在する場合)

.NOTES
    各フェーズの詳細ログは console に出力されます。
    エラーが発生した場合は、該当フェーズで停止します。
#>

param(
    [string]$ScriptPath = $null,
    [bool]$FastMode = $false,
    [bool]$SkipPhase2 = $false,
    [bool]$SkipPhase3 = $false,
    [bool]$SkipPhase4 = $false
)

$ErrorCount = 0
$PhaseResults = @()

# スクリプトパス設定
if ([string]::IsNullOrEmpty($ScriptPath)) {
    $ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    if ([string]::IsNullOrEmpty($ScriptPath)) {
        $ScriptPath = (Get-Location).Path
    }
}

$projectRoot = Split-Path -Parent $ScriptPath
$scriptsDir = Join-Path $projectRoot "scripts"

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " VibeCoding 動画生成パイプライン 統合実行" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 プロジェクトルート: $projectRoot" -ForegroundColor Gray
Write-Host "📂 スクリプトディレクトリ: $scriptsDir" -ForegroundColor Gray
Write-Host "⚡ FastMode: $FastMode" -ForegroundColor Gray
Write-Host ""

# ========================================
# ユーティリティ関数
# ========================================
function Invoke-Phase {
    param(
        [string]$PhaseNumber,
        [string]$PhaseName,
        [string]$ScriptPath,
        [string[]]$Arguments
    )
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "[ Phase $PhaseNumber ] $PhaseName" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    
    if (-not (Test-Path $ScriptPath)) {
        Write-Host "  ❌ スクリプトが見つかりません: $ScriptPath" -ForegroundColor Red
        return $false
    }
    
    Write-Host "  🔄 実行開始: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
    
    try {
        # スクリプト実行（引数がある場合）
        if ($Arguments -and $Arguments.Count -gt 0) {
            & $ScriptPath @Arguments
        }
        else {
            & $ScriptPath
        }
        
        $exitCode = $LASTEXITCODE
        
        if ($exitCode -eq 0 -or $exitCode -eq $null) {
            Write-Host "  ✅ 実行成功: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "  ⚠️  Exit Code: $exitCode" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "  ❌ エラー: $_" -ForegroundColor Red
        return $false
    }
}

function Pause-IfInteractive {
    if (-not $FastMode) {
        Write-Host ""
        Write-Host "  ⏸️  続行するには Enter キーを押してください..." -ForegroundColor Cyan
        Read-Host | Out-Null
    }
}

# ========================================
# Phase 2: 音声生成
# ========================================
if ($SkipPhase2) {
    Write-Host "⏭️  Phase 2: 音声生成 (スキップ)" -ForegroundColor Gray
}
else {
    $phase2Script = Join-Path $scriptsDir "generate_voice.ps1"
    $phase2Success = Invoke-Phase "2" "音声生成（VOICEVOX）" $phase2Script
    
    if (-not $phase2Success) {
        $ErrorCount++
        Write-Host ""
        Write-Host "  ⛔ Phase 2 でエラーが発生しました" -ForegroundColor Red
        exit 1
    }
    
    $PhaseResults += @{ Phase = 2; Status = "Success" }
    Pause-IfInteractive
}

# ========================================
# Phase 2.5: 映像要素生成
# ========================================
if ($SkipPhase2) {
    Write-Host "⏭️  Phase 2.5: 映像要素生成 (スキップ)" -ForegroundColor Gray
}
else {
    $phase2_5Script = Join-Path $scriptsDir "generate_video_elements.ps1"
    $phase2_5Success = Invoke-Phase "2.5" "映像要素生成（レイアウト・背景・立ち絵）" $phase2_5Script
    
    if (-not $phase2_5Success) {
        Write-Host ""
        Write-Host "  ⚠️  Phase 2.5 でエラーが発生しました（継続します）" -ForegroundColor Yellow
    }
    
    $PhaseResults += @{ Phase = "2.5"; Status = "Complete" }
    Pause-IfInteractive
}

# ========================================
if ($SkipPhase3) {
    Write-Host "⏭️  Phase 3: Exo 生成 (スキップ)" -ForegroundColor Gray
}
else {
    $phase3Script = Join-Path $scriptsDir "generate_exo.ps1"
    $phase3Success = Invoke-Phase "3" "Exo ファイル生成" $phase3Script
    
    if (-not $phase3Success) {
        $ErrorCount++
        Write-Host ""
        Write-Host "  ⛔ Phase 3 でエラーが発生しました" -ForegroundColor Red
        exit 1
    }
    
    $PhaseResults += @{ Phase = 3; Status = "Success" }
    Pause-IfInteractive
}

# ========================================
# Phase 4: 動画エンコード
# ========================================
if ($SkipPhase4) {
    Write-Host "⏭️  Phase 4: 動画エンコード (スキップ)" -ForegroundColor Gray
}
else {
    $phase4Script = Join-Path $scriptsDir "aviutl_runner.ps1"
    $exoFile = Join-Path $projectRoot "project.exo"
    $configFile = Join-Path $projectRoot "output_config.json"
    
    $phase4Success = Invoke-Phase "4" "AviUtl CUI 動画エンコード" $phase4Script @(
        "-ExoFilePath", $exoFile,
        "-OutputFormat", "mp4",
        "-ConfigPath", $configFile
    )
    
    if (-not $phase4Success) {
        Write-Host ""
        Write-Host "  ⚠️  Phase 4 でエラーが発生しました" -ForegroundColor Yellow
        Write-Host "     ただし処理を継続します（AviUtl は手動で確認してください）" -ForegroundColor Gray
    }
    
    $PhaseResults += @{ Phase = 4; Status = "Complete" }
    Pause-IfInteractive
}

# ========================================
# 完了サマリー
# ========================================
Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " パイプライン実行完了" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

foreach ($result in $PhaseResults) {
    Write-Host "  Phase $($result.Phase): $($result.Status)" -ForegroundColor Green
}

Write-Host ""
Write-Host "  📁 出力先: $projectRoot\output\" -ForegroundColor Gray
Write-Host "     - voice/   : 音声ファイル (WAV)" -ForegroundColor Gray
Write-Host "     - exo/     : Exo ファイル" -ForegroundColor Gray
Write-Host "     - video/   : 動画ファイル (MP4/AVI)" -ForegroundColor Gray
Write-Host ""

if ($ErrorCount -eq 0) {
    Write-Host "  ✅ すべてのフェーズが正常に完了しました！" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "  ⚠️  $ErrorCount 件のエラーが発生しました" -ForegroundColor Yellow
    exit 1
}
