#Requires -Version 5.1
<#
.SYNOPSIS
    AviUtl Exo ファイル生成スクリプト（ID 017 Phase 3 → Phase 5.4 拡張版）

.DESCRIPTION
    voice/ ディレクトリの .wav ファイルをタイムラインに配置し、
    映像要素（背景、立ち絵、テロップ、字幕）を追加し、
    トランジション効果（Phase 5.3 effect_config）を適用した AviUtl 互換の Exo ファイルを生成する。

.PARAMETER OutputPath
    生成する Exo ファイルの出力パス（デフォルト: ./project.exo）

.PARAMETER LayoutConfigPath
    レイアウト設定 JSON ファイルのパス（デフォルト: ./video_layout.json）
    generate_video_elements.ps1 で生成されるファイル

.PARAMETER DynamicsLayoutPath
    動的レイアウト設定 JSON ファイルのパス（デフォルト: ./video_layout_dynamics.json）
    generate_video_layout_dynamics.ps1 で生成されるファイル (Phase 5.2)
    selected_effect フィールド含む (Phase 5.3)

.PARAMETER EffectConfigPath
    トランジション効果設定 JSON ファイルのパス（デフォルト: ../effect_config.json）
    effect_config.json で生成されるファイル (Phase 5.3)

.EXAMPLE
    .\generate_exo.ps1
    .\generate_exo.ps1 -OutputPath "./output/timeline.exo" -EffectConfigPath "../effect_config.json"

.NOTES
    - AVIUTL_ROOT, VOICEVOX_PORT が設定されている必要があります
    - voice/ ディレクトリ内の .wav ファイルを時間順に配置します
    - video_layout.json を使用して映像レイアウトを反映します (Phase 5.1)
    - video_layout_dynamics.json でセグメント情報とトランジション効果を反映します (Phase 5.2-5.3)
    - effect_config.json でトランジション効果定義を参照します (Phase 5.3)
#>

param(
    [string]$OutputPath = "./project.exo",
    [string]$LayoutConfigPath = "./video_layout.json",
    [string]$DynamicsLayoutPath = "./video_layout_dynamics.json",
    [string]$EffectConfigPath = "../effect_config.json"
)

# ========================================
# 環境セットアップ
# ========================================

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptRoot  # aviutl_voicevox_pipeline ディレクトリ
$voiceDir = Join-Path $projectRoot "output\voice"
$videoDir = Join-Path $projectRoot "output\video"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " AviUtl Exo ファイル生成 (Phase 5.4)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
Write-Host "実装: ID 025 Phase 5.4 - トランジション効果統合" -ForegroundColor Green
Write-Host "  ✅ Phase 5.1: 映像レイヤー (video_layout.json)" -ForegroundColor Gray
Write-Host "  ✅ Phase 5.2: 動的レイアウト (video_layout_dynamics.json)" -ForegroundColor Gray
Write-Host "  ✅ Phase 5.3: エフェクト定義 (effect_config.json)" -ForegroundColor Gray
Write-Host "  🆕 Phase 5.4: トランジション統合 (selected_effect → Exo)" -ForegroundColor Green
Write-Host ""

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
        $riff = $reader.ReadBytes(4) | ForEach-Object { [char]$_ } -Begin { $s = "" } { $s += $_ } -End { $s }
        $fileSize = $reader.ReadInt32()
        $wave = $reader.ReadBytes(4) | ForEach-Object { [char]$_ } -Begin { $s = "" } { $s += $_ } -End { $s }
        
        # fmt サブチャンク探索
        $fmt = $reader.ReadBytes(4) | ForEach-Object { [char]$_ } -Begin { $s = "" } { $s += $_ } -End { $s }
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
            File          = $wav.Name
            FullPath      = $wav.FullName
            Duration      = $durationSeconds
            Channels      = $channels
            SampleRate    = $sampleRate
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
# ステップ 2.5: レイアウト JSON 読込 (Phase 5.1)
# ========================================

Write-Host "`n[ 2.5/5 ] レイアウト設定読込 (Phase 5.1)..." -ForegroundColor Yellow

# LayoutConfig パスが相対パスの場合、projectRoot 基準に
if (-not [System.IO.Path]::IsPathRooted($LayoutConfigPath)) {
    $LayoutConfigPath = Join-Path $projectRoot $LayoutConfigPath
}

$layoutLayers = @()

