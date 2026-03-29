import React from 'react';
import axios from 'axios';
import './ChatWindow.css';

export default function ChatWindow() {
  const [messages, setMessages] = React.useState([
    {
      role: 'assistant',
      content: 'こんにちは！何かお手伝いできることはありますか？'
    }
  ]);
  const [input, setInput] = React.useState('');
  const [isLoading, setIsLoading] = React.useState(false);
  const messagesEndRef = React.useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  React.useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = async (e) => {
    e.preventDefault();

    if (!input.trim()) {
      return;
    }

    const userMessage = input.trim();
    setInput('');

    // Add user message to chat
    const updatedMessages = [
      ...messages,
      { role: 'user', content: userMessage }
    ];
    setMessages(updatedMessages);
    setIsLoading(true);

    try {
      // Call backend API via proxy
      const response = await axios.post('/api/chat', {
        message: userMessage,
        conversation_history: messages
      });

      if (response.data.success) {
        const assistantMessage = response.data.message;
        setMessages([
          ...updatedMessages,
          { role: 'assistant', content: assistantMessage }
        ]);
      } else {
        setMessages([
          ...updatedMessages,
          {
            role: 'assistant',
            content: 'エラーが発生しました。もう一度試してください。'
          }
        ]);
      }
    } catch (error) {
      console.error('Error sending message:', error);
      setMessages([
        ...updatedMessages,
        {
          role: 'assistant',
          content: `エラー: ${error.response?.data?.error || 'サーバーに接続できません'}`
        }
      ]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="chat-window">
      <div className="chat-header">
        <h1>チャットボット</h1>
        <p>AI アシスタントとの会話</p>
      </div>

      <div className="chat-messages">
        {messages.map((msg, index) => (
          <div
            key={index}
            className={`message message-${msg.role}`}
          >
            <div className="message-content">
              {msg.content}
            </div>
          </div>
        ))}
        {isLoading && (
          <div className="message message-assistant">
            <div className="message-content loading">
              <span>入力中</span>
              <span className="dots">
                <span>.</span><span>.</span><span>.</span>
              </span>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      <form className="chat-input-form" onSubmit={handleSendMessage}>
        <input
          type="text"
          className="chat-input"
          placeholder="メッセージを入力..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
          disabled={isLoading}
        />
        <button
          type="submit"
          className="send-button"
          disabled={isLoading || !input.trim()}
        >
          送信
        </button>
      </form>
    </div>
  );
}
