import { useState } from 'react';
import '../styles/TransferForm.css';

export function TransferForm({ account, loading, error, onTransfer }) {
  const [recipient, setRecipient] = useState('');
  const [amount, setAmount] = useState('');
  const [txHash, setTxHash] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      if (!recipient || !amount) {
        throw new Error('Please fill in all fields');
      }

      if (!/^0x[a-fA-F0-9]{40}$/.test(recipient)) {
        throw new Error('Invalid Ethereum address');
      }

      if (isNaN(amount) || parseFloat(amount) <= 0) {
        throw new Error('Invalid amount');
      }

      setTxHash('');
      const hash = await onTransfer(recipient, amount);
      setTxHash(hash);
      setRecipient('');
      setAmount('');

    } catch (err) {
      console.error('Transfer error:', err);
    }
  };

  if (!account) {
    return (
      <div className="transfer-form disabled">
        <p>⚠️ Connect your wallet to transfer tokens</p>
      </div>
    );
  }

  return (
    <div className="transfer-form">
      <div className="form-card">
        <h2>Transfer Tokens</h2>
        
        {error && <div className="form-error">{error}</div>}
        {txHash && (
          <div className="form-success">
            ✅ Transaction sent!<br />
            <small>Hash: <code>{txHash.slice(0, 20)}...{txHash.slice(-10)}</code></small>
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="recipient">Recipient Address</label>
            <input
              id="recipient"
              type="text"
              placeholder="0x..."
              value={recipient}
              onChange={(e) => setRecipient(e.target.value)}
              disabled={loading}
            />
          </div>

          <div className="form-group">
            <label htmlFor="amount">Amount</label>
            <input
              id="amount"
              type="number"
              placeholder="0.0"
              step="0.01"
              min="0"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              disabled={loading}
            />
          </div>

          <button type="submit" disabled={loading}>
            {loading ? 'Sending...' : 'Send Tokens'}
          </button>
        </form>

        <div className="form-note">
          <p>💡 Tip: Make sure the recipient address is correct before sending.</p>
        </div>
      </div>
    </div>
  );
}
