# 🌐 VibeCoding Web3 フロントエンド [ID 015]

## プロジェクト概要

**VibeCoding ID 015** は、**Sepolia テストネット** 上で動作する **Web3 対応 React フロントエンド** です。
スマートコントラクト（ERC-20 Token）と MetaMask を統合し、トークン残高表示・トークン転送機能を提供します。

---

## ✨ 主な機能

### 🔐 MetaMask ウォレット連携
- **ワンクリック接続**: MetaMask のウォレット選択
- **自動ネットワーク検出**: Sepolia テストネット確認
- **複数アカウント対応**: アカウント切り替え対応

### 💰 トークン残高表示
- **リアルタイム更新**: スマートコントラクト直連携
- **フォーマット表示**: 1,000,000 VBC 形式で表示
- **ネットワーク情報**: Chain ID・ネットワーク名表示

### 📤 トークン転送 UI
- **送信先アドレス入力**: 任意のアドレスへ送信
- **送信額指定**: トークン量を入力
- **MetaMask 署名**: トランザクション確認

### 🎨 レスポンシブ デザイン
- モバイル・タブレット・PC 対応
- ダークモード対応の UI
- リアルタイム ステータス表示

---

## 🛠️ 技術スタック

| 技術 | バージョン | 用途 |
|-----|---------|------|
| **React** | 18.2.0 | UI フレームワーク |
| **Vite** | 4.5.14 | ビルド・開発サーバー |
| **ethers.js** | 6.7.1 | Web3 ライブラリ |
| **CSS3** | - | スタイリング |

---

## 📂 プロジェクト構成

```
frontend/
├── src/
│   ├── components/
│   │   ├── Dashboard.jsx       # メインダッシュボード
│   │   ├── TokenBalance.jsx    # 残高表示パネル
│   │   ├── TransferForm.jsx    # 転送フォーム
│   │   ├── NetworkInfo.jsx     # ネットワーク情報
│   │   └── WalletConnect.jsx   # ウォレット接続ボタン
│   │
│   ├── hooks/
│   │   └── useWeb3.js         # Web3 ロジック（164 行）
│   │       ├── connectWallet()      # MetaMask 接続
│   │       ├── fetchBalance()       # 残高取得
│   │       ├── transferToken()      # トークン転送
│   │       └── disconnectWallet()   # 接続解除
│   │
│   ├── styles/
│   │   ├── Dashboard.css       # ダッシュボード スタイル
│   │   ├── TokenBalance.css    # 残高パネル スタイル
│   │   ├── TransferForm.css    # フォーム スタイル
│   │   ├── NetworkInfo.css     # ネットワーク情報 スタイル
│   │   └── index.css           # グローバル スタイル
│   │
│   └── App.jsx                # メインアプリケーション
│
├── index.html                 # HTML ルート
├── vite.config.js             # Vite 設定
├── package.json               # 依存関係
├── .env.example              # 環境変数テンプレート
├── README_ja.md              # 📖 このファイル（日本語）
├── SETUP_GUIDE_ja.md         # セットアップガイド（日本語）
├── README.md                 # プロジェクト概要（英語）
└── SETUP_GUIDE.md            # セットアップガイド（英語）
```

---

## 🚀 クイックスタート

### 1️⃣ 環境設定

```bash
cd frontend
cp .env.example .env
```

`.env` を編集:
```
VITE_TOKEN_ADDRESS=0xBbe8666fF3d416Ef9a27e842F3575F76636218ff
VITE_NETWORK_ID=11155111
```

### 2️⃣ 依存パッケージをインストール

```bash
npm install
```

### 3️⃣ 開発サーバーを起動

```bash
npm run dev
```

**出力例**:
```
  VITE v4.5.14  ready in 572 ms

  ➜  Local:   http://localhost:3001/
  ➜  Network: use --host to expose
```

### 4️⃣ ブラウザで確認

`http://localhost:3001/` を開く

### 5️⃣ MetaMask で接続

1. **MetaMask をネットワーク「Sepolia」に切り替え**
2. **「Connect Wallet」ボタンをクリック**
3. **MetaMask で署名を承認**
4. **トークン残高が 1,000,000 VBC と表示される ✅**

---

## 📖 各コンポーネント の説明

### `useWeb3.js` フック（Web3 ロジックの中核）

**機能**:
- MetaMask 接続・切断
- トークン残高の取得・更新
- トークン転送トランザクション実行

**主要な関数**:

```javascript
// MetaMask に接続
const connectWallet = async () => {
  // accounts リスト取得 → 最初のアカウント選択
  // Provider 初期化 → Signer 取得
  // 残高を自動取得
}

// 残高を取得
const fetchBalance = async (provider, account) => {
  // コントラクトから balanceOf(account) を呼び出し
  // 18 デシマルで数値を変換
}

// トークンを転送
const transferToken = async (recipientAddress, amount) => {
  // transfer() トランザクションを実行
  // MetaMask で署名
}
```

### `Dashboard.jsx` - メインコンポーネント

表示するもの:
- ウォレット接続状態
- トークン残高（VBC）
- ネットワーク情報（Sepolia）
- トークン転送フォーム

### `TransferForm.jsx` - トークン転送フォーム

**入力フィールド**:
- 送信先アドレス
- 送信額（VBC）

**実行可能な操作**:
- 「Transfer」ボタンで トークン転送実行
- MetaMask で署名確認
- トランザクション完了後、残高を自動更新

---

## 🔧 設定ファイル

### `.env` ファイル

