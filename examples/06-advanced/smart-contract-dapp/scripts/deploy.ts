import { ethers } from "hardhat";

async function main() {
  console.log("🚀 Deploying VibeCodingToken...");

  // Get deployer account
  const [deployer] = await ethers.getSigners();
  console.log(`📢 Deploying with account: ${deployer.address}`);

  // Get account balance
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log(`💰 Account balance: ${ethers.formatEther(balance)} ETH`);

  // Deploy VibeCodingToken
  const VibeCodingToken = await ethers.getContractFactory("VibeCodingToken");
  const token = await VibeCodingToken.deploy();

  const deployedToken = await token.waitForDeployment();
  const tokenAddress = await deployedToken.getAddress();

  console.log(`✅ VibeCodingToken deployed to: ${tokenAddress}`);

  // Display initial details
  const name = await token.name();
  const symbol = await token.symbol();
  const totalSupply = await token.totalSupply();
  const decimals = await token.decimals();

  console.log("\n📋 Token Details:");
  console.log(`   Name: ${name}`);
  console.log(`   Symbol: ${symbol}`);
  console.log(`   Decimals: ${decimals}`);
  console.log(`   Total Supply: ${ethers.formatEther(totalSupply)} ${symbol}`);

  // Get deployer balance
  const deployerBalance = await token.balanceOf(deployer.address);
  console.log(`   Deployer Balance: ${ethers.formatEther(deployerBalance)} ${symbol}`);

  // Save deployment info
  const network = await ethers.provider.getNetwork();
  const deploymentInfo = {
    network: network.name || network.chainId.toString(),
    token: {
      address: tokenAddress,
      name: name,
      symbol: symbol,
      decimals: Number(decimals),
      totalSupply: ethers.formatEther(totalSupply),
    },
    deployer: deployer.address,
    deployedAt: new Date().toISOString(),
  };

  console.log("\n📝 Deployment Info:");
  console.log(JSON.stringify(deploymentInfo, null, 2));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
