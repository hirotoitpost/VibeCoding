"""
Unit tests for ChatService (Mock mode)
"""
import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.chat_service import ChatService


def test_chat_service_initialization():
    """Test ChatService initializes correctly."""
    service = ChatService()
    assert service.max_tokens == 2048
    assert service.temperature == 0.7


def test_validate_message_empty():
    """Test message validation - empty message."""
    service = ChatService()
    assert service.validate_message("") == False
    assert service.validate_message("   ") == False


def test_validate_message_too_long():
    """Test message validation - message too long."""
    service = ChatService()
    long_message = "a" * 5000
    assert service.validate_message(long_message) == False


def test_validate_message_valid():
    """Test message validation - valid message."""
    service = ChatService()
    assert service.validate_message("Hello") == True
    assert service.validate_message("What is Vibe Coding?") == True


def test_mock_response_hello():
    """Test mock response for 'hello' keyword."""
    service = ChatService()
    response = service.get_response("hello")
    assert "👋 Hello" in response
    assert "Vibe Coding" in response


def test_mock_response_vibe_coding():
    """Test mock response for 'vibe coding' keyword."""
    service = ChatService()
    response = service.get_response("what is vibe coding?")
    assert "🎯 Vibe Coding" in response
    assert "learning project" in response


def test_mock_response_joke():
    """Test mock response for 'joke' keyword."""
    service = ChatService()
    response = service.get_response("tell me a joke")
    assert "😄" in response


def test_mock_response_help():
    """Test mock response for 'help' keyword."""
    service = ChatService()
    response = service.get_response("help")
    assert "📖" in response
    assert "I can help you with" in response


def test_mock_response_default():
    """Test default mock response for unknown keyword."""
    service = ChatService()
    response = service.get_response("unknown question xyz")
    assert "interesting question" in response
    assert "unknown question xyz" in response


def test_get_response_with_history():
    """Test get_response with conversation history."""
    service = ChatService()
    history = [
        {"role": "user", "content": "Hi"},
        {"role": "assistant", "content": "Hello!"}
    ]
    response = service.get_response("hello", history)
    assert len(response) > 0
    assert isinstance(response, str)


if __name__ == "__main__":
    # Simple test runner
    test_functions = [
        test_chat_service_initialization,
        test_validate_message_empty,
        test_validate_message_too_long,
        test_validate_message_valid,
        test_mock_response_hello,
        test_mock_response_vibe_coding,
        test_mock_response_joke,
        test_mock_response_help,
        test_mock_response_default,
        test_get_response_with_history,
    ]
    
    passed = 0
    failed = 0
    
    for test_func in test_functions:
        try:
            test_func()
            print(f"✅ {test_func.__name__}")
            passed += 1
        except AssertionError as e:
            print(f"❌ {test_func.__name__}: {str(e)}")
            failed += 1
        except Exception as e:
            print(f"⚠️ {test_func.__name__}: {str(e)}")
            failed += 1
    
    print(f"\n📊 Results: {passed} passed, {failed} failed")
