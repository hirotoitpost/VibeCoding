# 🔧 VibeCoding Smart Contract DApp - Setup Guide [ID 014]

## Complete Setup Instructions

### Step 1: Environment Prerequisites

#### Install Node.js

**Windows (使用 Chocolatey)**:
```powershell
choco install nodejs
# または https://nodejs.org (v18+ LTS 推奨)
```

**Verify Installation**:
```bash
node --version    # v18.x.x 以上
npm --version     # 9.x.x 以上
```

#### Install MetaMask Browser Extension

1. Download MetaMask from [metamask.io](https://metamask.io)
2. Add to your browser (Chrome, Firefox, Edge, etc.)
3. Create or import a wallet
4. **Save seed phrase securely** (never share!)

### Step 2: Project Setup

#### Clone Repository (if not already done)

```bash
cd d:\ProjectPool2\hirotoitpost\GitHub\VibeCoding\examples\06-advanced\smart-contract-dapp
```

#### Install Dependencies

```bash
npm install
```

**Expected output**:
```
added 679 packages in 3m
...
✅ Installation complete
```

#### Compile Smart Contract

```bash
npm run compile
```

**Expected output**:
```
Compiling 1 file with 0.8.19
Compilation successful!
```

### Step 3: Environment Configuration

#### Create `.env` File

```bash
cp .env.example .env
```

#### Get Sepolia RPC URL

**Option A: Infura**
1. Visit [infura.io](https://infura.io)
2. Sign up and create new project
3. Select **Sepolia** network
4. Copy HTTPS endpoint
5. Add to `.env`:
```
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
```

**Option B: Alchemy**
1. Visit [alchemy.com](https://alchemy.com)
2. Create app on Sepolia
3. Copy HTTPS endpoint
4. Add to `.env`:
```
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
```

#### Get Private Key (Testnet Only)

⚠️ **Safety Warning**: Never use mainnet private keys here

**MetaMask**:
1. Open MetaMask → Settings
2. Select "Security & Privacy"
3. Click "Show Private Key"
4. Enter password to reveal
5. Copy key to `.env`:
```
PRIVATE_KEY=0x0000...
```

#### Get Etherscan API Key (Optional)

1. Visit [etherscan.io](https://etherscan.io)
2. Create account → API Keys
3. Create new key name (e.g., "Hardhat")
4. Add to `.env`:
```
ETHERSCAN_API_KEY=YOUR_KEY_HERE
```

### Step 4: Setup MetaMask for Sepolia

#### Add Sepolia Network (if not present)

1. Open MetaMask → Network dropdown
2. Click "Add network"
3. Fill in details:
   - **Network name**: Sepolia
   - **RPC URL**: https://sepolia.infura.io/v3/YOUR_PROJECT_ID
   - **Chain ID**: 11155111
   - **Currency**: ETH
   - **Explorer**: https://sepolia.etherscan.io

4. Click "Save"

#### Get Testnet ETH

1. Go to [sepolia-faucet.pk910.de](https://sepolia-faucet.pk910.de/)
2. Enter your MetaMask address
3. Submit request
4. Wait 30 seconds - 1 minute
5. Check balance in MetaMask (should show ~0.05-0.5 ETH)

### Step 5: Run Tests

#### Local Testing (No network required)

```bash
npm run test
```

**Expected output**:
```
  VibeCodingToken
    Deployment
      ✓ Should set the right owner (45ms)
      ✓ Should have correct name and symbol (38ms)
      ✓ Should have 18 decimals (32ms)
      ✓ Should mint initial supply to owner (35ms)
    Transfer
      ✓ Should transfer tokens between accounts (42ms)
      ✓ Should fail if sender doesn't have enough tokens (38ms)
    Approve and TransferFrom
      ✓ Should approve tokens (40ms)
      ✓ Should transfer tokens via transferFrom (45ms)
    Burn
      ✓ Should burn tokens (48ms)
    Pause
      ✓ Should pause token transfers (50ms)
      ✓ Should unpause token transfers (45ms)
    Snapshot
      ✓ Should create a snapshot (40ms)
    Access Control
      ✓ Should only allow owner to pause (38ms)
      ✓ Should only allow owner to unpause (42ms)
      ✓ Should only allow owner to create snapshot (40ms)

  15 passing (750ms)
```

### Step 6: Deploy to Sepolia

#### Pre-Deployment Checklist

- ✅ `.env` configured with `SEPOLIA_RPC_URL`
- ✅ `.env` contains `PRIVATE_KEY`
- ✅ MetaMask has Sepolia testnet ETH (~0.1 ETH minimum)
- ✅ Tests passing locally (`npm run test`)

#### Deploy

```bash
npm run deploy -- --network sepolia
```

**Expected output**:
```
🚀 Deploying VibeCodingToken...
📢 Deploying with account: 0x1234567890123456789012345678901234567890
💰 Account balance: 0.50 ETH

✅ VibeCodingToken deployed to: 0xAbCdEf1234567890AbCdEf1234567890AbCdEf12

📋 Token Details:
   Name: VibeCoding Token
   Symbol: VBC
   Decimals: 18
   Total Supply: 1000000.0 VBC
   Deployer Balance: 1000000.0 VBC

📝 Deployment Info:
{
  "network": "sepolia",
  "token": {
    "address": "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12",
    "name": "VibeCoding Token",
    "symbol": "VBC",
    "decimals": 18,
    "totalSupply": "1000000.0"
  },
  "deployer": "0x1234567890123456789012345678901234567890",
  "deployedAt": "2026-04-04T09:00:00.000Z"
}
```

**✅ Deployment Successful!**

Copy the contract address:
```
0xAbCdEf1234567890AbCdEf1234567890AbCdEf12
```

### Step 7: Verify on Etherscan

```bash
npx hardhat verify --network sepolia 0xAbCdEf1234567890AbCdEf1234567890AbCdEf12
```

**Expected output**:
```
Nothing to compile
Successfully submitted source code for contract...
Waiting for Etherscan to process...
Successfully verified contract VibeCodingToken on Etherscan.
https://sepolia.etherscan.io/address/0xAbCdEf1234567890AbCdEf1234567890AbCdEf12#code
```

✅ Contract now visible on blockchain explorer!

### Step 8: Setup Frontend (Optional)

#### Create React Frontend

```bash
mkdir -p frontend/src
cd frontend
npm init -y
npm install react react-dom web3 vite @vitejs/plugin-react
```

#### Start Development Server

```bash
npm run frontend:dev
```

Visit `http://localhost:3000` to interact with your token!

## ✅ Verification Checklist

- [ ] Node.js v18+ installed
- [ ] `npm install` completed successfully
- [ ] `.env` file configured
- [ ] Tests passing: `npm run test`
- [ ] MetaMask setup with Sepolia testnet
- [ ] Testnet ETH obtained (~0.1 ETH)
- [ ] Deployment successful to Sepolia
- [ ] Contract verified on Etherscan

## 🔗 Useful Links

### Testnet Faucets
- [Sepolia Faucet](https://sepolia-faucet.pk910.de/)
- [QuickNode Faucet](https://faucet.quicknode.com/ethereum/sepolia)

### Block Explorers
- [Sepolia Etherscan](https://sepolia.etherscan.io)
- [Blockscout](https://eth-sepolia.blockscout.com/)

### RPC Providers
- [Infura Docs](https://docs.infura.io/)
- [Alchemy Docs](https://docs.alchemy.com/)
- [QuickNode Docs](https://www.quicknode.com/docs)

### Development Tools
- [Hardhat Docs](https://hardhat.org/docs)
- [OpenZeppelin Docs](https://docs.openzeppelin.com/)
- [Soldity Docs](https://docs.soliditylang.org/)

## 🐛 Troubleshooting

### Error: "Cannot find module 'hardhat'"
```bash
npm install @nomicfoundation/hardhat-toolbox hardhat ethers
npm run compile
```

### Error: "Insufficient balance"
1. Check address in MetaMask
2. Verify network is Sepolia in MetaMask
3. Get testnet ETH from [faucet](https://sepolia-faucet.pk910.de/)
4. Wait 30 seconds for transaction confirmation

### Error: "Invalid network 'sepolia'"
Check `hardhat.config.ts` contains:
```typescript
networks: {
  sepolia: {
    url: process.env.SEPOLIA_RPC_URL,
    accounts: [process.env.PRIVATE_KEY],
  },
}
```

### Error: "Cannot estimate gas"
1. Ensure Sepolia RPC URL is correct
2. Verify testnet ETH balance > 0.1 ETH
3. Check contract compilation: `npm run compile`

### MetaMask Not Connecting to Localhost
1. Switch MetaMask to Sepolia testnet (not Localhost)
2. Use Sepolia RPC in `hardhat.config.ts`
3. Restart frontend dev server

## 📞 Support

For issues specific to this project:
1. Check [README.md](./README.md)
2. Review [VibeCoding Smart Contract DApp](#) documentation
3. Check git logs: `git log --oneline examples/06-advanced/smart-contract-dapp/`

---

**Setup Complete! 🎉**

Next steps:
1. Run tests: `npm run test`
2. Deploy: `npm run deploy -- --network sepolia`
3. Verify: View on [Etherscan](https://sepolia.etherscan.io)
