# ゆかりねっとコネクターNEO インストール手順書 (For AI Agent & User)

## 1\. 概要

**ゆかりねっとコネクターNEO** は、音声認識（Google/OpenAI Whisper等）を利用して、マイク音声をリアルタイムでテキスト化し、VOICEVOX（春日部つむぎ）に送信して喋らせるためのハブ・アプリケーションです。

## 2\. 入手先と事前準備

AIエージェントは以下のURLをユーザーに提示し、最新版のダウンロードを促すこと。

  * **公式サイト:** [ゆかりねっとコネクターNEO ダウンロードページ](https://www.google.com/search?q=https://v-tsunagarugenba.com/download/)
      * ※「インストーラー版」または「ZIP版」がありますが、管理のしやすさから「ZIP版」を推奨します。
  * **依存関係:** \* [.NET 6.0 Desktop Runtime](https://dotnet.microsoft.com/download/dotnet/6.0) (Shoostと共通)
      * インターネット接続（音声認識APIの利用に必要）

## 3\. インストール工程 (PowerShell推奨)

AIエージェントは、以下の手順を実行するスクリプト、またはユーザーへの指示を生成すること。

1.  **解凍先ディレクトリの決定**
      * `C:\Program Files\YukariNetConnectorNEO` 等に展開。
2.  **セキュリティブロックの解除**
    ```powershell
    Get-ChildItem -Path "C:\Program Files\YukariNetConnectorNEO" -Recurse | Unblock-File
    ```
3.  **環境変数の登録**
      * `YUKARINETTO_PATH`: `C:\Program Files\YukariNetConnectorNEO` （`setup_env.ps1` と統一）

## 4\. 初期設定（ユーザー手動作業：春日部つむぎ連携）

起動後、以下のステップで「春日部つむぎ」と連動させます。

1.  **音声認識エンジンを選択:**
      * `音声認識` タブから「Google Chrome拡張」や「OpenAI Whisper」などを選択（精度重視ならWhisperがおすすめ）。
2.  **読み上げエンジン（TTS）の設定:**
      * `音声合成(TTS)` タブで **「VOICEVOX」** を選択。
      * 接続テストを行い、キャラクター一覧から **「春日部つむぎ」** を指定。
3.  **字幕出力（オプション）:**
      * デスクトップ上に字幕を出したい場合は「オーバーレイ」設定を有効にする。

## 5\. 運用上のポイント

  * **VOICEVOXを先に起動しておく:** ゆかりねっとコネクターNEOがVOICEVOXサーバーを見つけられるようにします。
  * **オーディオデバイスの確認:** マイク入力が正しく認識されているか、設定画面のレベルメーターで確認してください。

-----

## 💡 AIエージェントへの追加タスク依頼

**Task 1:** ユーザーにインストールディレクトリを確認し、`YUKARINETTO_PATH` を環境変数にセットしてください。

**Task 2:** `VOICEVOX.exe` → `Shoost.exe` → `YukariNetConnectorNEO.exe` の順番で、適切なディレイを挟みながら一括起動する PowerShell スクリプト（`start_all_tsumugi.ps1`）を作成してください。各ツールが完全に起動するまでの待機時間を実装すること。
