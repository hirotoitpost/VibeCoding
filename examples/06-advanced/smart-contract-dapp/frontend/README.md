# 🎯 Vibe Token - Web3 Frontend

**ID 015A: Web3 フロントエンド統合**

React + ethers.js による ERC-20 トークン（VibeCodingToken）用の Web3 ダッシュボードです。MetaMask との統合により、ウォレット接続とトークン転送をシンプルに実現します。

---

## ✨ 機能

- 🔗 **MetaMask ウォレット連携**
  - ワンクリック接続
  - アドレス・チェーン情報表示
  - リアルタイム同期

- 💰 **トークン管理**
  - VBC 残高表示（5秒自動更新）
  - トークン転送フォーム
  - トランザクション追跡

- 🌐 **マルチネットワーク対応**
  - ✅ Hardhat Local（ローカル開発）
  - ✅ Sepolia Testnet
  - ✅ Ethereum Mainnet（将来対応）

- 🎨 **モダンUI**
  - Vite + React 18
  - レスポンシブデザイン
  - ダークテーマ

---

## 🚀 クイックスタート

### 前提条件
- **Node.js** >=16
- **npm** >=8
- **MetaMask** ブラウザ拡張機能

### インストール

```bash
cd frontend
npm install
```

### 開発サーバー起動

```bash
npm run dev
```

ブラウザで `http://localhost:3000` を開きます。

### ビルド

```bash
npm run build
npm run preview
```

---

## 🔧 セットアップ

### 1. 環境変数設定

`.env.example` をコピーしてカスタマイズ：

```bash
cp .env.example .env
```

**`.env` 内容:**

| 変数 | 説明 | デフォルト |
|-----|------|----------|
| `VITE_TOKEN_ADDRESS` | VibeCodingToken コントラクトアドレス | `0x5FbDB...` |
| `VITE_NETWORK_ID` | ネットワーク ID (31337=Hardhat, 11155111=Sepolia) | `31337` |

### 2. MetaMask 設定

**Hardhat ローカルの場合:**

```bash
# Hardhat node 起動（別ターミナル）
npx hardhat node

# MetaMask に Hardhat ネットワーク追加
# Network Name: Hardhat
# RPC URL: http://127.0.0.1:8545
# Chain ID: 31337
```

**Sepolia Testnet の場合:**

