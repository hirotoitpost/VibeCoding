# Phase 5.5 E2E テスト実行ガイド

**セッション**: Session 26  
**Work ID**: 026  
**実行日**: 2026-04-13  
**ステータス**: 🔄 実行予定

---

## 📋 概要

VibeCoding 動画生成パイプライン（Phase 2～5.4）の完全統合テストです。

**目的**:
- ✅ Phase 2～5.4 全フェーズの正常動作確認
- ✅ トランジション効果（Phase 5.3-5.4）が実際に Exo に統合されるか確認
- ✅ 最終ビデオ出力（AviUtl レンダリング）が成功するか確認
- ✅ 完全な動画生成パイプラインの実用性検証

**テスト流程**:
```
Phase 2     → Phase 2.5 → Phase 2.6 → Phase 2.7 → Phase 2.8 → Phase 3 → Phase 4
Audio        Video elem  Layout      Transition  Effect cfg   Exo      Video
生成         生成        定義        配置        読込         生成     出力
```

---

## 🔍 環境チェック

### 前提条件

| 項目 | 要件 | 確認コマンド |
|------|------|-----------|
| **PowerShell** | 5.1+ | `$PSVersionTable.PSVersion` |
| **VOICEVOX** | 起動可能 | `curl http://localhost:50021/version` |
| **AviUtl** | CUI インターフェース対応 | `aviutl.exe /?` |
| **effect_config.json** | 存在 | `ls examples/07-advanced/aviutl_voicevox_pipeline/effect_config.json` |
| **generate_*.ps1** | すべて存在 | `ls examples/07-advanced/aviutl_voicevox_pipeline/scripts/` |

### クイックチェック

```powershell
# 1. VOICEVOX サーバー確認
curl http://localhost:50021/version
# 期待値: {"version":"x.x.x"}

# 2. AviUtl パス確認
Get-Command aviutl.exe -ErrorAction SilentlyContinue
# 期待値: C:\Program Files\AviUtl\aviutl.exe (インストール場所に依存)

# 3. effect_config.json 確認
$config = Get-Content "examples/07-advanced/aviutl_voicevox_pipeline/effect_config.json" | ConvertFrom-Json
$config.available_effects | Select-Object name, duration_ms
# 期待値: 5種類の effect が表示される (fade, dissolve, slide_left, slide_right, fade_through_color)
```

---

## 🚀 実行フロー

### ステップ 1: 入力シナリオ確認

```powershell
cd "examples/07-advanced/aviutl_voicevox_pipeline"

# デフォルトシナリオ確認
Get-ChildItem scenarios/ -Filter "*.json" | ForEach-Object {
    Write-Host "📄 $_"
    Get-Content $_.FullName | ConvertFrom-Json | Select-Object -Property narration, duration_sec | Format-Table
}
```

**期待値**: scenario_basic.json または他のシナリオが表示される

---

### ステップ 2: FastMode でパイプライン実行

```powershell
cd "examples/07-advanced/aviutl_voicevox_pipeline"

# 自動実行モード（InteractiveMode = False）
.\run_all.ps1 -FastMode $true
```

**実行時間**: 5-15 分（環境に依存）

**期待出力 (各 Phase)**:

#### Phase 2: 音声生成（VOICEVOX）
```
========================================
[ Phase 2 ] 音声生成（VOICEVOX）
========================================

🔄 実行開始: HH:mm:ss
✅ 実行成功: HH:mm:ss
```
**成功条件**:
- ✅ `output/audio_*.wav` ファイルが生成される
- ✅ Exit Code: 0

#### Phase 2.5: 映像要素生成
```
========================================
[ Phase 2.5 ] 映像要素生成（レイアウト・背景・立ち絵）
========================================

🔄 実行開始: HH:mm:ss
✅ 実行成功: HH:mm:ss
```
**成功条件**:
- ✅ `output/video_frames_*.png` が生成される
- ✅ Exit Code: 0 または警告

#### Phase 2.6: 動的レイアウト生成
```
========================================
[ Phase 2.6 ] 動的レイアウト生成（トランジション・タイミング）
========================================

🔄 実行開始: HH:mm:ss
✅ 実行成功: HH:mm:ss
```
**成功条件**:
- ✅ `output/video_layout_dynamics.json` が生成される
- ✅ segments に `selected_effect` フィールドが含まれている

