# 🔧 VibeCoding スマートコントラクト DApp - セットアップガイド [ID 014 + 015]

## 完全なセットアップ手順

このガイドに従うことで、**Sepolia テストネット** 上で VibeCodingToken スマートコントラクトをデプロイし、React フロントエンドで Web3 連携が可能になります。

---

## ステップ 1: 環境前提条件

### Node.js のインストール

**Windows (Chocolatey 使用)**:
```powershell
choco install nodejs
# または手動: https://nodejs.org (v18+ LTS 推奨)
```

**macOS (Homebrew 使用)**:
```bash
brew install node
```

**インストール確認**:
```bash
node --version    # v18.x.x 以上
npm --version     # 9.x.x 以上
```

### MetaMask ブラウザ拡張をインストール

1. [metamask.io](https://metamask.io) からダウンロード
2. ブラウザに追加（Chrome, Firefox, Edge など対応）
3. ウォレットを作成またはインポート
4. **シードフレーズを安全に保存** （絶対に他人に共有しないこと！）

---

## ステップ 2: プロジェクトセットアップ

### リポジトリをクローン

```bash
cd d:\ProjectPool2\hirotoitpost\GitHub\VibeCoding\examples\06-advanced\smart-contract-dapp
```

### 依存パッケージをインストール

```bash
npm install
```

**予想される出力**:
```
added 679 packages in 3m
...
✅ インストール完了
```

### スマートコントラクトをコンパイル

```bash
npm run compile
```

**予想される出力**:
```
Compiling 1 file with 0.8.19
Compilation successful!
```

---

## ステップ 3: 環境設定

### `.env` ファイルを作成

```bash
cp .env.example .env
```

### Sepolia RPC URL を取得

#### オプション A: Alchemy（推奨）

1. [alchemy.com](https://alchemy.com) にアクセス
2. アカウント作成 → アプリ作成
3. ネットワーク選択: **Sepolia**
4. HTTPS エンドポイントをコピー
5. `.env` に追加:

```
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
```

#### オプション B: Infura

1. [infura.io](https://infura.io) にアクセス
2. ログイン → 新規プロジェクト作成
3. ネットワーク選択: **Sepolia**
4. HTTPS エンドポイントをコピー
5. `.env` に追加:

```
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
```

### 秘密鍵を取得（テストネットのみ）

⚠️ **重要**: Mainnet の秘密鍵は絶対にここに貼り付けないこと！

**MetaMask から取得**:

1. MetaMask を開く
2. 右上のアイコン → **「設定」**
3. **「セキュリティとプライバシー」** をクリック
4. **「秘密鍵を表示」** をクリック
5. パスワードを入力
6. 表示された秘密鍵をコピー
7. `.env` に追加:

```
PRIVATE_KEY=0x0000...
```

### Etherscan API キー（オプション）

1. [etherscan.io](https://etherscan.io) にアクセス
2. アカウント作成 → API キーを作成
3. 新規キーを作成（例: "Hardhat"）
4. `.env` に追加:

```
ETHERSCAN_API_KEY=YOUR_KEY_HERE
```

---

## ステップ 4: MetaMask を Sepolia 用に設定

### Sepolia ネットワークを追加（見つからない場合）

1. MetaMask を開く → ネットワークドロップダウン
2. **「ネットワークを追加」** をクリック
3. 以下の情報を入力:

| 項目 | 値 |
|-----|-----|
| **ネットワーク名** | Sepolia Testnet |
| **新しい RPC URL** | `https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY` |
| **チェーン ID** | `11155111` |
| **通貨記号** | `ETH` |
| **ブロック エクスプローラ URL** | `https://sepolia.etherscan.io` |

4. **「保存」** をクリック

### テストネット ETH を取得

**いずれかの Faucet から取得**:

| Faucet | リンク | 特徴 |
|--------|--------|------|
| **Alchemy** | https://www.alchemy.com/faucets/ethereum-sepolia | 推奨（安定） |
| **Sepolia Faucet** | https://sepolia-faucet.pk910.de/ | クイック |
| **QuickNode** | https://faucet.quicknode.com/ethereum/sepolia | 高速 |

**手順**:
1. 上記の Faucet のいずれかにアクセス
2. MetaMask アドレスを入力
3. 「Send」ボタンをクリック
4. **5〜30 分待つ**（ブロック確認中）
5. MetaMask で残高確認（0.05 〜 0.5 ETH 程度）

---

## ステップ 5: テストを実行

### ローカルテスト（ネットワーク不要）

```bash
npm run test
```

**予想される出力**:

```
  VibeCodingToken
    デプロイ
      ✓ オーナー権限を正しく設定 (45ms)
      ✓ 正しい名前とシンボル (38ms)
      ✓ 18 デシマル (32ms)
      ✓ 初期供給量をオーナーにミント (35ms)
    
    トークン転送
      ✓ アカウント間でトークンを転送 (42ms)
      ✓ 残高不足で転送失敗 (38ms)
    
    承認と TransferFrom
      ✓ トークン承認 (40ms)
      ✓ TransferFrom でトークン転送 (45ms)
    
    バーン
      ✓ トークンをバーン (48ms)
    
    一時停止
      ✓ トークン転送を一時停止 (50ms)
      ✓ トークン転送を再開 (45ms)
    
    スナップショット
      ✓ スナップショット作成 (40ms)
    
    アクセス制御
      ✓ オーナーのみ一時停止可能 (38ms)
      ✓ オーナーのみ再開可能 (42ms)
      ✓ オーナーのみスナップショット作成可能 (40ms)

  15 個のテスト成功 (750ms)
```

---

## ステップ 6: Sepolia にデプロイ

### デプロイ前チェックリスト

**すべてに✅を確認してから進める**:

- ✅ `.env` に `SEPOLIA_RPC_URL` が設定されている
- ✅ `.env` に `PRIVATE_KEY` が設定されている
- ✅ MetaMask に Sepolia テストネット ETH がある（最低 0.1 ETH）
- ✅ ローカルテストが成功している (`npm run test`)

### デプロイ実行

```bash
npm run deploy -- --network sepolia
```

**予想される出力**:

```
🚀 VibeCodingToken をデプロイ中...
📢 デプロイアカウント: 0xCE241a60a23825059aA05F83FEF291CcaD65BC38
💰 アカウント残高: 0.50 ETH

✅ VibeCodingToken がデプロイされました: 0xBbe8666fF3d416Ef9a27e842F3575F76636218ff

📋 トークン詳細:
   名前: VibeCoding Token
   シンボル: VBC
   デシマル: 18
   総供給量: 1000000.0 VBC
   デプロイアカウント残高: 1000000.0 VBC

📝 デプロイ情報:
{
  "network": "sepolia",
  "token": {
    "address": "0xBbe8666fF3d416Ef9a27e842F3575F76636218ff",
    "name": "VibeCoding Token",
    "symbol": "VBC",
    "decimals": 18,
    "totalSupply": "1000000.0"
  },
  "deployer": "0xCE241a60a23825059aA05F83FEF291CcaD65BC38",
  "deployedAt": "2026-04-05T06:22:15.381Z"
}
```

✅ **デプロイ成功！**

コントラクトアドレスをコピーしておきます:
```
0xBbe8666fF3d416Ef9a27e842F3575F76636218ff
```

---

## ステップ 7: Etherscan で検証

```bash
npx hardhat verify --network sepolia 0xBbe8666fF3d416Ef9a27e842F3575F76636218ff
```

**予想される出力**:

```
Nothing to compile
ソースコードをコントラクトに提出しました...
Etherscan での処理を待機中...
VibeCodingToken コントラクトが Etherscan で正常に検証されました。
https://sepolia.etherscan.io/address/0xBbe8666fF3d416Ef9a27e842F3575F76636218ff#code
```

✅ コントラクトがブロックチェーンエクスプローラで確認可能になりました！

---

## ステップ 8: フロントエンドを設定（ID 015）

### フロントエンド環境設定

```bash
cd frontend
cp .env.example .env
```

`.env` ファイルを編集:
```
VITE_TOKEN_ADDRESS=0xBbe8666fF3d416Ef9a27e842F3575F76636218ff
VITE_NETWORK_ID=11155111
```

### 開発サーバーを起動

```bash
npm run dev
```

**出力例**:
```
  VITE v4.5.14  ready in 572 ms

  ➜  Local:   http://localhost:3001/
  ➜  Network: use --host to expose
```

ブラウザで **`http://localhost:3001`** にアクセス！

### 機能をテスト

1. **「Connect Wallet」** をクリック
2. MetaMask で **Sepolia Test Account** を選択
3. **署名** をクリック
4. トークン残高が **1,000,000 VBC** と表示される ✅
5. **トークン転送** フォームで別アカウントへ送信テスト

---

## ✅ セットアップ完了チェックリスト

- [ ] Node.js v18+ がインストール済み
- [ ] `npm install` が成功
- [ ] `.env` ファイルが設定済み
- [ ] テストが成功: `npm run test`
- [ ] MetaMask が Sepolia テストネットで設定済み
- [ ] テスト ETH を取得済み（最低 0.1 ETH）
- [ ] Sepolia へのデプロイが成功
- [ ] Etherscan で コントラクト検証済み
- [ ] フロントエンド起動成功
- [ ] MetaMask 接続でトークン残高表示

---

## 🔗 便利なリンク

### テストネット Faucets
- [Alchemy Faucet](https://www.alchemy.com/faucets/ethereum-sepolia)
- [Sepolia Faucet](https://sepolia-faucet.pk910.de/)
- [QuickNode Faucet](https://faucet.quicknode.com/ethereum/sepolia)

### ブロック エクスプローラ
- [Sepolia Etherscan](https://sepolia.etherscan.io)
- [Blockscout](https://eth-sepolia.blockscout.com/)

### RPC プロバイダ
- [Alchemy Docs](https://docs.alchemy.com/)
- [Infura Docs](https://docs.infura.io/)
- [QuickNode Docs](https://www.quicknode.com/docs)

### 開発ツール
- [Hardhat Docs](https://hardhat.org/docs)
- [OpenZeppelin Docs](https://docs.openzeppelin.com/)
- [Solidity Docs](https://docs.soliditylang.org/)

---

## 🐛 トラブルシューティング

### エラー: "Cannot find module 'hardhat'"

```bash
npm install @nomicfoundation/hardhat-toolbox hardhat ethers
npm run compile
```

### エラー: "Insufficient balance"

1. MetaMask でアドレスを確認
2. MetaMask がネットワークを Sepolia に設定しているか確認
3. Faucet からテスト ETH を取得: [sepolia-faucet.pk910.de](https://sepolia-faucet.pk910.de/)
4. トランザクション確認を待つ（30 秒〜1 分）

### エラー: "Invalid network 'sepolia'"

`hardhat.config.ts` に以下が含まれているか確認:

```typescript
networks: {
  sepolia: {
    url: process.env.SEPOLIA_RPC_URL,
    accounts: [process.env.PRIVATE_KEY],
  },
}
```

### エラー: "Cannot estimate gas"

1. Sepolia RPC URL が正しいか確認
2. テストネット ETH 残高を確認（> 0.1 ETH が必要）
3. コントラクトコンパイルを確認: `npm run compile`

### エラー: MetaMask が接続できない

1. MetaMask ネットワーク を Sepolia に切り替え
2. 接続権限をリセット: MetaMask → Settings → Connected sites → localhost 削除
3. ページをリロード（F5）
4. 「Connect Wallet」を再度クリック

---

## 📞 サポート

問題が発生した場合:

1. [README_ja.md](./README_ja.md) を確認
2. [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) を確認
3. GitHub Issues で報告

---

## 📚 参考資料

より詳しい情報は以下を参照してください:

| ドキュメント | 説明 |
|------------|------|
| [README_ja.md](README_ja.md) | プロジェクト概要（日本語） |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | トラブルシューティング |
| [README.md](README.md) | プロジェクト概要（英語） |

---

**セットアップ完了！🎉**

次のステップ:
1. テスト実行: `npm run test`
2. デプロイ: `npm run deploy -- --network sepolia`
3. Etherscan で確認: `https://sepolia.etherscan.io`
4. フロントエンド: `cd frontend && npm run dev`

---

**最終更新**: 2026年4月5日  
**言語**: 日本語  
**バージョン**: 1.0
