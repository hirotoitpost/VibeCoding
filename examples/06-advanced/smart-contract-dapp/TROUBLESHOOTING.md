# 🔍 Smart Contract DApp - Troubleshooting Guide [ID 014]

## Common Issues & Solutions

### 🔴 Compilation & Build Errors

#### ❌ "Cannot find module '@nomicfoundation/hardhat-toolbox'"

**Symptom**:
```
Error: Cannot find module '@nomicfoundation/hardhat-toolbox'
```

**Solution**:
```bash
# Option 1: Reinstall dependencies
rm -r node_modules package-lock.json
npm install

# Option 2: Install specific package
npm install --save-dev @nomicfoundation/hardhat-toolbox@^4.0.0
```

#### ❌ "Declaration file for module not found (*.d.ts)"

**Symptom**:
```
error TS7016: Could not find a declaration file for module 'hardhat'
```

**Solution**:
```bash
npm install --save-dev @types/node
npm run compile
```

#### ❌ "Compilation failed: Compilation error"

**Symptom**:
```
Error HH502: Compilation failed. See output above.
```

**Solution**:
1. Check Solidity version matches in `hardhat.config.ts`:
   ```typescript
   solidity: "0.8.19",
   ```
2. Verify OpenZeppelin imports:
   ```bash
   npm install @openzeppelin/contracts
   ```
3. Clear cache and recompile:
   ```bash
   rm -rf cache artifacts
   npm run compile
   ```

---

### 🔴 Network & RPC Issues

#### ❌ "Invalid network 'sepolia'"

**Symptom**:
```
Error: Invalid network 'sepolia'
```

**Solution**:
Check `hardhat.config.ts` contains Sepolia network:
```typescript
networks: {
  sepolia: {
    url: process.env.SEPOLIA_RPC_URL || "...",
    accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
  },
}
```

#### ❌ "Failed to fetch from RPC provider"

**Symptom**:
```
Error: failed to fetch from RPC provider: <error>
```

**Troubleshooting**:
1. Verify `.env` contains correct `SEPOLIA_RPC_URL`:
   ```bash
   echo $SEPOLIA_RPC_URL  # Should show full URL
   ```

2. Test RPC connection:
   ```bash
   curl https://sepolia.infura.io/v3/YOUR_PROJECT_ID \
     -X POST \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"net_version","params":[],"id":67}'
   ```

3. Verify API key is active:
   - Infura: Check project settings
   - Alchemy: Check API key not rate-limited
   - QuickNode: Verify endpoint status

4. Ensure `.env` is loaded:
   ```bash
   # Re-check .env file exists
   ls -la .env
   # Redeploy
   npm run deploy -- --network sepolia
   ```

#### ❌ "Could not connect to any of the configured Ethereum nodes"

**Symptom**:
```
Error: Could not connect to any of the configured Ethereum nodes
```

**Solution**:
```bash
# 1. Verify network is accessible
ping https://sepolia.infura.io  # Should respond

# 2. Check hardhat.config.ts has networks defined
cat hardhat.config.ts | grep "sepolia" -A 3

# 3. Verify .env is correct
cat .env | grep SEPOLIA_RPC_URL

# 4. Try with explicit network
npm run deploy -- --network sepolia
```

---

### 🔴 Deployment Issues

#### ❌ "Insufficient balance for gas"

**Symptom**:
```
Error: Sender account balance is insufficient for sending transaction. 
Required balance: 0.123 ETH
Current balance: 0.05 ETH
```