#### Phase 2.7: トランジション効果統合チェック ⭐ （重要）
```
========================================
[ Phase 2.7 ] トランジション効果統合チェック
========================================

✅ effect_config.json が見つかりました
   生成される Exo ファイルに selected_effect が統合されます (Phase 5.4)
```
**成功条件**:
- ✅ `effect_config.json` が検出される
- ✅ ステータスメッセージが緑色表示される

#### Phase 3: Exo ファイル生成 ⭐ （最重要）
```
========================================
[ Phase 3 ] Exo ファイル生成 (Phase 5.4: トランジション効果統合)
========================================

🔄 実行開始: HH:mm:ss
✅ 実行成功: HH:mm:ss
```
**成功条件**:
- ✅ `project.exo` ファイルが生成される
- ✅ ファイル内に `<transition>` タグが存在する（Phase 5.4 効果）

**検証手順**:
```powershell
# Exo ファイル内の transition タグを確認
$exoContent = Get-Content "project.exo"
$transitionCount = ($exoContent | Select-String "<transition" -AllMatches).Matches.Count

Write-Host "検出されたトランジション効果: $transitionCount 個"
# 期待値: 3 個以上（セグメント境界に効果が配置)
```

#### Phase 4: 動画エンコード
```
========================================
[ Phase 4 ] 動画エンコード（AviUtl）
========================================

🔄 実行開始: HH:mm:ss
✅ 実行成功: HH:mm:ss
```
**成功条件**:
- ✅ `output/output_0*.mp4` ファイルが生成される
- ✅ ファイルサイズ > 1 MB
- ✅ 再生可能（MediaInfo で確認可能）

---

## ✅ 検証チェックリスト

### パイプライン全体

- [ ] **Phase 2**: `output/audio_*.wav` 生成 ✅
- [ ] **Phase 2.5**: `output/video_frames_*.png` 生成 ✅
- [ ] **Phase 2.6**: `output/video_layout_dynamics.json` 生成 + `selected_effect` フィールド存在 ✅
- [ ] **Phase 2.7**: `effect_config.json` 検出 ✅
- [ ] **Phase 3**: `project.exo` 生成 ✅
- [ ] **Phase 4**: `output/output_0*.mp4` 生成 ✅

### Phase 5.3-5.4 トランジション効果統合

- [ ] **Effect Config 統合**:
  ```powershell
  # effect_config.json が generate_exo.ps1 に読み込まれるか確認
  $exoContent = Get-Content "project.exo"
  
  # <transition> タグをカウント
  ($exoContent | Select-String "<transition" -AllMatches).Matches.Count
  # 期待値: 3以上
  ```

- [ ] **Transition タグ構造確認**:
  ```powershell
  # Exo ファイルから最初の transition タグを抽出
  $exoContent = Get-Content "project.exo"
  $transitionXml = $exoContent | Select-String "<transition.*?</transition>" -AllMatches | Select-Object -First 1
  Write-Host $transitionXml.Matches[0].Value
  
  # 期待値:
  # <transition type="fade" duration="300" easing="linear" intensity="100" />
  ```

- [ ] **Selected Effect 検証**:
  ```powershell
  # video_layout_dynamics.json の selected_effect を確認
  $layoutJson = Get-Content "output/video_layout_dynamics.json" | ConvertFrom-Json
  $layoutJson.segments | ForEach-Object {
      Write-Host "Segment $($_.segment_idx): selected_effect = $($_.selected_effect)"
  }
  
  # 期待値:
  # Segment 0: selected_effect = fade
  # Segment 1: selected_effect = dissolve
  # ...
  ```

### ビデオ品質確認

- [ ] **MP4 ファイル情報**:
  ```powershell
  # MediaInfo インストール環境
  & mediainfo "output/output_0.mp4"
  
  # または ffprobe
  ffprobe -v quiet -print_format json -show_format -show_streams "output/output_0.mp4"
  
  # 期待値:
  # Duration: 30+ seconds
  # Codec: H.264 (AVC)
  # Resolution: 1920x1080 (設定に依存)
  ```

- [ ] **トランジション効果が見える**（目視確認）:
  - VLC / Windows Media Player で再生
  - セグメント境界でフェード/ディゾルブが確認できるか

---

## 🐛 トラブルシューティング

### Phase 2 失敗: VOICEVOX 接続不可

**症状**:
```
❌ エラー: HTTP Error: 404
```

**原因**: VOICEVOX サーバーが起動していない

