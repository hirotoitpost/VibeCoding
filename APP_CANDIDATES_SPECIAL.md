# アプリケーション候補 - 特殊プロジェクト（ID 016-017）

> **参照**: [APP_CANDIDATES.md](APP_CANDIDATES.md), [APP_CANDIDATES_ADVANCED.md](APP_CANDIDATES_ADVANCED.md), [SESSION_PROGRESS.md](SESSION_PROGRESS.md#phase-33d-動画システム-s17-s20)

---

## 🎬 ID 016: 春日部つむぎ立ち絵解説動画システム

**フェーズ**: 3.3 拡張 / フェーズ 4 準備  
**難易度**: ⭐⭐⭐ (中級)  
**ステータス**: ✅ 完了 (Session 17)

### 概要

VibeCoding プロジェクトの 15 演習成果を、**春日部つむぎ**ボイロキャラが「喋りながら解説する動画」として制作するための統合 UI/UX・音声システム。

### 技術スタック

| コンポーネント | 役割 | 技術 |
|-------------|------|------|
| **VOICEVOX** | 音声合成エンジン | 春日部つむぎ (Speaker ID: 14) |
| **Shoost** | 立ち絵表示・リップシンク | デスクトップ透過・回転・反転制御 |
| **PowerShell** | 環境自動化 | セットアップ・テストスクリプト |
| **Windows Desktop** | ビジュアル基盤 | デスクトップアプリケーション統合 |

### 実装成果

- ✅ VOICEVOX API セットアップスクリプト
- ✅ 環境変数自動設定 (setup_env.ps1)
- ✅ Shoost 立ち絵セットアップ手順
- ✅ 音声連動リップシンク設定
- ✅ VibeCoding プロジェクト解説スクリプト集

---

## 🎞️ ID 017: AviUtl + PSDToolKit + VOICEVOX 動画自動生成システム

**フェーズ**: 3.3 拡張 / フェーズ 4 準備  
**難易度**: ⭐⭐⭐ (中級)  
**ステータス**: 🔄 実装中 (Session 18-20 + Phase 5 진행 중)

### 概要

**ID 016 の進化版**。Shoost が PSD ファイル非対応だったため、AviUtl + PSDToolKit + VOICEVOX を用いた**完全自動動画生成パイプライン**へ移行。

### 技術スタック

| コンポーネント | 役割 | 技術 |
|-------------|------|------|
| **AviUtl** | 動画編集・エンコード | スクリプト API・拡張プラグイン |
| **PSDToolKit** | PSD → 画像変換・立ち絵管理 | AviUtl プラグイン |
| **VOICEVOX** | 音声合成エンジン | 春日部つむぎ REST API (localhost:50021) |
| **PowerShell** | 統合制御・自動化 | パイプライン全体の制御スクリプト |

### 動画生成パイプライン

```
[入力]
  台本テキスト (.txt / .md)
       ↓
[1. 音声生成]
  VOICEVOX API → WAV ファイル
       ↓
[2. AviUtl + PSDToolKit]
  PSD 立ち絵 → 画像化
  音声 + 立ち絵 → タイムライン制御
  字幕 → オーバーレイ
       ↓
[3. エンコード出力]
  MP4 / WebM (YouTube 投稿用)
```

### 実装構成

| ファイル | 役割 | 行数 |
|---------|------|------|
| **generate_voice.ps1** | 台本 → 音声一括生成 | セッション 18 |
| **generate_exo.ps1** | Exo プロジェクト自動生成 | Session 27 (進行中) |
| **encode_video.ps1** | AviUtl エンコード実行 | Session 20 計画 |
| **run_all.ps1** | ワンコマンド全工程実行 | Session 21 計画 |

### 実装状況

| フェーズ | 内容 | ステータス | Session |
|---------|------|----------|--------|
| **Phase 5.1** | 音声生成完成 | ✅ | S18 |
| **Phase 5.2** | 映像要素生成 | ✅ | S22 |
| **Phase 5.3** | トランジション効果 | ✅ | S23-25 |
| **Phase 5.5.1** | PSDToolKit 分析 | ✅ | S26 |
| **Phase 5.5.2** | INI 形式 Exo 書き直し | 🔄 | S27 (進行中) |
| **Phase 5.6** | E2E 統合・最適化 | ⏳ | S28+ |

### Vibe Coding の学習ポイント

- ✅ Windows デスクトップアプリケーション統合
- ✅ VOICEVOX REST API + PowerShell 統合
- ✅ AviUtl Exo ファイルフォーマット生成
- ✅ パイプライン設計（テキスト → 音声 → 動画）
- ✅ 環境変数・ランタイム管理
- ✅ VibeCoding 全プロジェクトのナレッジシェア化

### 前提条件（環境）

- ✅ AviUtl インストール済み (`AVIUTL_ROOT=C:\AviUtl`)
- ✅ VOICEVOX インストール済み
- ✅ PSDToolKit プラグイン導入済み
- ✅ PowerShell 5.1+

### 参考ドキュメント

- [Session Progress - ID 017](SESSION_PROGRESS.md#phase-33d-動画システム-s17-s20)
- [examples/07-advanced/aviutl_voicevox_pipeline/README.md](examples/07-advanced/aviutl_voicevox_pipeline/README.md)

---

**最終更新**: 2026年4月13日 | **バージョン**: 1.0