1. MetaMask で Sepolia を選択
2. `.env` のアドレスをコントラクトアドレスに更新
3. テストネット ETH を[フォーセット](https://sepoliafaucet.com)から取得

### 3. トークンコントラクト取得

#### ローカル Hardhat:
```bash
# smart-contract-dapp ディレクトリで
cd ../
npx hardhat run scripts/deploy.ts --network hardhat

# 得たアドレスを .env に設定
```

#### Sepolia Testnet:
```bash
# PRIVATE_KEY を設定してから
npx hardhat run scripts/deploy.ts --network sepolia
```

---

## 📱 使用方法

### 1. ウォレット接続

- **「Connect Wallet」** ボタンをクリック
- MetaMask ポップアップで確認

### 2. 残高確認

- 接続後、トークン残高が自動表示
- 5秒ごとに自動更新

### 3. トークン転送

1. 受信者アドレスを入力（`0x...` 形式）
2. 金額を入力
3. **「Send Tokens」** クリック
4. MetaMask で確認・署名

---

## 📁 ファイル構造

```
frontend/
├── src/
│   ├── components/
│   │   ├── WalletConnect.jsx      # ウォレット接続UI
│   │   ├── TokenInfo.jsx          # 残高・ネットワーク情報
│   │   └── TransferForm.jsx       # トークン転送フォーム
│   │
│   ├── hooks/
│   │   └── useWeb3.js             # Web3 ロジック・状態管理
│   │
│   ├── styles/
│   │   ├── WalletConnect.css
│   │   ├── TokenInfo.css
│   │   └── TransferForm.css
│   │
│   ├── App.jsx                    # メインコンポーネント
│   ├── App.css                    # グローバルスタイル
│   ├── main.jsx                   # エントリーポイント
│   └── index.css                  # ベーススタイル
│
├── index.html                     # HTML テンプレート
├── vite.config.js                 # Vite 設定
├── package.json                   # 依存関係
├── .env.example                   # 環境変数テンプレート
└── README.md                      # このファイル
```

---

## 🔌 Web3 統合詳細

### useWeb3 フック

カスタムフック `useWeb3.js` が以下を提供：

```javascript
const {
  account,           // 接続アカウント
  balance,           // トークン残高
  tokenSymbol,       // トークンシンボル (VBC)
  chainId,           // チェーン ID
  loading,           // 読み込み状態
  error,             // エラーメッセージ
  connectWallet,     // ウォレット接続函数
  transferToken,     // トークン転送函数
  fetchBalance,      // 残高再取得函数
} = useWeb3();
```

### ERC-20 ABI

以下の標準関数を使用：

```solidity
balanceOf(address owner)
transfer(address to, uint256 amount)
approve(address spender, uint256 amount)
allowance(address owner, address spender)
name()
symbol()
decimals()
```

---

## 🧪 テスト・検証

### ローカル Hardhat テスト

```bash
# Terminal 1: Hardhat node
npx hardhat node

# Terminal 2: ID 014 デプロイ
cd ../
npx hardhat run scripts/deploy.ts --network hardhat

# Terminal 3: フロントエンド起動
cd frontend
npm run dev

# ブラウザで http://localhost:3000 開く
```

### Sepolia Testnet テスト

```bash
# 1. コントラクトをデプロイ
npx hardhat run scripts/deploy.ts --network sepolia

# 2. .env を更新
VITE_TOKEN_ADDRESS=<デプロイアドレス>
VITE_NETWORK_ID=11155111

# 3. フロントエンド起動
npm run dev

# 4. MetaMask で Sepolia 選択
```

---

## 🐛 トラブルシューティング

### MetaMask 接続失敗

**症状:** "MetaMask not installed"

**解決:**
1. MetaMask 拡張機能をインストール
2. ブラウザ再起動
3. localhost でのみテスト

### コントラクト読み込み失敗

**症状:** "Failed to fetch balance"

**解決:**
1. `.env` のコントラクトアドレスを確認
2. アドレスが現在のネットワークにデプロイされているか確認
3. ネットワーク ID を確認

### トランザクション失敗

**症状:** "Transaction reverted"

**解決:**
1. ウォレット残高を確認
2. ガス代が十分か確認（Sepolia は無料）
3. トークンコントラクトで残高があるか確認

### スタイルが表示されない

**症状:** UI が崩れている

**解決:**
```bash
rm -rf node_modules
npm install
npm run dev
```

---

## 📚 参考資料

- **ethers.js ドキュメント**: https://docs.ethers.org
- **MetaMask**: https://metamask.io
- **Sepolia Faucet**: https://sepoliafaucet.com
- **OpenZeppelin ERC-20**: https://docs.openzeppelin.com/contracts/4.x/erc20

---

## 📊 Vibe Coding での学習ポイント

✅ **Web3.js ライブラリ統合**
- ethers.js v6 API
- ブラウザプロバイダー（MetaMask）
- コントラクト ABI の活用

✅ **React Hooks**
- useEffect での MetaMask イベント監視
- カスタムフックで複雑な状態管理
- 計算値のメモ化

✅ **スマートコントラクト連携**
- ERC-20 標準の理解
- トランザクション署名・検証
- ガス価格見積もり

✅ **UI/UX**
- モダン CSS グラデーション
- レスポンシブデザイン
- ローディング・エラー処理

---

## ✅ Status

**Phase**: 3.3.A Web3 Frontend Integration
**Status**: ✅ **実装完了・ローカルテスト待機中**
**Test Status**: Awaiting user verification

---

## 📄 License

MIT License - See [LICENSE](../../LICENSE)

---

**Built with ❤️ for VibeCoding Project**