**解決**:
```powershell
# 1. VOICEVOX 起動確認
curl http://localhost:50021/version

# 2. 起動していない場合は起動
Start-Process "C:\Program Files\VOICEVOX\voicevox.exe"

# 3. 起動待機
Start-Sleep -Seconds 5

# 4. 再実行
.\run_all.ps1 -FastMode $true -SkipPhase2 $true  # 最初だけスキップ
```

---

### Phase 3 失敗: Exo 生成エラー

**症状**:
```
❌ エラー: Cannot parse video_layout_dynamics.json
```

**原因**: Phase 2.6 が失敗している、または JSON が正しくない

**解決**:
```powershell
# 1. video_layout_dynamics.json の確認
$json = Get-Content "output/video_layout_dynamics.json" | ConvertFrom-Json
$json | Format-List

# 2. JSON 構文チェック
Test-Json -Path "output/video_layout_dynamics.json"

# 3. Phase 2.6 を個別実行
.\scripts\generate_video_layout_dynamics.ps1

# 4. 再度 Phase 3 実行
.\scripts\generate_exo.ps1
```

---

### Phase 3文解: Exo に transition タグがない

**症状**:
```
Exo ファイルに <transition> タグがない
```

**原因**: effect_config.json が読み込まれていない

**解決**:
```powershell
# 1. effect_config.json の存在確認
Test-Path "effect_config.json"

# 2. effect_config.json の内容確認
Get-Content "effect_config.json" | ConvertFrom-Json

# 3. generate_exo.ps1 に EffectConfigPath を明示的に指定
.\scripts\generate_exo.ps1 -EffectConfigPath "./effect_config.json"

# 4. Exo ファイルを再生成
.\run_all.ps1 -FastMode $true -SkipPhase2 $true -SkipPhase2_5 $true
```

---

### Phase 4 失敗: AviUtl エラー

**症状**:
```
❌ エラー: aviutl.exe not found or failed
```

**原因**: AviUtl がインストールされていない

**解決**:
```powershell
# 1. AviUtl インストール状態確認
Get-Command aviutl.exe -ErrorAction SilentlyContinue

# 2. インストール済みの場合、パス確認
Where.exe aviutl.exe

# 3. インストール文件が見つかった場合、aviutl_runner.ps1 を確認
Get-Content "scripts/aviutl_runner.ps1" | Select-String "aviutl.exe" | Select-Object -First 3
```

---

## 📊 成功条件（統合判定）

**E2E テスト PASS 条件**：

| フェーズ | 成功条件 | 重要度 |
|---------|--------|------|
| Phase 2 | 音声ファイル生成 | 🔴 必須 |
| Phase 2.5 | 映像フレーム生成 | 🟡 推奨 |
| Phase 2.6 | Layout JSON + selected_effect | 🔴 必須 |
| Phase 2.7 | Effect Config 検出 | 🔴 必須 |
| Phase 3 | Exo ファイル + **<transition> タグ** | 🔴 必須 |
| Phase 4 | MP4 ファイル生成 | 🔴 必須 |

**PASS**: 🔴 すべての必須項目が成功 ✅  
**WARN**: 🟡 推奨項目に失敗（継続可能）  
**FAIL**: 🔴 必須項目に 1 つ以上失敗 ❌

---

## 📝 実行ログ記録

**推奨**: PowerShell スクリプト実行を Transcript で記録

```powershell
# ログ記録開始
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = "E2E_TEST_$timestamp.log"
Start-Transcript -Path $logFile -Append

# パイプライン実行
.\run_all.ps1 -FastMode $true

# ログ記録終了
Stop-Transcript

# ログ確認
Get-Content $logFile | Tail -50
```

---

## 🎯 次ステップ

1. **E2E テスト実行** → 検証チェックリスト確認
2. **Phase 5.5 テスト結果ドキュメント作成**
3. **PR #40 作成**: "ID 026: Phase 5.5 E2E テスト完成"
4. **SESSION_PROGRESS.md + WORK_ID_REGISTRY.md 更新**
5. **Session 27 / ID 027 計画** (Phase 6 新規プロジェクト)

---

**参考資料**:
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Phase 5.3-5.4 ガイド
- [run_all.ps1](run_all.ps1) - パイプラインスクリプト
- [generate_exo.ps1](scripts/generate_exo.ps1) - Exo 生成スクリプト
- [effect_config.json](effect_config.json) - トランジション効果定義
