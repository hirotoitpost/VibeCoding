import '../styles/WalletConnect.css';

export function WalletConnect({ account, loading, error, onConnect }) {
  const truncateAddress = (addr) => {
    if (!addr) return '';
    return `${addr.slice(0, 6)}...${addr.slice(-4)}`;
  };

  return (
    <div className="wallet-connect">
      <div className="wallet-card">
        {error && <div className="error-message">{error}</div>}
        
        {account ? (
          <div className="wallet-info">
            <div className="wallet-status">✅ Connected</div>
            <div className="wallet-address">
              Wallet: <code>{truncateAddress(account)}</code>
            </div>
          </div>
        ) : (
          <div className="wallet-disconnect">
            <p>Please connect your MetaMask wallet to continue</p>
            <button 
              onClick={onConnect} 
              disabled={loading}
              className="connect-button"
            >
              {loading ? 'Connecting...' : 'Connect Wallet'}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
