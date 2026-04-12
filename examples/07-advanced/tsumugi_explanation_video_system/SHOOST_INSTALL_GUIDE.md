# Shoost インストール手順書 (For AI Agent & User)

## 1\. 概要

**Shoost** は、PSD形式の立ち絵をデスクトップ上に背景透過で表示し、マウスでの回転・反転・拡大縮小、および音声に連動したリップシンク（口パク）を可能にするアプリケーションです。

## 2\. 入手先と事前準備

AIエージェントは以下のURLをユーザーに提示し、ダウンロードを促すこと。

  * **配布元:** [Shoost (BOOTH)](https://booth.pm/ja/items/2832014)
      * ※無料版と支援版がありますが、基本機能は無料版で完結します。
  * **依存ランタイム:** \* [.NET Desktop Runtime 6.0 (x64)](https://dotnet.microsoft.com/download/dotnet/6.0) が必要です。

## 3\. インストール工程 (PowerShell推奨)

AIエージェントは、以下の手順を実行するスクリプト、またはユーザーへの指示を生成すること。

1.  **解凍先ディレクトリの決定**
      * ユーザーに `C:\Program Files\Shoost` のようなパスを指定させる。
2.  **ファイルの配置**
      * ダウンロードした `.zip` ファイルを PowerShell で展開する：
    ```powershell
    $zipPath = "C:\Users\YourName\Downloads\Shoost.zip"
    $extractPath = "C:\Program Files\Shoost"
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    ```
3.  **ブロック解除 (Unblock-File)**
      * Windowsのセキュリティ機能により実行がブロックされるのを防ぐため、以下のコマンドを実行する。
    ```powershell
    Get-ChildItem -Path "C:\Program Files\Shoost" -Recurse | Unblock-File
    ```

## 4\. 初期設定 (ユーザー手動作業)

インストール後、以下の手順で「春日部つむぎ」を召喚します。

1.  **Shoost.exe の起動**
2.  **立ち絵の読み込み**
      * 「春日部つむぎ」のPSDファイルをウィンドウ内にドラッグ＆ドロップする。
3.  **リップシンクの設定 (重要)**
      * 設定画面（歯車アイコン）\> `Audio` セクション。
      * `Input Device` に **VOICEVOXの音声が出力されるデバイス**（既定のスピーカーなど）を選択。
      * `Threshold` (しきい値) を調整し、音が鳴った時だけ口が動くように微調整する。
4.  **操作方法の確認**
      * `Alt + 左ドラッグ`: 移動
      * `Alt + 右ドラッグ`: 拡大縮小
      * `Alt + Shift + 左ドラッグ`: 回転
      * `Hキー`: 左右反転（Flip）

## 5\. 環境変数の追加

AIエージェントは、後続の自動起動スクリプトのために以下の環境変数を追加すること。

  * `SHOOST_PATH`: `C:\Path\To\Shoost` （setup_env.ps1 と統一）

-----

## 6. VB-Audio Virtual Cable（オプション）

リップシンクをより正確にするには、**仮想オーディオデバイス** を経由して VOICEVOX の音を Shoost に入力することをお薦めします。

1. **VB-Audio Virtual Cable の入手**
   * 入手先: [VB-Audio Virtual Cable](https://vb-audio.com/Cable/)
   * 無料版で完全に動作します。

2. **Shoost の設定**
   * Shoost の設定画面（歯車アイコン）> `Audio` セクション
   * `Input Device` に **"CABLE Output"** を選択
   * 「音声はここから Shoost に送られる」という設定になります。

---

## 💡 AIエージェントへの追加タスク依頼

**Task 1:** 上記手順に基づき、Shoostのインストールディレクトリをユーザーに問い合せ、環境変数を設定した上で、デスクトップに「Shoost起動用ショートカット」を作成する PowerShell スクリプトを生成してください。

**Task 2:** Shoost がインストール済みかをチェックするロジックを `setup_env.ps1` に追加してください。未インストール時は警告と入手先リンクを表示すること。
