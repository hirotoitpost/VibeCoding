import { useWeb3 } from './hooks/useWeb3';
import { WalletConnect } from './components/WalletConnect';
import { TokenInfo } from './components/TokenInfo';
import { TransferForm } from './components/TransferForm';
import './App.css';

function App() {
  const {
    account,
    balance,
    tokenSymbol,
    chainId,
    loading,
    error,
    connectWallet,
    transferToken,
  } = useWeb3();

  return (
    <div className="app">
      <header className="app-header">
        <h1>🎯 Vibe Token Dashboard</h1>
        <p>Web3 Frontend for ERC-20 Token Management</p>
      </header>

      <main className="app-main">
        <WalletConnect 
          account={account}
          loading={loading}
          error={error}
          onConnect={connectWallet}
        />

        {account && (
          <>
            <TokenInfo 
              balance={balance}
              tokenSymbol={tokenSymbol}
              account={account}
              chainId={chainId}
            />

            <TransferForm 
              account={account}
              loading={loading}
              error={error}
              onTransfer={transferToken}
            />
          </>
        )}
      </main>

      <footer className="app-footer">
        <p>Built with React + ethers.js • Part of VibeCoding Project</p>
        <p>
          Contract: <code>{import.meta.env.VITE_TOKEN_ADDRESS || '0x5FbDB...'}</code>
        </p>
      </footer>
    </div>
  );
}

export default App;