```bash
# Smart Contract が デプロイ されたアドレス
VITE_TOKEN_ADDRESS=0xBbe8666fF3d416Ef9a27e842F3575F76636218ff

# ネットワーク ID (Sepolia)
VITE_NETWORK_ID=11155111
```

### `vite.config.js`

```javascript
export default {
  plugins: [react()],
  server: {
    port: 3001,  // 開発サーバーポート
  },
}
```

---

## 📊 使用方法

### ステップ 1: ウォレット接続

```
【フロントエンド】
┌─────────────────────┐
│  Vibe Token         │
│  Dashboard          │
│                     │
│ [Connect Wallet]    │ ← クリック
└─────────────────────┘
         ↓
【MetaMask ポップアップ】
┌──────────────────────┐
│ Account を選択:       │
│ ☑ Sepolia Test Acc   │
│ ☐ Account 2          │
│ ☐ Imported Acc 1     │
│                      │
│ [Connect] [Cancel]   │
└──────────────────────┘
         ↓
【フロントエンド】
✅ Connected: 0xCE241a60...
💰 Balance: 1,000,000 VBC
```

### ステップ 2: トークン転送

```
【トークン残高】
💰 Balance: 1,000,000.00 VBC

【転送フォーム】
送信先アドレス: 0x0a9867cE69...
送信額: 100

[Transfer] ← クリック
     ↓
【MetaMask 確認】
トランザクション確認画面表示
ガス代: 0.00008 Sepolia ETH
[署名] ← クリック
     ↓
【トランザクション完了】
✅ Transaction successful!
💰 Updated Balance: 999,900 VBC
```

---

## 🐛 トラブルシューティング

### 問題 1: トークン残高が 0 VBC と表示される

**原因**:
1. MetaMask ネットワークが Sepolia ではない
2. MetaMask アカウントが デプロイアカウント ではない
3. コントラクトアドレスが正しくない

**解決方法**:
```bash
1. MetaMask ネットワークを Sepolia に切り替え
2. [Connect Wallet] をクリックして接続し直し
3. Browser DevTools (F12) で確認:
   console.log('ネットワーク ID:', await window.ethereum.request({ method: 'eth_chainId' }))
   // 出力: 0xaa36a7 (Sepolia = 11155111)
```

### 問題 2: "Cannot find module 'ethers'"

**解決方法**:
```bash
npm install ethers@^6.7.1
npm run dev
```

### 問題 3: ポート 3001 が既に使用されている

**解決方法**:
```bash
# 別のポートで起動
npm run dev -- --port 3002

# または既存プロセスを終了
# Windows
taskkill /F /IM node.exe
# macOS/Linux
killall node
```

### 問題 4: MetaMask 接続ボタンが応答しない

**解決方法**:
```bash
1. MetaMask が インストール されているか確認
2. ブラウザ DevTools (F12) でエラー確認
3. MetaMask サイト権限をリセット:
   - MetaMask → Settings → Connected sites
   - localhost:3001 を削除
4. ページをリロード (F5)
```

---

## ✅ テスト手順

### 基本テスト

```
1. Page Loading
   ✅ http://localhost:3001 にアクセス
   ✅ ページが読み込まれる
   ✅ "Connect Wallet" ボタンが表示される

2. Wallet Connection
   ✅ MetaMask が Sepolia に切り替わっている
   ✅ "Connect Wallet" をクリック
   ✅ MetaMask ポップアップが表示される
   ✅ テストアカウントを選択できる
   ✅ 署名後、"Connected" が表示される

3. Balance Display
   ✅ トークン残高が表示される（1,000,000 VBC）
   ✅ ネットワーク情報が正しく表示される

4. Token Transfer
   ✅ 転送フォームが表示される
   ✅ 送信先・送信額を入力できる
   ✅ "Transfer" をクリックで MetaMask 確認画面
   ✅ 署名後、トランザクション実行
   ✅ 残高が更新される
```

---

## 🌐 ブラウザ サポート

| ブラウザ | バージョン | 対応状況 |
|--------|---------|--------|
| Chrome | 90+ | ✅ 完全対応 |
| Firefox | 88+ | ✅ 完全対応 |
| Edge | 90+ | ✅ 完全対応 |
| Safari | 15+ | ✅ 完全対応 |

---

## 📚 参考資料

### 公式ドキュメント
- [ethers.js v6 Docs](https://docs.ethers.org/v6/)
- [React Docs](https://react.dev/)
- [Vite Docs](https://vitejs.dev/)
- [MetaMask Docs](https://docs.metamask.io/)

### チュートリアル
- [Web3 開発入門](https://docs.metamask.io/guide/mobile-getting-started.html)
- [Hardhat チュートリアル](https://hardhat.org/docs/guides/waffle-testing)

---

## 🤝 貢献

改善提案やバグ報告は GitHub Issues でお願いします！

---

## 📄 ライセンス

MIT License

---

## 📈 パフォーマンス

| メトリック | 値 | 評価 |
|----------|-----|------|
| Initial Load | < 1s | ✅ 優秀 |
| Balance Fetch | < 2s | ✅ 優秀 |
| Transaction Confirm | < 10s | ✅ 良好 |

---

## 📞 サポート

質問や問題がある場合:

1. [README_ja.md](README_ja.md) を確認
2. [SETUP_GUIDE_ja.md](SETUP_GUIDE_ja.md) を確認
3. [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) を確認
4. GitHub Issues を作成

---

**Last Updated**: 2026年4月5日  
**Language**: 日本語  
**Version**: 1.0  
**ID**: 015 (Web3 フロントエンド統合)