if (Test-Path $LayoutConfigPath) {
    try {
        $layoutConfig = Get-Content $LayoutConfigPath | ConvertFrom-Json
        $layoutLayers = $layoutConfig.layers
        Write-Host "  ✅ レイアウト設定読込成功" -ForegroundColor Green
        Write-Host "     パターン: $($layoutConfig.pattern) - $($layoutConfig.description)" -ForegroundColor Cyan
        Write-Host "     総レイヤー数: $($layoutLayers.Count)" -ForegroundColor Cyan
    }
    catch {
        Write-Host "  ⚠️  レイアウト JSON 読込エラー: $_" -ForegroundColor Yellow
        Write-Host "     映像レイヤーなしで Exo を生成します" -ForegroundColor Gray
    }
}
else {
    Write-Host "  ⚠️  レイアウト JSON ファイルが見つかりません: $LayoutConfigPath" -ForegroundColor Yellow
    Write-Host "     generate_video_elements.ps1 を先に実行してください" -ForegroundColor Gray
}

# ========================================
# ステップ 2.7: 動的レイアウト JSON 読込 (Phase 5.2)
# ========================================

Write-Host "`n[ 2.7/5 ] 動的レイアウト読込 (Phase 5.2)..." -ForegroundColor Yellow

$dynamicLayout = $null
$segments = @()

# DynamicsLayoutPath が相対パスの場合、projectRoot 基準に
if (-not [System.IO.Path]::IsPathRooted($DynamicsLayoutPath)) {
    $DynamicsLayoutPath = Join-Path $projectRoot $DynamicsLayoutPath
}

