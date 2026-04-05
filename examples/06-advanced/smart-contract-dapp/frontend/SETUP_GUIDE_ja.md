# 🔧 VibeCoding Web3 フロントエンド - セットアップガイド [ID 015]

## セットアップ手順

このガイドに従うことで、**React + ethers.js** で構成された Web3 フロントエンドを起動し、Sepolia テストネット上・のスマートコントラクトと連携できます。

---

## ステップ 1: 前提条件

### Node.js と npm がインストール済みか確認

```bash
node --version    # v18.x.x 以上
npm --version     # 9.x.x 以上
```

### MetaMask ブラウザ拡張がインストール済みか確認

1. ブラウザ右上に MetaMask アイコンがあるか確認
2. なければ [metamask.io](https://metamask.io) からインストール

### Sepolia テストネットが MetaMask に追加済みか確認

1. MetaMask のネットワークドロップダウンをクリック
2. "Sepolia Testnet" が見えたら OK
3. 見えなければ [親ディレクトリの SETUP_GUIDE_ja.md](../SETUP_GUIDE_ja.md) でネットワーク追加

---

## ステップ 2: フロントエンド環境をセットアップ

### ディレクトリに移動

```bash
cd examples/06-advanced/smart-contract-dapp/frontend
```

### 依存パッケージをインストール

```bash
npm install
```

**予想される出力**:
```
added 350+ packages in 1-2m
...
✅ インストール完了
```

**インストール内容**:
- **react@18.2.0** - UI フレームワーク
- **react-dom@18.2.0** - DOM 操作
- **ethers@6.7.1** - Web3 ライブラリ
- **vite@4.5.14** - ビルド・開発サーバー
- **@vitejs/plugin-react** - React プラグイン

---

## ステップ 3: 環境変数を設定

### `.env` ファイルを作成

```bash
cp .env.example .env
```

### `.env` ファイルを編集

テキストエディタで `.env` を開き、以下の値を設定:

```
# Sepolia にデプロイされたコントラクトアドレス
VITE_TOKEN_ADDRESS=0xBbe8666fF3d416Ef9a27e842F3575F76636218ff

# Sepolia テストネットのチェーン ID
VITE_NETWORK_ID=11155111
```

**重要**: `VITE_TOKEN_ADDRESS` は自分がデプロイしたコントラクトアドレスに置き換えてください

---

## ステップ 4: 開発サーバーを起動

### サーバー起動コマンド

```bash
npm run dev
```

### 予想される出力

```
  VITE v4.5.14  ready in 572 ms

  ➜  Local:   http://localhost:3001/
  ➜  Network: use --host to expose
  ➜  press h to show help
```

✅ 開発サーバーが起動しました！

---

## ステップ 5: ブラウザで確認

### ブラウザを開く

```
http://localhost:3001/
```

またはブラウザで手動で上記 URL を入力

### 予想される画面

```
┌──────────────────────────────────────────────┐
│  🎯 Vibe Token Dashboard                      │
│  Web3 Frontend for ERC-20 Token Management    │
│                                              │
│  ┌──────────────────────────────────┐       │
│  │  ✅ Connected                     │       │
│  │  Wallet: 0xCE24...65bc38          │       │
│  └──────────────────────────────────┘       │
│                                              │
│  ┌──────────────────────────────────┐       │
│  │  💰 Token Balance                 │       │
│  │  1000000.00 VBC                   │       │
│  └──────────────────────────────────┘       │
│                                              │
│  ┌──────────────────────────────────┐       │
│  │  🔗 Network Information           │       │
│  │  Network: Sepolia Testnet         │       │
│  │  Chain ID: 11155111               │       │
│  │  Account: 0xCE24...65bc38         │       │
│  └──────────────────────────────────┘       │
└──────────────────────────────────────────────┘
```

---

## ステップ 6: MetaMask で接続

### ネットワークを "Sepolia" に切り替え

1. MetaMask を開く
2. 左上のネットワークドロップダウンをクリック
3. **"Sepolia Testnet"** を選択

### 「Connect Wallet」をクリック

1. ページの **"Connect Wallet"** ボタンをクリック
2. MetaMask ポップアップが表示される
3. **テストアカウント** を選択チェック ✅
4. **「Connect」** をクリック

### 署名を承認

1. MetaMask の **署名リクエスト** ダイアログが表示
2. **「署名」** をクリック

### 接続確認

以下が表示されれば成功 ✅:

```
✅ Connected: 0xCE241a60a23825059aA05F83FEF291CcaD65BC38
💰 Balance: 1,000,000 VBC
🔗 Network: Sepolia Testnet
🔗 Chain ID: 11155111
```

---

## ステップ 7: トークン転送をテスト（オプション）

### 転送フォームに入力

| フィールド | 入力例 |
|----------|--------|
| **送信先アドレス** | `0x0a9867cE69cC78b4c89cE1725Ed8fBc8da4E38C5` |
| **送信額** | `100` |

### 「Transfer」をクリック

1. **「Transfer」** ボタンをクリック
2. MetaMask トランザクション確認画面が表示
3. ガス代を確認（通常 0.00008 Sepolia ETH）
4. **「確認」** をクリック

### トランザクション完了

```
✅ Transaction successful!
   Hash: 0x3f4...abc
   💰 Updated Balance: 999,900 VBC
```

---

## 🔧 開発コマンド

### 開発サーバー起動

```bash
npm run dev
```

**用途**: アプリケーション開発時に使用
**ホットリロード**: ファイル保存で自動更新
**ポート**: `http://localhost:3001`

### ビルド（本番用）

```bash
npm run build
```

**用途**: 本番環境へのデプロイ用
**出力**: `dist/` ディレクトリに最適化されたファイルが生成

### ビルドを確認

```bash
npm run preview
```

**用途**: ビルド後の出力結果をローカルで確認
**ポート**: `http://localhost:4173` などで確認可能

---

## 📂 ディレクトリ構成

```
frontend/
├── src/
│   ├── components/          # React コンポーネント
│   │   ├── Dashboard.jsx
│   │   ├── TokenBalance.jsx
│   │   ├── TransferForm.jsx
│   │   ├── NetworkInfo.jsx
│   │   └── WalletConnect.jsx
│   │
│   ├── hooks/              # React カスタムフック
│   │   └── useWeb3.js      # ← Web3 ロジックの中核
│   │
│   ├── styles/             # CSS ファイル
│   │   ├── Dashboard.css
│   │   ├── TokenBalance.css
│   │   ├── TransferForm.css
│   │   ├── NetworkInfo.css
│   │   └── index.css
│   │
│   └── App.jsx             # メインコンポーネント
│
├── index.html              # HTML ルート
├── vite.config.js          # Vite 設定
├── package.json            # NPM 設定
├── .env                    # 環境変数 ⚠️ Git に含めない
├── .env.example            # テンプレート
├── README_ja.md            # 📖 プロジェクト概要（日本語）
└── SETUP_GUIDE_ja.md       # 📖 このファイル
```

---

## 🧩 コンポーネント の役割

### `useWeb3.js` フック（メイン）

Web3 ロジックすべてを担当:

```javascript
export function useWeb3() {
  // ① MetaMask 接続
  const connectWallet = async () => { ... }
  
  // ② 残高を取得
  const fetchBalance = async (provider, account) => { ... }
  
  // ③ トークンを転送
  const transferToken = async (recipient, amount) => { ... }
  
  // ④ 接続を切断
  const disconnectWallet = () => { ... }
  
  return { account, balance, connectWallet, transferToken, ... }
}
```

### `Dashboard.jsx` - メインコンポーネント

UI を組み立てる:
- `useWeb3()` から状態を取得
- `TokenBalance` で残高を表示
- `TransferForm` で転送フォームを表示
- `NetworkInfo` でネットワーク情報を表示

### `TransferForm.jsx` - 転送フォーム

ユーザー入力を受け付ける:
- 送信先アドレス入力
- 送信額入力
- 「Transfer」ボタンで `useWeb3.transferToken()` を実行

---

## 🐛 トラブルシューティング

### エラー 1: "Cannot find module 'ethers'"

**原因**: ethers がインストール されていない

**解決**:
```bash
npm install ethers@^6.7.1
npm run dev
```

### エラー 2: "VITE_TOKEN_ADDRESS is not defined"

**原因**: `.env` ファイルが見つからない、または空

**解決**:
```bash
cp .env.example .env
# .env を編集してコントラクトアドレスを設定
```

### エラー 3: トークン残高が "0.00 VBC"

**原因**: 以下のいずれか
1. MetaMask ネットワークが Sepolia ではない
2. MetaMask アカウントが デプロイアカウント ではない
3. コントラクトアドレスが無効

**解決**:
```bash
1. MetaMask ネットワーク → Sepolia に変更
2. [Connect Wallet] をクリックして接続あ直し
3. DevTools (F12) で以下を確認:
   console.log(import.meta.env.VITE_TOKEN_ADDRESS)
   // 0xBbe8666fF3d416Ef9a27e842F3575F76636218ff と表示されるか？
```

### エラー 4: ポート 3001 が既に使用されている

**原因**: 別プロセスがポート 3001 を使用している

**解決**:
```bash
# 別のポートで起動
npm run dev -- --port 3002

# または既存プロセスを終了
# Windows:
taskkill /F /IM node.exe
# macOS/Linux:
killall node
```

### エラー 5: "window.ethereum is undefined"

**原因**: MetaMask がインストール されていない

**解決**:
1. [metamask.io](https://metamask.io) から MetaMask をインストール
2. ブラウザを再起動
3. ページをリロード

### エラー 6: MetaMask 署名後に接続されない

**原因**: ネットワーク設定がズレている

**解決**:
```bash
1. MetaMask 右上 → Settings
2. Connected sites → localhost:3001 を削除
3. ページをリロード (F5)
4. 「Connect Wallet」を再度クリック
```

---

## ✅ セットアップ完了チェックリスト

- [ ] Node.js v18+ がインストール済み
- [ ] npm install が成功
- [ ] `.env` ファイルが設定済み
- [ ] MetaMask が Sepolia テストネット設定済み
- [ ] `npm run dev` で開発サーバーが起動
- [ ] `http://localhost:3001` でページが表示
- [ ] MetaMask 接続ボタンが動作
- [ ] トークン残高が表示される
- [ ] 転送フォームで入力可能

---

## 🔗 便利なリンク

### ドキュメント
| リンク | 説明 |
|-------|------|
| [ethers.js v6](https://docs.ethers.org/v6/) | Web3 ライブラリ |
| [React](https://react.dev/) | UI フレームワーク |
| [Vite](https://vitejs.dev/) | ビルドツール |
| [MetaMask](https://docs.metamask.io/) | ウォレット SDK |

### テスト ネットワーク
| リンク | 説明 |
|-------|------|
| [Sepolia Etherscan](https://sepolia.etherscan.io) | ブロック エクスプローラ |
| [Sepolia Faucet](https://www.alchemy.com/faucets/ethereum-sepolia) | テスト ETH 取得 |

---

## 📚 外部資料

| 題目 | リンク |
|-----|--------|
| ethers.js チュートリアル | https://docs.ethers.org/v6/getting-started/ |
| React 入門 | https://react.dev/learn |
| Vite ガイド | https://vitejs.dev/guide/ |
| MetaMask 統合 | https://docs.metamask.io/guide/create-dapp/ |

---

## 🎯 次のステップ

セットアップ完了後:

1. ✅ トークン転送でテスト
2. ✅ Etherscan でトランザクション確認
3. ✅ コンポーネントをカスタマイズ
4. ✅ 本番環境にデプロイ（`npm run build`）

---

## 📞 サポート

問題が発生した場合:

1. このガイドの **トラブルシューティング** を確認
2. [README_ja.md](README_ja.md) を確認
3. [親ディレクトリ TROUBLESHOOTING.md](../TROUBLESHOOTING.md) を確認
4. GitHub Issues を作成

---

**セットアップ完了！🎉**

```bash
$ npm run dev
  VITE v4.5.14  ready in 572 ms
  ➜  Local:   http://localhost:3001/
```

ブラウザで `http://localhost:3001/` にアクセスしてください！

---

**最終更新**: 2026年4月5日  
**言語**: 日本語  
**バージョン**: 1.0  
**ID**: 015 (Web3 フロントエンド統合)
