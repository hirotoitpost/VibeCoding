"""
Chat service module using Google Generative AI (Gemini) API.
Mock responses for demonstration when API is unavailable.
"""
from src.config import GOOGLE_API_KEY, MAX_TOKENS, TEMPERATURE

# Mock responses for testing (avoiding API version conflicts)
MOCK_RESPONSES = {
    "hello": "👋 Hello! I'm a chatbot powered by Vibe Coding. How can I help you today?",
    "how are you": "😊 I'm doing great! Thanks for asking. I'm ready to chat and help with your questions.",
    "what is vibe coding": "🎯 Vibe Coding is a learning project that teaches how to work with AI in code development. It focuses on understanding what AI can do and how to effectively collaborate with AI tools.",
    "tell me": "📚 I'd be happy to help! What would you like to know more about?",
    "example": "💡 Here are some things you can ask me:\n- What is Vibe Coding?\n- Tell me a joke\n- Explain machine learning\n- How can AI help with coding?\nFeel free to chat naturally!",
    "thanks": "🙏 You're welcome! Feel free to ask me anything else.",
    "bye": "👋 Goodbye! Have a great day!",
    "help": "📖 I can help you with:\n- Information about Vibe Coding\n- General coding questions\n- AI and machine learning basics\n- Development tips and tricks\nJust ask away!",
    "joke": "😄 Why do Java developers wear glasses? Because they don't C#!",
    "ai": "🤖 AI is fascinating! I can help you understand machine learning, neural networks, and how AI assistants like me work.",
    "coding": "💻 Coding is great! Whether it's Python, JavaScript, or other languages, I'm here to help with your programming questions.",
    "python": "🐍 Python is an excellent programming language! Great for web development, data science, and AI.",
    "javascript": "⚙️ JavaScript powers interactive web applications. Combined with React (like this app!), it creates amazing user experiences.",
    "vibe": "✨ That's the spirit! Vibe Coding is all about creating a positive learning experience with AI.",
}


class ChatService:
    """Service for interacting with Gemini API (with fallback mock responses)."""

    def __init__(self):
        """Initialize the chat service."""
        self.max_tokens = MAX_TOKENS
        self.temperature = TEMPERATURE

    def get_response(self, user_message: str, conversation_history: list = None) -> str:
        """
        Get a response from Gemini API or mock response.

        Args:
            user_message: The user's input message
            conversation_history: Previous messages in the conversation

        Returns:
            The AI response message
        """
        if conversation_history is None:
            conversation_history = []

        try:
            # Try to use actual Gemini API
            import google.generativeai as genai
            genai.configure(api_key=GOOGLE_API_KEY)
            model = genai.GenerativeModel("gemini-pro")
            
            response = model.generate_content(user_message)
            return response.text
        except Exception as api_error:
            # Fallback to mock responses for demonstration
            print(f"⚠️ API Error (using mock response): {str(api_error)}")
            return self._get_mock_response(user_message)

    def _get_mock_response(self, user_message: str) -> str:
        """
        Get a mock response based on user message.

        Args:
            user_message: The user's input message

        Returns:
            A mock response string
        """
        message_lower = user_message.lower()
        
        # Check for keyword matches
        for keyword, response in MOCK_RESPONSES.items():
            if keyword in message_lower:
                return response
        
        # Default response
        return f"✨ That's an interesting question! In a real scenario with full Gemini API integration, I would provide a detailed response. For now, you said: \"{user_message}\" - feel free to ask me anything about Vibe Coding or coding in general!"

    def validate_message(self, message: str) -> bool:
        """
        Validate user message.

        Args:
            message: The message to validate

        Returns:
            True if valid, False otherwise
        """
        if not message:
            return False
        if len(message.strip()) == 0:
            return False
        if len(message) > 4096:
            return False
        return True
