# 🚀 VibeCoding スマートコントラクト DApp [ID 014 + 015]

## プロジェクト概要

**VibeCoding ID 014 + 015** は、**Sepolia テストネット**上で動作する分散型アプリケーション（DApp）です。
**ERC-20 トークン** スマートコントラクトと React フロントエンド、Web3.js 統合を活用しています。

### 機能

✅ **ERC-20 トークン実装** (VibeCodingToken - VBC)
- 標準 ERC-20 インターフェース
- Burnable: トークン保有者がトークンをバーン可能
- Snapshot: 投票・配布用のスナップショット機能
- Pausable: トランザクション一時停止・再開
- Ownable: オーナーのみ実行可能な管理機能

✅ **スマートコントラクト テスト**
- 15 種類以上の包括的 Hardhat テスト
- すべての主要機能をカバー
- アクセス制御の検証

✅ **Web3 フロントエンド統合** (ID 015)
- React 18 + Vite
- MetaMask ウォレット接続
- リアルタイム トークン残高表示
- トークン転送 UI
- トランザクション履歴表示

---

## 📋 必須環境

- **Node.js**: v16+ (LTS 推奨)
- **npm**: 9.x.x 以上
- **MetaMask**: ブラウザ拡張機能 ([metamask.io](https://metamask.io))
- **Git**: バージョン管理

---

## 🚀 クイックスタート

### 1️⃣ リポジトリをクローン

```bash
git clone https://github.com/hirotoitpost/VibeCoding.git
cd VibeCoding/examples/06-advanced/smart-contract-dapp
```

### 2️⃣ 依存パッケージをインストール

```bash
# スマートコントラクト環境
npm install

# フロントエンド
cd frontend && npm install && cd ..
```

### 3️⃣ 環境変数を設定

```bash
# .env.example をコピー
cp .env.example .env

# 編集: SEPOLIA_RPC_URL, PRIVATE_KEY を追加
# 詳細は SETUP_GUIDE_ja.md を参照
```

### 4️⃣ ローカルテスト（オプション）

```bash
# Hardhat ノード起動
npx hardhat node

# 別ターミナルでテスト実行
npm run test
```

### 5️⃣ Sepolia に デプロイ

```bash
npx hardhat run scripts/deploy.ts --network sepolia
# 出力例: ✅ VibeCodingToken deployed to: 0xBbe8666fF3d416Ef9a27e842F3575F76636218ff
```

### 6️⃣ フロントエンドを起動

```bash
cd frontend
npm run dev
# ブラウザで http://localhost:3001 を開く
```

---

## 📂 プロジェクト構成

```
smart-contract-dapp/
├── contracts/
│   └── VibeCodingToken.sol    # ERC-20 トークンコントラクト
├── scripts/
│   └── deploy.ts              # デプロイスクリプト
├── test/
│   └── VibeCodingToken.test.ts  # テストスイート（15 テスト）
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   ├── Dashboard.jsx      # ダッシュボード
│   │   │   ├── TokenBalance.jsx   # 残高表示
│   │   │   └── TransferForm.jsx   # 転送フォーム
│   │   ├── hooks/
│   │   │   └── useWeb3.js        # Web3 ロジック
│   │   └── App.jsx               # メインアプリ
│   ├── index.html
│   └── package.json
├── hardhat.config.ts           # Hardhat 設定
├── package.json               # NPM 依存関係
├── .env.example              # 環境変数テンプレート
├── README_ja.md             # 📖 このファイル
├── SETUP_GUIDE_ja.md        # セットアップガイド（日本語）
└── TROUBLESHOOTING.md       # トラブルシューティング
```

---

## 🧪 テスト実行

### ローカル テスト（Hardhat）

```bash
npm run test

# 出力例:
#   VibeCodingToken
#     ✓ Constructor sets initial state (65ms)
#     ✓ Transfer works correctly (72ms)
#     ✓ Burn works correctly (68ms)
#     ... (計 15 テスト)
#   
#   15 passing (922ms)
```

### Sepolia テストネット での検証

1. **デプロイ実行**
   ```bash
   npx hardhat run scripts/deploy.ts --network sepolia
   ```

2. **フロントエンド接続確認**
   - `npm run dev` でフロントエンド起動
   - MetaMask を Sepolia に切り替え
   - 「Connect Wallet」をクリック

3. **トークン転送テスト**
   - 残高表示: 1,000,000 VBC ✅
   - 別アカウントへ 100 VBC を転送
   - トランザクション成功確認

---

## 🔐 セキュリティに関する注意

⚠️ **重要**: このプロジェクトはテスト・学習用です

- **Mainnet では使用しないこと** - テストネット専用
- **秘密鍵を GitHub にコミットしない** - `.env` は `.gitignore` に指定
- **MetaMask の秘密鍵は絶対に共有しないこと** - パスワード管理ツール推奨
- **Mainnet 流出防止** - Hardhat config で複数ネットワーク設定時は要注意

---

## 📖 ドキュメント

| ファイル | 説明 |
|---------|------|
| [README_ja.md](README_ja.md) | 📋 このプロジェクト概要（日本語） |
| [SETUP_GUIDE_ja.md](SETUP_GUIDE_ja.md) | 🔧 詳細セットアップ手順（日本語） |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | 🔍 トラブルシューティング |
| [README.md](README.md) | 📋 プロジェクト概要（英語） |
| [SETUP_GUIDE.md](SETUP_GUIDE.md) | 🔧 詳細セットアップ手順（英語） |

---

## 🛠️ よくある質問

### Q: 0.1 Sepolia ETH はどこで入手？

**A**: Sepolia Faucet から取得
- 🔗 https://www.alchemy.com/faucets/ethereum-sepolia
- 🔗 https://sepolia-faucet.pk910.de/

テストアカウントアドレスを入力して「Send」をクリック。5〜30 分で到着します。

### Q: ガス代はいくら？

**A**: Sepolia テストネットはテスト用つため、ガス代は実質無料
- 実績: トークン転送で **0.00008 Sepolia ETH** 消費
- 参考: Mainnet では数ドル〜数十ドル必要

### Q: MetaMask で Sepolia が見つからない？

**A**: 手動で Sepolia ネットワークを追加
1. MetaMask → ネットワーク追加
2. RPC URL: `https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY`
3. チェーン ID: `11155111`
4. ネットワーク名: `Sepolia Testnet`

詳細は [SETUP_GUIDE_ja.md](SETUP_GUIDE_ja.md) を参照

### Q: トークン残高が 0 VBC と表示される？

**A**: 以下を確認
1. MetaMask ネットワークが **Sepolia** か？
2. MetaMask アカウントが **デプロイアカウント** か？
3. ページが正しい **Contract Address** を使用しているか？

詳細は [TROUBLESHOOTING.md](TROUBLESHOOTING.md) 参照

---

## 🔗 リンク集

- **GitHub**: https://github.com/hirotoitpost/VibeCoding
- **Sepolia Etherscan**: https://sepolia.etherscan.io
- **OpenZeppelin Docs**: https://docs.openzeppelin.com/contracts/
- **Hardhat Docs**: https://hardhat.org/docs
- **ethers.js Docs**: https://docs.ethers.org/v6/

---

## 👥 貢献

このプロジェクトは VibeCoding 学習プロジェクトの一部です。

改善提案やバグ報告は GitHub Issues で！

---

## 📝 ライセンス

MIT License - 詳細は [LICENSE](../../LICENSE) を参照

---

## 📅 プロジェクト情報

| 項目 | 内容 |
|-----|------|
| **ID** | 014 (コントラクト) + 015 (フロントエンド) |
| **開始日** | 2026年3月26日 |
| **テスト環境** | Sepolia Testnet |
| **最終更新** | 2026年4月5日 |
| **ステータス** | ✅ テスト完了・本番対応準備 |

---

**質問や問題があれば、Issue を作成してください！** 🤝

---

**Last Updated**: 2026年4月5日  
**Language**: 日本語  
**Version**: 1.0
