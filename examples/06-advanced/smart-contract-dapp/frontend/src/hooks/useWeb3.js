import { useState, useEffect, useCallback } from 'react';
import { ethers } from 'ethers';

// ERC-20 ABI（必要な関数のみ）
const ERC20_ABI = [
  'function balanceOf(address owner) view returns (uint256)',
  'function transfer(address to, uint256 amount) returns (bool)',
  'function approve(address spender, uint256 amount) returns (bool)',
  'function allowance(address owner, address spender) view returns (uint256)',
  'function name() view returns (string)',
  'function symbol() view returns (string)',
  'function decimals() view returns (uint8)',
];

// 設定
const CONTRACT_ADDRESS = import.meta.env.VITE_TOKEN_ADDRESS || '0x5FbDB2315678afecb367f032d93F642f64180aa3';
const NETWORK_ID = import.meta.env.VITE_NETWORK_ID || '31337'; // Hardhat local

export function useWeb3() {
  const [account, setAccount] = useState(null);
  const [balance, setBalance] = useState('0');
  const [tokenSymbol, setTokenSymbol] = useState('VBC');
  const [chainId, setChainId] = useState(null);
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // MetaMask 接続
  const connectWallet = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      if (!window.ethereum) {
        throw new Error('MetaMask not installed');
      }

      // アカウント要求
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      });

      const connectedAccount = accounts[0];
      setAccount(connectedAccount);

      // プロバイダー初期化
      const newProvider = new ethers.BrowserProvider(window.ethereum);
      setProvider(newProvider);

      const newSigner = await newProvider.getSigner();
      setSigner(newSigner);

      // チェーンID取得
      const network = await newProvider.getNetwork();
      setChainId(network.chainId.toString());

      // 残高取得
      await fetchBalance(newProvider, connectedAccount);

    } catch (err) {
      setError(err.message);
      console.error('Wallet connection error:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  // 残高取得
  const fetchBalance = useCallback(async (prov, acc) => {
    try {
      const contract = new ethers.Contract(CONTRACT_ADDRESS, ERC20_ABI, prov);
      const balanceRaw = await contract.balanceOf(acc);
      const decimals = await contract.decimals();
      const symbol = await contract.symbol();

      const balanceFormatted = ethers.formatUnits(balanceRaw, decimals);
      setBalance(balanceFormatted);
      setTokenSymbol(symbol);
    } catch (err) {
      console.error('Balance fetch error:', err);
      setError('Failed to fetch balance');
    }
  }, []);

  // トークン転送
  const transferToken = useCallback(async (toAddress, amount) => {
    try {
      if (!signer) throw new Error('Wallet not connected');

      setLoading(true);
      setError(null);

      const contract = new ethers.Contract(CONTRACT_ADDRESS, ERC20_ABI, signer);
      const decimals = await contract.decimals();
      const amountToSend = ethers.parseUnits(amount, decimals);

      const tx = await contract.transfer(toAddress, amountToSend);
      await tx.wait();

      // 残高更新
      if (provider && account) {
        await fetchBalance(provider, account);
      }

      return tx.hash;
    } catch (err) {
      setError(err.message);
      console.error('Transfer error:', err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [signer, provider, account, fetchBalance]);

  // アカウント変更検知
  useEffect(() => {
    if (!window.ethereum) return;

    const handleAccountsChanged = (accounts) => {
      if (accounts.length === 0) {
        setAccount(null);
        setBalance('0');
      } else if (accounts[0] !== account) {
        setAccount(accounts[0]);
      }
    };

    const handleChainChanged = () => {
      window.location.reload();
    };

    window.ethereum.on('accountsChanged', handleAccountsChanged);
    window.ethereum.on('chainChanged', handleChainChanged);

    return () => {
      window.ethereum.removeListener('accountsChanged', handleAccountsChanged);
      window.ethereum.removeListener('chainChanged', handleChainChanged);
    };
  }, [account]);

  // 定期的に残高更新
  useEffect(() => {
    if (!account || !provider) return;

    const interval = setInterval(() => {
      fetchBalance(provider, account);
    }, 5000);

    return () => clearInterval(interval);
  }, [account, provider, fetchBalance]);

  return {
    account,
    balance,
    tokenSymbol,
    chainId,
    loading,
    error,
    connectWallet,
    transferToken,
    fetchBalance: () => account && provider && fetchBalance(provider, account),
  };
}
