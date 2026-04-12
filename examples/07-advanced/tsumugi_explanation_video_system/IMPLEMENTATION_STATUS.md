# Tsumugi Explanation Video System - 実装ステータス

## ⚠️ 現在のステータス: DEPRECATED (廃止)

このプロジェクトは、以下の理由により **非推奨（Deprecated）** となりました。

### 廃止理由

1. **PSD ファイル非対応**
   - 当初、Shoost で PSD 形式の立ち絵を読み込める想定でしたが、**Shoost は PDF ファイル非対応**でした
   - PSD ファイルの処理ができないため、本来の目的が達成できません

2. **代替案の検討**
   - AviUtl + PSDToolKit + VOICEVOX による動画制作パイプラインへの移行を予定しています

---

## 📚 参考情報

本プロジェクトで実施した調査・検証内容は以下のドキュメントで参照可能です。
これらは今後のプロジェクト実装の参考資料となります。

- [SHOOST_INSTALL_GUIDE.md](./SHOOST_INSTALL_GUIDE.md) - Shoost インストール手順（参考資料）
- [YUKARINET_NEO_INSTALL_GUIDE.md](./YUKARINET_NEO_INSTALL_GUIDE.md) - ゆかりねっと CoネクターNEO インストール手順（参考資料）

---

## 🔄 後続プロジェクト

### ID 017: AviUtl + PSDToolKit + VOICEVOX 統合

**目途**: フェーズ 3.3.C - 動画自動生成システム

**概要**:
- AviUtl のスクリプト制御で自動動画編集
- PSDToolKit で PSD を画像に変換
- VOICEVOX で音声生成
- PowerShell で全体を統合制御

**パイプライン**:
```
PSD → PSDToolKit (画像変換)
         ↓
AviUtl (編集・エンコード) ← VOICEVOX (音声)
         ↓
MP4 / WebM (出力動画)
```

詳細は [APP_CANDIDATES.md](../../APP_CANDIDATES.md#フェーズ33-追加プロジェクト候補) を参照してください。

---

## 📌 その他の参考資料

- VOICEVOX: https://voicevox.hiroshiba.jp/
- PSDToolKit: https://www.assetstore.unity.com/packages/tools/input-management/psd-toolkit-162048
- AviUtl: https://spring-fragrance.mints.ne.jp/

---

**最終更新**: 2026年4月12日
