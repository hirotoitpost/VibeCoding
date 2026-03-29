"""
Chat service module using OpenAI API.
"""
import openai
from src.config import OPENAI_API_KEY, OPENAI_MODEL, MAX_TOKENS, TEMPERATURE

openai.api_key = OPENAI_API_KEY


class ChatService:
    """Service for interacting with OpenAI API."""

    def __init__(self):
        """Initialize the chat service."""
        self.model = OPENAI_MODEL
        self.max_tokens = MAX_TOKENS
        self.temperature = TEMPERATURE

    def get_response(self, user_message: str, conversation_history: list = None) -> str:
        """
        Get a response from OpenAI API.

        Args:
            user_message: The user's input message
            conversation_history: Previous messages in the conversation

        Returns:
            The AI response message
        """
        if conversation_history is None:
            conversation_history = []

        # Prepare messages for the API
        messages = conversation_history + [
            {"role": "user", "content": user_message}
        ]

        try:
            response = openai.ChatCompletion.create(
                model=self.model,
                messages=messages,
                max_tokens=self.max_tokens,
                temperature=self.temperature,
            )
            return response.choices[0].message.content
        except openai.error.AuthenticationError:
            raise ValueError("Invalid OpenAI API key")
        except openai.error.RateLimitError:
            raise RuntimeError("OpenAI API rate limit exceeded")
        except Exception as e:
            raise RuntimeError(f"OpenAI API error: {str(e)}")

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
