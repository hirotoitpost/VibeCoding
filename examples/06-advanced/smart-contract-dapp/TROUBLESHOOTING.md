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

**Last Updated**: 2026年4月4日  
**ID**: 014  
**Project**: VibeCoding Smart Contract DApp