if (Test-Path $DynamicsLayoutPath) {
    try {
        $dynamicLayout = Get-Content $DynamicsLayoutPath | ConvertFrom-Json
        $segments = $dynamicLayout.segments
        Write-Host "  ✅ 動的レイアウト読込成功" -ForegroundColor Green
        Write-Host "     総セグメント数: $($segments.Count)" -ForegroundColor Cyan
        Write-Host "     合計時間: $([System.Math]::Round($dynamicLayout.metadata.total_duration / 1000, 2))秒" -ForegroundColor Cyan
        
        # セグメント情報をログ出力
        foreach ($segment in $segments) {
            Write-Host "     Segment #$($segment.id): Speaker $($segment.speaker_name) ($($segment.duration)ms)" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "  ⚠️  動的レイアウト JSON 読込エラー: $_" -ForegroundColor Yellow
        Write-Host "     トランジション効果なしで Exo を生成します" -ForegroundColor Gray
    }
}
else {
    Write-Host "  ⚠️  動的レイアウト JSON ファイルが見つかりません: $DynamicsLayoutPath" -ForegroundColor Yellow
    Write-Host "     generate_video_layout_dynamics.ps1 を先に実行してください（オプション）" -ForegroundColor Gray
}

# ========================================
# ステップ 2.8: エフェクト設定読込 (Phase 5.4)
# ========================================

Write-Host "`n[ 2.8/5 ] エフェクト設定読込 (Phase 5.3 Effect Config)..." -ForegroundColor Yellow

$effectConfig = $null
$effectDefinitions = @{}

# EffectConfigPath が相対パスの場合、projectRoot 基準に
if (-not [System.IO.Path]::IsPathRooted($EffectConfigPath)) {
    $EffectConfigPath = Join-Path $projectRoot $EffectConfigPath
}

if (Test-Path $EffectConfigPath) {
    try {
        $effectConfig = Get-Content $EffectConfigPath | ConvertFrom-Json
        
        # 利用可能なエフェクト定義をマップ化
        if ($effectConfig.available_effects) {
            foreach ($effect in $effectConfig.available_effects) {
                $effectDefinitions[$effect.name] = $effect
            }
        }
        
        Write-Host "  ✅ エフェクト設定読込成功" -ForegroundColor Green
        Write-Host "     利用可能エフェクト: $($effectDefinitions.Keys.Count) 種類" -ForegroundColor Cyan
        foreach ($effectName in $effectDefinitions.Keys) {
            $effect = $effectDefinitions[$effectName]
            Write-Host "     - $effectName : $($effect.duration_ms)ms, $($effect.easing)" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  ⚠️  エフェクト設定読込エラー: $_" -ForegroundColor Yellow
        Write-Host "     デフォルトトランジション（フェード）で処理します" -ForegroundColor Gray
    }
}
else {
    Write-Host "  ⚠️  エフェクト設定ファイルが見つかりません: $EffectConfigPath" -ForegroundColor Yellow
    Write-Host "     generate_video_layout_dynamics.ps1 (Phase 5.3) を先に実行してください（推奨）" -ForegroundColor Gray
}


Write-Host "`n[ 3/5 ] Exo ファイル生成..." -ForegroundColor Yellow

# ========================================
# ユーティリティ関数: トランジション変換 (Phase 5.4)
# ========================================

function Get-AviUtlTransitionCommand {
    <#
    .SYNOPSIS
        Phase 5.3 selected_effect → AviUtl トランジションコマンド変換
    
    .PARAMETER SelectedEffect
        selected_effect オブジェクト { name, duration_ms, easing, ... }
    
    .PARAMETER EffectDefinitions
        effect_config.json から読み込んだエフェクト定義マップ
    
    .OUTPUT
        AviUtl互換の<transition>タグ内容
    #>
    param(
        [PSObject]$SelectedEffect,
        [hashtable]$EffectDefinitions
    )
    
    if (-not $SelectedEffect) {
        # デフォルト: フェード（300ms）
        return @{
            type      = "fade"
            duration  = 300
            intensity = 100
        }
    }
    
    $effectName = $SelectedEffect.name
    $duration = $SelectedEffect.duration_ms
    
    # エフェクト定義に基づいて AviUtl コマンド生成
    if ($EffectDefinitions.ContainsKey($effectName)) {
        $effectDef = $EffectDefinitions[$effectName]
        
        # AviUtl エフェクト名マッピング
        $aviutlName = switch ($effectName) {
            "fade" { "フェード" }
            "dissolve" { "ディゾルブ" }
            "slide_left" { "スライド" }
            "slide_right" { "スライド" }
            "fade_through_color" { "色を通して フェード" }
            default { "フェード" }
        }
        
        # スライド効果の方向設定
        $params = @{}
        if ($effectName -like "slide_*") {
            $direction = if ($effectName -eq "slide_left") { 90 } else { 270 }
            $params["direction"] = $direction
        }
        
        return @{
            type      = $aviutlName
            duration  = $duration
            easing    = $effectDef.easing
            intensity = 100
            params    = $params
        }
    }
    else {
        # デフォルト: フェード
        return @{
            type      = "フェード"
            duration  = $duration
            intensity = 100
        }
    }
}

function Format-TransitionXml {
    <#
    .SYNOPSIS
        トランジション情報を Exo XML フォーマットに変換
    
    .PARAMETER Transition
        トランジション情報オブジェクト
    
    .PARAMETER StartFrame
        トランジション開始フレーム
    #>
    param(
        [PSObject]$Transition,
        [int]$StartFrame
    )
    
    if (-not $Transition) { return "" }
    
    $xml = "        <!-- Transition: $($Transition.type) ($($Transition.duration)ms) -->`n" +
    "        <transition`n" +
    "          type=`"$($Transition.type)`"`n" +
    "          frame=`"$StartFrame`"`n" +
    "          duration=`"$($Transition.duration)`"`n" +
    "          intensity=`"$($Transition.intensity)`"`n"
    
    if ($Transition.easing) {
        $xml += "          easing=`"$($Transition.easing)`"`n"
    }
    
    $xml += "        />`n"
    
    return $xml
}



# デフォルト設定（1920x1080, 30fps）
$width = 1920
$height = 1080
$videoRate = 30
$audioRate = 44100

# フレーム数計算
$totalFrames = [int]($totalDuration * $videoRate)

# ========================================
# セグメント処理と トランジション情報構築 (Phase 5.4)
# ========================================

Write-Host "  📊 セグメント情報処理中..." -ForegroundColor Cyan

$segmentTransitions = @()  # トランジション情報リスト

if ($segments.Count -gt 1) {
    for ($i = 0; $i -lt $segments.Count - 1; $i++) {
        $currentSeg = $segments[$i]
        $nextSeg = $segments[$i + 1]
        
        $transitionStartTime = ($currentSeg.start + $currentSeg.duration) / 1000  # ミリ秒を秒に変換
        $transitionStartFrame = [int]($transitionStartTime * $videoRate)
        
        # selected_effect を取得
        $selectedEffect = if ($currentSeg.selected_effect) { $currentSeg.selected_effect } else { $null }
        
        # トランジション情報生成
        $transition = Get-AviUtlTransitionCommand -SelectedEffect $selectedEffect -EffectDefinitions $effectDefinitions
        
        $segmentTransitions += @{
            segment_from = $currentSeg.id
            segment_to   = $nextSeg.id
            start_frame  = $transitionStartFrame
            transition   = $transition
            effect_name  = if ($selectedEffect) { $selectedEffect.name } else { "default_fade" }
        }
        
        Write-Host "    ✅ Transition $($currentSeg.id)→$($nextSeg.id): $($transition.type) @ frame $transitionStartFrame" -ForegroundColor Green
    }
}
else {
    Write-Host "    ℹ️  セグメント1個のみ: トランジションなし" -ForegroundColor Gray
}

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
    <!-- Phase 5.4 実装: トランジション効果統合 -->
    <!-- セグメント間トランジション定義 -->
"@

# ========================================
# 映像レイヤー追加 (Phase 5.1)
# ========================================

if ($layoutLayers.Count -gt 0) {
    Write-Host "  📊 映像レイヤー追加中..." -ForegroundColor Cyan
    
    foreach ($layer in $layoutLayers) {
        switch ($layer.type) {
            "color_gradient" {
                # 背景レイヤー（グラデーション）
                $exoContent += @"

    <!-- Layer $($layer.layer): $($layer.name) (背景) -->
    <object
      index="$($layer.layer)"
      name="$($layer.name)"
      type="color_gradient"
      colorTop="$($layer.color_top)"
      colorBottom="$($layer.color_bottom)"
      x="$($layer.x)"
      y="$($layer.y)"
      width="$($layer.width)"
      height="$($layer.height)"
      alpha="$($layer.alpha)"
      start="0"
      end="$totalFrames"
      locked="$($layer.locked)"
    />
"@
                Write-Host "    ✅ Layer $($layer.layer): $($layer.name) (グラデーション背景)" -ForegroundColor Green
            }
            "psd_image" {
                # PSD 立ち絵レイヤー (PSDToolKit XML/Lua フォーマット)
                if (-not [string]::IsNullOrEmpty($layer.psdFile)) {
                    $psdPath = $layer.psdFile
                    
                    # 相対パスの場合、プロジェクトルートをベースに完全パスに変換
                    if (-not [System.IO.Path]::IsPathRooted($psdPath)) {
                        # 相対パスを正規化（スラッシュをバックスラッシュに）
                        $psdPath = $psdPath -replace '/', '\'
                        # プロジェクトルートと結合
                        $psdPath = "$projectRoot\$psdPath"
                    }
                    
                    # パス正規化: 重複したセパレータを削除
                    while ($psdPath -match '\\\\') {
                        $psdPath = $psdPath -replace '\\\\', '\'
                    }
                    $psdPath = $psdPath -replace '\\\.\\', '\'
                    $psdPath = $psdPath -replace '\.\\', '\'
                    
                    if (Test-Path $psdPath) {
                        # PSDToolKit 用に Windows パスをエスケープ（\\ に変換）
                        $psdPathEscaped = $psdPath -replace '\\', '\\'
                        $psdFilename = Split-Path -Leaf $psdPath
                        
                        # XML/Lua ハイブリッド形式で生成（PSDToolKit 公式パターン）
                        $exoContent += @"

    <!-- Layer $($layer.layer): $($layer.name) (PSD 立ち絵 - $($layer.characterName)) -->
    <!-- PSDToolKit XML/Lua フォーマット Integration (Phase 5.5.1) -->
`<?-- $psdFilename
o={
  lipsync=2,
  ptkf=`"$psdPathEscaped`",
  ptkl=`"L.0 V._BAAaYw`"
}PSD,subobj=require(`"PSDToolKit`").PSDState.init(obj,o)?>
"@
                        Write-Host "    ✅ Layer $($layer.layer): $($layer.name) ($($layer.characterName)) [PSDToolKit XML/Lua]" -ForegroundColor Green
                        Write-Host "       PSD Path: $psdPath" -ForegroundColor Gray
                    }
                    else {
                        Write-Host "    ⚠️  PSD ファイルが見つかりません: $psdPath" -ForegroundColor Yellow
                    }
                }
            }
            "text_box" {
                # テキストレイヤー
                $exoContent += @"

    <!-- Layer $($layer.layer): $($layer.name) (テキスト) -->
    <object
      index="$($layer.layer)"
      name="$($layer.name)"
      type="text"
      text=""
      x="$($layer.x)"
      y="$($layer.y)"
      width="$($layer.width)"
      height="$($layer.height)"
      fontSize="$($layer.text_config.fontSize)"
      fontFamily="$($layer.text_config.fontFamily)"
      fontColor="$($layer.text_config.fontColor)"
      fontBold="$($layer.text_config.fontBold)"
      alignment="$($layer.text_config.alignment)"
      backgroundColor="$($layer.backgroundColor)"
      borderColor="$($layer.borderColor)"
      borderWidth="$($layer.borderWidth)"
      start="0"
      end="$totalFrames"
      locked="$($layer.locked)"
    />
"@
                Write-Host "    ✅ Layer $($layer.layer): $($layer.name) (テキスト)" -ForegroundColor Green
            }
        }
    }
}

# ========================================
# トランジション情報追加 (Phase 5.4)
# ========================================

Write-Host "  📊 トランジション情報追加中..." -ForegroundColor Cyan

if ($segmentTransitions.Count -gt 0) {
    $exoContent += "`n"
    $exoContent += "    <!-- Transitions (Phase 5.4: selected_effect 統合) -->`n"
    
    foreach ($trans in $segmentTransitions) {
        $transXml = Format-TransitionXml -Transition $trans.transition -StartFrame $trans.start_frame
        $exoContent += $transXml
        Write-Host "    ✅ Transition XML 追加: $($trans.effect_name) @ frame $($trans.start_frame)" -ForegroundColor Green
    }
}
else {
    Write-Host "    ℹ️  トランジション情報なし（セグメント1個 or selected_effect 未設定）" -ForegroundColor Gray
}

# ========================================
# 音声トラック追加
# ========================================

Write-Host "  📊 音声トラック追加中..." -ForegroundColor Cyan

$trackId = $layoutLayers.Count
$currentFrame = 0

foreach ($audio in $audioMetadata) {
    $startFrame = [int]($audio.TimelineStart * $videoRate)
    $endFrame = [int](($audio.TimelineStart + $audio.Duration) * $videoRate)
    $duration = $endFrame - $startFrame
    
    $exoContent += @"

    <!-- Audio Track: $($audio.File) -->
    <object
      index="$trackId"
      name="$($audio.File)"
      src="$($audio.FullPath)"
      start="$startFrame"
      end="$endFrame"
      layer="$($layoutLayers.Count)"
      time="0"
      x="0"
      y="0"
      scale_x="1"
      scale_y="1"
      alpha="255"
      rotate="0"
    />
"@
    Write-Host "    ✅ 音声: $($audio.File) (${startFrame}f - ${endFrame}f)" -ForegroundColor Green
    
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
# ステップ 5: 確認
# ========================================

Write-Host "`n[ 5/5 ] 出力確認..." -ForegroundColor Yellow

if (Test-Path $OutputPath) {
    $fileSize = (Get-Item $OutputPath).Length
    Write-Host "  ✅ ファイルサイズ: $fileSize bytes" -ForegroundColor Green
    Write-Host "  📄 プロジェクト設定:" -ForegroundColor Cyan
    Write-Host "     - 解像度: ${width}x${height}" -ForegroundColor Gray
    Write-Host "     - フレームレート: ${videoRate} fps" -ForegroundColor Gray
    Write-Host "     - 長さ: $totalFrames フレーム (${totalDuration}s)" -ForegroundColor Gray
    Write-Host "     - 音声レート: $audioRate Hz" -ForegroundColor Gray
    Write-Host "  🎨 映像レイヤー: $($layoutLayers.Count) レイヤー" -ForegroundColor Gray
    foreach ($layer in $layoutLayers) {
        Write-Host "     - Layer $($layer.layer): $($layer.name)" -ForegroundColor Gray
    }
    Write-Host "`n  🎉 Exo ファイル生成成功！" -ForegroundColor Green
    Write-Host "     AviUtl で 'ファイル → 開く' で $OutputPath を選択してください" -ForegroundColor Cyan
}
else {
    Write-Host "  ❌ Exo ファイル生成失敗" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " 実行完了 (Phase 5.4: トランジション効果統合)===================================`n" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
