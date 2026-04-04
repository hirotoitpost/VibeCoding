# 🚀 VibeCoding Smart Contract DApp [ID 014]

## Project Overview

**VibeCoding ID 014** is a decentralized application (DApp) showcasing an **ERC-20 token** on the **Sepolia testnet** with a React frontend and Web3.js integration.

### Features

✅ **ERC-20 Token Implementation** (VibeCodingToken - VBC)
- Standard ERC-20 interface
- Burnable: token holders can burn their tokens
- Snapshot: create voting/distribution snapshots
- Pausable: pause/unpause transactions
- Ownable: owner-only administrative functions

✅ **Smart Contract Testing**
- 15+ comprehensive Hardhat tests
- Coverage for all major functions
- Access control verification

✅ **Web3 Frontend Integration**
- React 18 + Vite
- MetaMask wallet connection
- Real-time token balances
- Transfer UI
- Transaction history

## 📋 Requirements

- **Node.js**: v16+ (LTS recommended)
- **npm**: v8+
- **MetaMask**: Browser extension for wallet operations
- **Sepolia Testnet ETH**: For gas fees (get from [faucet](https://sepolia-faucet.pk910.de/))

## 🛠️ Setup & Installation

### 1. Clone and Install Dependencies

```bash
cd examples/06-advanced/smart-contract-dapp
npm install
```

### 2. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` with:
- `SEPOLIA_RPC_URL`: Your Infura/Alchemy API endpoint
- `PRIVATE_KEY`: Your wallet's private key (never commit!)
- `ETHERSCAN_API_KEY`: For contract verification (optional)

### 3. Compile Smart Contract

```bash
npm run compile
```

Expected output:
```
Compiling 1 file with 0.8.19
Compilation successful!
```

## 📝 Usage

### Run Tests Locally

```bash
npm run test
```

Output:
```
  VibeCodingToken
    Deployment
      ✓ Should set the right owner
      ✓ Should have correct name and symbol
      ✓ Should have 18 decimals
      ✓ Should mint initial supply to owner
    Transfer
      ✓ Should transfer tokens between accounts
      ✓ Should fail if sender doesn't have enough tokens
    (... 10+ more tests ...)
      
  15 passing (XXms)
```

### Deploy to Sepolia Testnet

```bash
npm run deploy -- --network sepolia
```

Output example:
```
🚀 Deploying VibeCodingToken...
📢 Deploying with account: 0x1234...5678
💰 Account balance: 0.5 ETH

✅ VibeCodingToken deployed to: 0xABCD...EFGH

📋 Token Details:
   Name: VibeCoding Token
   Symbol: VBC
   Decimals: 18
   Total Supply: 1000000.0 VBC
   Deployer Balance: 1000000.0 VBC
```

### Verify Contract on Etherscan

```bash
npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
```

Replace `<CONTRACT_ADDRESS>` with the deployed contract address.

### Start Frontend Development

```bash
npm run frontend:dev
```

Visit `http://localhost:3000` to interact with the token via Web3.

## 📂 Project Structure

```
smart-contract-dapp/
├── contracts/
│   └── VibeCodingToken.sol          # ERC-20 token implementation
├── scripts/
│   └── deploy.ts                     # Deployment script
├── test/
│   └── VibeCodingToken.test.ts       # Test suite (15+ tests)
├── frontend/
│   ├── src/
│   │   ├── App.jsx                   # Main React component
│   │   └── Web3Provider.jsx          # MetaMask integration
│   └── package.json
├── hardhat.config.ts                 # Hardhat configuration
├── package.json                      # Dependencies
├── .env.example                      # Environment template
└── README.md                         # This file
```

## 🔐 Security Considerations

⚠️ **Private Keys**: Never commit `.env` files containing private keys
⚠️ **Testnet Only**: This contract is for educational purposes on testnet
⚠️ **Audit**: Production contracts should undergo professional security audit
⚠️ **Gas Costs**: Mainnet deployment requires ETH for gas fees

## 🌐 Network Configuration

### Sepolia Testnet
- **Chain ID**: 11155111
- **RPC**: https://sepolia.infura.io/v3/{PROJECT_ID}
- **Explorer**: https://sepolia.etherscan.io
- **Faucet**: https://sepolia-faucet.pk910.de/

## 📚 Learning Resources

### Smart Contract Development
- [OpenZeppelin ERC20 Docs](https://docs.openzeppelin.com/contracts/4.x/erc20)
- [Hardhat Documentation](https://hardhat.org/docs)
- [Solidity by Example](https://solidity-by-example.org/)

### Web3 & DApp Integration
- [Web3.js Documentation](https://docs.web3js.org/)
- [MetaMask Integration Guide](https://docs.metamask.io/guide/)
- [Ethers.js Documentation](https://docs.ethers.io/)

## 🚀 Next Steps

1. **Deploy to Sepolia**: Run `npm run deploy -- --network sepolia`
2. **Test via Frontend**: Connect MetaMask and interact with token
3. **Verify on Etherscan**: Use verify command for transparency
4. **Extend Features**: Add staking, governance, or swaps

## 📞 Troubleshooting

### "Cannot find module 'hardhat'"
```bash
npm install
npm run compile
```

### "Invalid network"
Check `SEPOLIA_RPC_URL` in `.env` is correct and accessible

### "Insufficient balance"
Get testnet ETH from [Sepolia faucet](https://sepolia-faucet.pk910.de/)

### MetaMask Connection Issues
1. Ensure MetaMask is installed
2. Switch network to **Sepolia Testnet**
3. Try again

## 📄 License

MIT License - See LICENSE file

---

**Created**: 2026年4月4日  
**VibeCoding Learning Project**  
**Phase**: 3.3 (Advanced Projects)
