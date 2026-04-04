# Web3 フロントエンド セットアップガイド

ID 015A: Web3 フロントエンド統合の詳細セットアップ手順

---

## 📋 目次

1. [前提条件](#前提条件)
2. [初期セットアップ](#初期セットアップ)
3. [ローカル開発環境](#ローカル開発環境)
4. [Sepolia Testnet 設定](#sepolia-testnet-設定)
5. [トラブルシューティング](#トラブルシューティング)

---

## 前提条件

### ソフトウェア

- **Node.js**: v16 以上 [ダウンロード](https://nodejs.org)
- **npm**: v8 以上（Node.js に含まれる）
- **Git**: 設定済み

### ブラウザ拡張機能

- **MetaMask**: [インストール](https://metamask.io/download)

### コマンド確認

```bash
node --version    # v18.x 以上
npm --version     # 8.x 以上
git --version     # 2.x 以上
```

---

## 初期セットアップ

### ステップ 1: Repository クローン

```bash
git clone https://github.com/hirotoitpost/VibeCoding.git
cd VibeCoding
```

### ステップ 2: フロントエンド ディレクトリ移動

```bash
cd examples/06-advanced/smart-contract-dapp/frontend
```

### ステップ 3: 環境変数設定

```bash
# テンプレートをコピー
cp .env.example .env

# .env をテキストエディタで編集
# デフォルト値のままで OK（Hardhat Local 用）
```

### ステップ 4: npm dependencies インストール

```bash
npm install
```

**期待される出力:**

```
added 73 packages
```

---

## ローカル開発環境

### オプション A: Hardhat ノードでテスト（推奨）

このオプションでは、ローカル Hardhat ノードで開発テストします。

#### 1. スマートコントラクト プロジェクトへ移動

```bash
cd ../     # smart-contract-dapp ディレクトリへ戻る
```

#### 2. Hardhat ノード起動（別ターミナル）

```bash
npx hardhat node
```

**出力例：**

```
started HTTP and WebSocket JSON-RPC server

Accounts:
Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
...
```

#### 3. ID 014 コントラクト デプロイ（別ターミナル）

```bash
npx hardhat run scripts/deploy.ts --network hardhat
```

**出力例：**

```
📝 Deployment Info:
{
  "network": "hardhat",
  "token": {
    "address": "0x5FbDB2315678afecb367f032d93F642f64180aa3",
    "name": "Vibe Coding Token",
    "symbol": "VBC",
    ...
  }
}
```

**アドレスをメモ:** `0x5FbDB2315678afecb367f032d93F642f64180aa3`

#### 4. MetaMask にネットワーク追加

1. MetaMask を開く
2. ⚙️ **Settings** → **Networks** → **Add Network**
3. 以下を入力：

| フィールド | 値 |
|-----------|-----|
| Network Name | Hardhat |
| RPC URL | `http://127.0.0.1:8545` |
| Chain ID | `31337` |
| Currency Symbol | `ETH` |

4. **Save** をクリック

#### 5. テストアカウント追加（MetaMask）

```bash
# Hardhat node の出力から Account #0 の秘密鍵をコピー
# 例: 0xac0974bec39a17e36ba4a6b4d238ff944bacb476caded87fc31b231d60f4493f
```

MetaMask で：
1. 👤 アカウント → **Import Account**
2. 秘密鍵（0x で始まる文字列）をペースト
3. **Import** をクリック

#### 6. フロントエンド起動（3 番目のターミナル）

```bash
cd frontend
npm run dev
```

**出力例：**

```
  ➜  Local:   http://localhost:3000/
  ➜  press h to show help
```

#### 7. ブラウザで確認

ブラウザを開いて `http://localhost:3000` にアクセス

**期待される動作：**

1. Vibe Token ダッシュボード が表示
2. **Connect Wallet** ボタンが見える
3. ボタンをクリック → MetaMask ポップアップ表示
4. **接続** → ウォレットアドレスが表示
5. VBC 残高が「1,000,000」で表示（テストアカウント初期供給）

---

### オプション B: ローカル RPC でテスト

Hardhat node の代わりに、別の JSON-RPC サーバーを使用する場合：

```bash
# .env を編集
VITE_TOKEN_ADDRESS=0x...   # ( deployed address)
VITE_NETWORK_ID=31337      # または目的のネットワーク
```

---

## Sepolia Testnet 設定

本番前テストの場合、Sepolia Testnet で検証します。

### ステップ 1: MetaMask を Sepolia に切り替え

1. MetaMask を開く
2. ネットワーク選択 → **Sepolia（テストネット）** を選択

### ステップ 2: コントラクトをデプロイ

```bash
# smart-contract-dapp ディレクトリで

# 新しい .env ファイル作成（ID 014 ディレクトリ）
cat > .env.sepolia << EOF
SEPOLIA_RPC_URL=https://rpc.sepolia.org
PRIVATE_KEY=<your_private_key>
ETHERSCAN_API_KEY=<optional>
EOF

# デプロイ実行
npx hardhat run scripts/deploy.ts --network sepolia
```

### ステップ 3: Sepolia テスト ETH 取得

以下から Sepolia ETH を取得（ガス代用）：

- [Sepolia Faucet 1](https://sepoliafaucet.com)
- [Sepolia Faucet 2](https://www.alchemy.com/faucets/ethereum-sepolia)

### ステップ 4: フロントエンド設定

```bash
cd frontend

# .env を編集
cat > .env << EOF
VITE_TOKEN_ADDRESS=0x...       # デプロイから得たアドレス
VITE_NETWORK_ID=11155111       # Sepolia Chain ID
EOF
```

### ステップ 5: フロントエンド起動

```bash
npm run dev
```

ブラウザで `http://localhost:3000` へアクセス

**注意:** MetaMask で Sepolia が選択されていることを確認

---

## トラブルシューティング

### 🔴 "MetaMask not installed"

**原因:** MetaMask ブラウザ拡張がインストールされていない

**解決:**
1. [MetaMask](https://metamask.io/download) をインストール
2. ブラウザ再起動
3. ページをリロード

---

### 🔴 ウォレット接続後もアドレスが表示されない

**原因:** `.env` の `VITE_TOKEN_ADDRESS` が誤っている

**解決:**
1. Hardhat node / Sepolia でデプロイアドレスを確認
2. `.env` を更新
3. フロントエンド再起動：`npm run dev`

---

### 🔴 "Failed to fetch balance"

**原因:** 
- コントラクトがデプロイされていない
- アドレスが現在のネットワークにない
- ネットワーク接続エラー

**解決:**
```bash
# 1. デプロイ状態確認
npx hardhat run scripts/deploy.ts --network hardhat

# 2. ネットワーク確認（ブラウザコンソール F12）
# MetaMask が正しいネットワークに切り替わっているか確認

# 3. フロントエンド再起動
npm run dev
```

---

### 🔴 npm install エラー

**症状:**

```
ERR! code ERESOLVE
ERR! ERESOLVE unable to resolve dependency tree
```

**解決:**

```bash
npm install --legacy-peer-deps
# または
npm cache clean --force
npm install
```

---

### 🔴 Vite ポート 3000 が既に使用中

**症状:**

```
EADDRINUSE: address already in use :::3000
```

**解決:**

```bash
# ポート 3000 のプロセスを確認
lsof -i :3000
# または ViteLOG がプロセスを使用している場合は kill

# 別ポートで実行
npm run dev -- --port 3001
```

---

### 🔴 MetaMask ネットワーク追加失敗

**症状:** Hardhat ネットワーク追加後も反応がない

**解決:**
1. MetaMask 再度ここで手動追加
2. RPC URL が `http://127.0.0.1:8545` か確認
3. Hardhat node が実行中か確認

---

### 🔴 トランザクション署名後、トランザクションが表示されない

**症状:** "Sending..." ボタンが固まる

**解決:**
1. MetaMask ウォレット確認
2. ガス代が十分か確認
3. ブラウザコンソール (F12) でエラー確認
4. MetaMask ネットワークが正しいか確認

---

## 💡 開発ヒント

### Vite 開発サーバーのホットリロード

ファイル保存時に自動でブラウザがリロードします：

```bash
npm run dev
# ファイル編集 → 自動リロード
```

### デバッグ

ブラウザコンソール (F12) でデバッグ情報確認：

```javascript
// コンポーネント内で
console.log('Account:', account);
console.log('Balance:', balance);
console.error('Error:', error);
```

### 環境変数のリセット

`.env` ファイルをリセット：

```bash
cp .env.example .env
```

---

## 📚 次のステップ

1. ✅ ローカル開発環境でテスト
2. ✅ Sepolia Testnet でテスト
3. ⏳ 本番 Ethereum ネットワーク（将来）

---

**Support**: トラブルが解決しない場合、[README.md](./README.md) の参考資料を確認してください。