**Solution**:
1. Get testnet ETH from faucet:
   - [Sepolia Faucet](https://sepolia-faucet.pk910.de/)
   - [QuickNode Faucet](https://faucet.quicknode.com/ethereum/sepolia)

2. Verify balance in MetaMask:
   - Switch to **Sepolia testnet**
   - Check balance shows > 0.1 ETH

3. Wait for transaction confirmation:
   - Faucets typically take 30-60 seconds
   - Check on [Etherscan](https://sepolia.etherscan.io)

#### ❌ "Invalid private key format"

**Symptom**:
```
Error: No private key provided. Please set PRIVATE_KEY environment variable
```

**Solution**:
1. Verify `.env` contains private key:
   ```bash
   grep PRIVATE_KEY .env
   # Should show: PRIVATE_KEY=0x0000...
   ```

2. Format must be hex string:
   - ✅ Correct: `PRIVATE_KEY=0xabcd1234...`
   - ❌ Wrong: `PRIVATE_KEY=abcd1234...` (missing 0x prefix)

3. Get private key from MetaMask:
   - Settings → Security & Privacy → Show Private Key
   - Copy with 0x prefix

4. Update `.env` and retry:
   ```bash
   npm run deploy -- --network sepolia
   ```

#### ❌ "Nonce too high"

**Symptom**:
```
Error: Transaction nonce is too high. Expected nonce: X but got: Y
```

**Solution**:
1. Reset Metamask account:
   - Settings → Advanced → Reset Account
   - Confirms all pending transactions

2. Check Etherscan for stuck transactions:
   - Navigate to your address on [Etherscan](https://sepolia.etherscan.io)
   - Check pending transactions
   - Wait for confirmation or cancel

3. Retry deployment:
   ```bash
   npm run deploy -- --network sepolia
   ```

---

### 🔴 Testing Issues

#### ❌ "Cannot find module 'chai'"

**Symptom**:
```
Error: Cannot find module 'chai'
```

**Solution**:
```bash
npm install --save-dev chai @nomicfoundation/hardhat-chai-matchers
npm run test
```

#### ❌ "Test timeout exceeded"

**Symptom**:
```
Error: timeout of 40000ms exceeded
```

**Solution**:
1. Increase Hardhat test timeout in `hardhat.config.ts`:
   ```typescript
   mocha: {
     timeout: 120000, // 2 minutes
   }
   ```

2. Run specific test:
   ```bash
   npx hardhat test test/VibeCodingToken.test.ts
   ```

#### ❌ "Contract not found during test"

**Symptom**:
```
Error: Unable to get the contract factory contract name
```

**Solution**:
1. Verify contract is compiled:
   ```bash
   npm run compile
   ls artifacts/contracts/
   ```

2. Verify import in test file:
   ```typescript
   const VibeCodingToken = await ethers.getContractFactory("VibeCodingToken");
   // Matches file: contracts/VibeCodingToken.sol
   ```

3. Recompile and test:
   ```bash
   npm run compile
   npm run test
   ```

---

### 🔴 Etherscan Verification Issues

#### ❌ "Contract address does not exist"

**Symptom**:
```
Error: 0x123... contract does not exist
```

**Solution**:
1. Verify deployment was successful:
   ```bash
   # Check last deployment output
   npm run deploy -- --network sepolia | tail -20
   ```

2. Search on Etherscan:
   - Visit [sepolia.etherscan.io](https://sepolia.etherscan.io)
   - Search your contract address
   - Confirm it shows "Contract" tag

3. If not found, deployment may have failed:
   ```bash
   # Check gas, balance, and retry
   npm run test  # Verify tests pass locally
   npm run deploy -- --network sepolia
   ```

#### ❌ "Constructor arguments mismatch"

**Symptom**:
```
Error: Retrieved constructor arguments do not match the submitted contract.
```

**Solution**:
For contracts with constructor params, verify in `hardhat.config.ts`:
```typescript
// For VibeCodingToken (no params), just verify:
npx hardhat verify --network sepolia 0xContractAddress

// If it had params:
// npx hardhat verify --network sepolia 0xContractAddress "param1" "param2"
```

#### ❌ "Wrong compiler version"

**Symptom**:
```
Error: Compiler version 0.8.19 was not found
```

**Solution**:
1. Verify `hardhat.config.ts` matches contract file:
   ```typescript
   solidity: "0.8.19"
   ```

2. Verify `.sol` file pragma:
   ```solidity
   pragma solidity ^0.8.0;  // Matches 0.8.19
   ```

3. Compile with specific version:
   ```bash
   npm run compile
   
   # Then verify
   npx hardhat verify --network sepolia 0xContractAddress
   ```

---

### 🔴 MetaMask & Web3 Issues

#### ❌ "MetaMask not found"

**Symptom**:
```
Error: window.ethereum is undefined
```

**Solution**:
1. Ensure MetaMask is installed:
   - Download from [metamask.io](https://metamask.io)
   - Refresh page after installation

2. Check browser console:
   - F12 → Console tab
   - Should see no errors about MetaMask

3. Verify permissions in MetaMask:
   - MetaMask icon → Settings → Permissions
   - Ensure localhost is allowed

#### ❌ "Wrong network in MetaMask"

**Symptom**:
```
Error: Chain ID mismatch. Expected 11155111, got 1
```

**Solution**:
1. Switch MetaMask to Sepolia:
   - Click network dropdown
   - Select **Sepolia Testnet**

2. If Sepolia not visible, add it:
   - Click "Add network"
   - Copy details from `.env` or SETUP_GUIDE.md

3. Check network in frontend:
   ```javascript
   const chainId = await window.ethereum.request({ 
     method: 'eth_chainId' 
   });
   console.log(chainId);  // Should be 0xaa36a7 (Sepolia)
   ```

---

### 🟡 Performance & Gas Issues

#### ⚠️ "High gas estimate"

**Note**: Gas costs vary by network congestion

```bash
# Check current gas price on Sepolia
curl https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=Z7H15GKDM98FT98QCUW61AYQN2MJDSVVJN
```

**Solutions**:
1. Deploy during low-traffic hours
2. Use Alchemy or QuickNode for better RPC performance
3. Monitor gas on [ETH Gas Station](https://ethgasstation.info/)

---

## 📋 Checklist for Successful Deployment

Before resorting to troubleshooting:

- [ ] `npm install` completed without errors
- [ ] `npm run compile` successful
- [ ] `npm run test` passes all 15 tests
- [ ] `.env` exists with all required variables
- [ ] `SEPOLIA_RPC_URL` is valid and accessible
- [ ] `PRIVATE_KEY` starts with `0x`
- [ ] MetaMask has Sepolia testnet ETH
- [ ] MetaMask network set to Sepolia (Chain ID: 11155111)
- [ ] No conflicting Hardhat processes running

## 🆘 Advanced Debugging

### Enable Verbose Logging

```bash
# Hardhat debug mode
DEBUG=hardhat:* npm run deploy -- --network sepolia

# Also check RPC calls
DEBUG=ethers:* npm run deploy -- --network sepolia
```

### Check Node Sync Status

```bash
curl -X POST https://sepolia.infura.io/v3/YOUR_API_KEY \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'

# Should return: false (node is synced)
```

### Verify Wallet Balance

```bash
npx hardhat run --network sepolia << 'EOF'
const { ethers } = require("hardhat");
const [signer] = await ethers.getSigners();
const balance = await ethers.provider.getBalance(signer.address);
console.log(`Balance: ${ethers.formatEther(balance)} ETH`);
EOF
```

---

## 📞 Getting Help

1. **Check logs carefully** - Most errors include actionable hints
2. **Search Hardhat docs** - [hardhat.org/docs](https://hardhat.org/docs)
3. **Check Etherscan** - [sepolia.etherscan.io](https://sepolia.etherscan.io)
4. **GitHub Issues** - [hardhat-plugins](https://github.com/NomicFoundation/hardhat/issues)
5. **Stack Exchange** - [ethereum.stackexchange.com](https://ethereum.stackexchange.com)

---

## 🎯 ID 015: Web3 フロントエンド統合テスト - 実装時の躓きと解決

> 📝 **Session 16**: Sepolia テストネットでの実際のテスト実施記録

### 📌 Issue 1: Hardhat Local でのコントラクト消失問題

**背景**: ID 015 実装後、Hardhat Local で最初のテストを試行

**症状**:
```
Frontend (localhost:3001) 接続 → ✅ OK
MetaMask 接続 → ✅ OK
トークン残高取得 → ❌ FAILED
エラー: "could not decode result data (value="0x", ...BAD_DATA)"
残高表示: 0.00 VBC
```

**原因分析**:
- **Hardhat Local ノード** はメモリベースのため、ノード再起動で デプロイされたコントラクトが **消失**
- フロントエンドが呼び出す契約アドレスが存在しない状態

**解決方法**:
```
✅ 決定: Hardhat Local 使用を中止 → Sepolia テストネット へ切り替え
理由: Sepolia は永続的、テスト目的に適正、実運用に近い
```

**学習ポイント**:
- Hardhat Local テスト環境は **開発初期段階専用**
- **本格的なテスト** には **テストネット** (Sepolia) を使用
- メモリベース環境の制約を理解することが重要

---

### 📌 Issue 2: Sepolia RPC エンドポイント選定の課題

**背景**: デプロイ実行のため Sepolia RPC URL が必要

**試行1: Alchemy デモ RPC**
```
エンドポイント: https://eth-sepolia.g.alchemy.com/v2/demo
エラー: "Too Many Requests error received from eth-sepolia.g.alchemy.com"
原因: Demo RPC はレート制限（複数ユーザー共有）
```

**試行2: BlastAPI パブリック RPC**
```
エンドポイント: https://eth-sepolia.public.blastapi.io
エラー: "Blast API is no longer available. Please update..."
原因: RPC プロバイダ廃止・サービス終了
```

**試行3: dRPC パブリック RPC**
```
エンドポイント: https://eth-sepolia.drpc.org
エラー: "Invalid JSON-RPC response received: {"message":"Not Found"}"
原因: URL 形式エラーまたはエンドポイント不安定
```

**試行4: Infura パブリック API キー**
```
エンドポイント: https://sepolia.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161
エラー: "project ID does not have access to this network"
原因: API キーに権限がない
```

**解決方法** ✅:
```
ユーザーが既に Alchemy アカウントを保有していた
提供: https://eth-sepolia.g.alchemy.com/v2/Xq0pcWL_M-FTEpftfv7z_
→ 正式 API キー (Demo ではない) で成功！
```

**ベストプラクティス**:
```
1️⃣ パブリック RPC の無料枠 → 廃止・制限が多い
2️⃣ サードパーティ RPC → 登録必須だが安定
3️⃣ 推奨: Alchemy, Infura, QuickNode などで正式アカウント取得
4️⃣ テスト段階: 正式 API キーを事前に用意する
```

---

### 📌 Issue 3: デプロイ失敗 - ガス代不足

**症状**:
```
npm run deploy -- --network sepolia
💰 Account balance: 0.0 ETH
❌ Error: insufficient funds for gas * price + value: have 0 want 107838202678473
```

**原因**: テストアカウント `0xCE241a60a23825059aA05F83FEF291CcaD65BC38` に **SEpoliaETH が 0**

**解決方法**:
```
1. Sepolia Faucet からテスト ETH を取得
   - https://www.alchemy.com/faucets/ethereum-sepolia
   - テストアドレスに 0.1 Sepolia ETH を送信
   
2. 待機: 5〜30 分（ブロック確認）

3. デプロイ再実行
   ✅ 成功: VibeCodingToken deployed to: 0xBbe8666fF3d416Ef9a27e842F3575F76636218ff
```

**ガス代の実績**:
```
トランザクション nonce: 1
基本料金 (Gwei): 0.038290043
優先手数料 (gwei): 15
ガスリミット: 52,990
ガス使用量: 52,200
ガス代合計: 0.00008 SepoliaETH ✅
```

---

### 📌 Issue 4: ウォレット接続時の複数アカウント問題

**症状**:
```
MetaMask に 4 つのアカウントが存在
- Sepolia Test Account (0xCE241a60...) ← デプロイ先（トークン保有）
- Imported Account 1 (0xf39Fd6e5...) ← 接続されてしまった（トークンなし）
- Account 2
- Account 3
```

**フロントエンド接続時**:
```
Frontend が eth_requestAccounts を呼び出す
→ MetaMask UI 表示（アカウント選択ダイアログ）
→ Imported Account 1 が自動選択される（歴史的理由？）
→ トークン残高 0 VBC として表示
```

**表示結果**:
```
✅ Connected: 0xF39F...2266 (Imported Account 1)
💰 Balance: 0.00 VBC ❌ 期待値: 1,000,000 VBC
```

**解決方法**:
```
1. MetaMask の接続権限をリセット
   - MetaMask 右上のメニュー → Settings
   - Connected sites → localhost:3001 を削除
   
2. ページをリロード (F5)

3. 「Connect Wallet」ボタン再クリック

4. MetaMask UI で「Sepolia Test Account」を選択

5. 接続完了
```

**改善後**:
```
✅ Connected: 0xCE241a60a23825059aA05F83FEF291CcaD65BC38 (正しい！)
💰 Balance: 1,000,000.00 VBC ✅
```

---

### 📌 Issue 5: MetaMask ネットワーク切り替え忘れ

**症状**:
```
ページの「Network Information」に "Ethereum Mainnet" と表示
タイルに大きなエラー表示: "Failed to fetch balance: could not decode result data..."
```

**原因**:
```
MetaMask が「Ethereum Mainnet」に接続されている
フロントエンド設定は「Sepolia」(Chain ID: 11155111)
→ ネットワーク不一致でコントラクト通信失敗
```

**解決方法**:
```
✅ MetaMask 左上のネットワークドロップダウンをクリック
✅ 「Sepolia」を選択
✅ ページをリロード (F5)
```

**改善後**:
```
Network Information:
- Network: Sepolia Testnet ✅
- Chain ID: 11155111 ✅
- Account: 0xCE241a60a23825059aA05F83FEF291CcaD65BC38 ✅
- Balance: 1,000,000.00 VBC ✅
```

---

### ✅ トークン転送テスト成功

**実施内容**:
```
送信元: Sepolia Test Account (0xCE241a60...)
  初期: 1,000,000 VBC
  
送信先: Account 2 (0x0a9867cE...)
  初期: 0 VBC
  
転送額: 100 VBC
```

**トランザクション詳細**:
```
Status: ✅ 確定されました
From: 0xCE241a60a23825059aA05F83FEF291CcaD65BC38
To: Account 2 (Wallet 1)
Transaction: Nonce 1

ガス内訳:
- 基本料金: 0.038290043 Gwei
- 優先手数料: 15 gwei
- ガスリミット: 52,990
- ガス使用量: 52,200
- ガス代合計: 0.00008 SepoliaETH ✅

転送結果:
- 送信元残高: 1,000,000 → 999,900 VBC
- 送信先残高: 0 → 100 VBC ✅
```

---

### 📚 概念の理解

**Sepolia テストネットの2つの資産**:

| 資産 | 発行者 | 用途 | 残高 |
|-----|--------|------|------|
| **SepoliaETH** | Ethereum | ガス代（手数料） | 0.0999 ETH |
| **VBC トークン** | デプロイされたコントラクト | アプリケーション内トークン | 999,900 VBC |

**転送による消費**:
- 転送対象: **VBC Token** (アプリケーションレベル)
- ガス代: **SepoliaETH の一部** (ネットワークレベル)
- 結果: VBC は 100 減、SepoliaETH は 0.00008 減

---

### 🎓 ベストプラクティス

#### デプロイ前チェックリスト
```
✅ RPC エンドポイント: 正式 API キー使用
✅ ウォレット残高: 最低 0.01 ETH
✅ ネットワーク設定: Sepolia に統一
✅ アカウント確認: デプロイアカウント = 接続アカウント
✅ ドメイン記録: アカウント・アドレス・チェーンID
```

#### フロントエンド接続手順
```
1. MetaMask ネットワーク切り替え → Sepolia
2. MetaMask サイト権限リセット（初回）
3. ページリロード
4. 「Connect Wallet」クリック
5. MetaMask で目的アカウント選択
6. 署名承認
```

#### トラブル診断フロー
```
残高が 0 VBC? 
  → メタマスク ネットワークが Sepolia か確認
  
エラーが消えない?
  → DevTools Console で eth_chainId 確認
  
アカウント違い?
  → MetaMask 接続権限をリセット
```

---

**テスト実施日**: 2026年4月5日  
**ID**: 015（Web3 フロントエンド統合）  
**テスト状況**: ✅ **完全成功** - Sepolia で正常に機能確認  
**ガス代実績**: 0.00008 SepoliaETH ($0 概算)

---

**Last Updated**: 2026年4月5日  
**ID**: 014 + 015  
**Project**: VibeCoding Smart Contract DApp
