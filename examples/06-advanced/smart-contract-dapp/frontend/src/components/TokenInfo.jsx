import '../styles/TokenInfo.css';

export function TokenInfo({ balance, tokenSymbol, account, chainId }) {
  const getNetworkName = (chainId) => {
    const networks = {
      '1': 'Ethereum Mainnet',
      '11155111': 'Sepolia Testnet',
      '31337': 'Hardhat Local',
    };
    return networks[chainId] || `Network ${chainId}`;
  };

  return (
    <div className="token-info">
      <div className="info-card">
        <div className="info-section">
          <h2>Token Balance</h2>
          <div className="balance-display">
            <span className="balance-value">
              {parseFloat(balance).toFixed(2)}
            </span>
            <span className="balance-symbol">{tokenSymbol}</span>
          </div>
        </div>

        <div className="info-section">
          <h3>Network Information</h3>
          <div className="network-info">
            <div className="info-item">
              <label>Network:</label>
              <span>{getNetworkName(chainId)}</span>
            </div>
            <div className="info-item">
              <label>Chain ID:</label>
              <span><code>{chainId}</code></span>
            </div>
            <div className="info-item">
              <label>Account:</label>
              <span><code>{account?.slice(0, 10)}...{account?.slice(-8)}</code></span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
