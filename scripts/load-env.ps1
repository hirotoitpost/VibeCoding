# VibeCoding .env ファイル読み込みスクリプト
# 用途: VS Code 統合ターミナル起動時に .env ファイルから環境変数を読み込む

param(
    [string]$EnvFilePath = ".env"
)

# ワークスペースルート確認
$WorkspaceRoot = if ($PSScriptRoot) { Split-Path -Parent $PSScriptRoot } else { Get-Location }
$FullEnvPath = Join-Path $WorkspaceRoot $EnvFilePath

# .env ファイルの存在確認
if (-not (Test-Path $FullEnvPath)) {
    Write-Host "⚠️  .env ファイルが見つかりません: $FullEnvPath" -ForegroundColor Yellow
    return
}

# .env ファイルを読み込んで環境変数をセット
try {
    $EnvContent = Get-Content -Path $FullEnvPath -ErrorAction Stop
    $Count = 0

    foreach ($line in $EnvContent) {
        # コメント行と空行をスキップ
        $trimmedLine = $line.Trim()
        if ($trimmedLine.StartsWith('#') -or [string]::IsNullOrWhiteSpace($trimmedLine)) {
            continue
        }

        # KEY=VALUE 形式をパース
        if ($trimmedLine -match '^([^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()

            # ダブルクォートとシングルクォートを削除（先頭と末尾）
            if ($value.StartsWith('"') -and $value.EndsWith('"')) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            elseif ($value.StartsWith("'") -and $value.EndsWith("'")) {
                $value = $value.Substring(1, $value.Length - 2)
            }

            # 環境変数をセット（プロセススコープ）
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
            $Count++
            Write-Host "✅ セット: $key = $value" -ForegroundColor Green
        }
    }

    if ($Count -gt 0) {
        Write-Host "📋 .env ファイルを読み込みました ($Count 個の環境変数)" -ForegroundColor Cyan
    }
    else {
        Write-Host "⚠️  設定可能な環境変数がありません" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "❌ エラー: .env ファイルの読み込みに失敗しました`n$($_.Exception.Message)" -ForegroundColor Red
}

