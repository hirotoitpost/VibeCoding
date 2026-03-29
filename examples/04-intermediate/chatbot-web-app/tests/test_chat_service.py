"""
Unit tests for chat_service module.
"""
import pytest
from unittest.mock import patch, MagicMock
from src.chat_service import ChatService


@pytest.fixture
def chat_service():
    """Create a ChatService instance for testing."""
    return ChatService()


class TestChatService:
    """Tests for ChatService class."""

    def test_chat_service_initialization(self, chat_service):
        """Test ChatService initialization."""
        assert chat_service.model == "gpt-3.5-turbo"
        assert chat_service.max_tokens == 2048
        assert chat_service.temperature == 0.7

    def test_validate_message_valid(self, chat_service):
        """Test message validation with valid message."""
        assert chat_service.validate_message("Hello") is True

    def test_validate_message_empty(self, chat_service):
        """Test message validation with empty message."""
        assert chat_service.validate_message("") is False

    def test_validate_message_whitespace(self, chat_service):
        """Test message validation with whitespace only."""
        assert chat_service.validate_message("   ") is False

    def test_validate_message_too_long(self, chat_service):
        """Test message validation with message exceeding max length."""
        long_message = "a" * 4097
        assert chat_service.validate_message(long_message) is False

    def test_validate_message_max_length(self, chat_service):
        """Test message validation with message at max length."""
        max_message = "a" * 4096
        assert chat_service.validate_message(max_message) is True

    @patch("src.chat_service.openai.ChatCompletion.create")
    def test_get_response_success(self, mock_create, chat_service):
        """Test successful response from OpenAI API."""
        mock_create.return_value = MagicMock(
            choices=[MagicMock(message=MagicMock(content="Test response"))]
        )

        response = chat_service.get_response("Hello")
        assert response == "Test response"
        mock_create.assert_called_once()

    @patch("src.chat_service.openai.ChatCompletion.create")
    def test_get_response_with_history(self, mock_create, chat_service):
        """Test response with conversation history."""
        mock_create.return_value = MagicMock(
            choices=[MagicMock(message=MagicMock(content="Response with history"))]
        )

        history = [
            {"role": "user", "content": "Previous message"},
            {"role": "assistant", "content": "Previous response"}
        ]

        response = chat_service.get_response("New message", history)
        assert response == "Response with history"

    @patch("src.chat_service.openai.ChatCompletion.create")
    def test_get_response_authentication_error(self, mock_create, chat_service):
        """Test handling of authentication error."""
        mock_create.side_effect = Exception("Invalid API key")

        with pytest.raises(RuntimeError):
            chat_service.get_response("Hello")
