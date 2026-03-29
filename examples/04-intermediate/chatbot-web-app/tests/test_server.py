"""
Unit tests for Flask server endpoints.
"""
import pytest
import json
from unittest.mock import patch, MagicMock
from backend.server import app


@pytest.fixture
def client():
    """Create a test client for the Flask app."""
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


class TestEndpoints:
    """Tests for Flask endpoints."""

    def test_health_check(self, client):
        """Test health check endpoint."""
        response = client.get("/api/health")
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data["status"] == "ok"

    @patch("backend.server.chat_service.get_response")
    def test_chat_endpoint_success(self, mock_response, client):
        """Test chat endpoint with valid input."""
        mock_response.return_value = "AI response"

        response = client.post(
            "/api/chat",
            json={"message": "Hello", "conversation_history": []}
        )

        assert response.status_code == 200
        data = json.loads(response.data)
        assert data["success"] is True
        assert data["message"] == "AI response"

    def test_chat_endpoint_no_data(self, client):
        """Test chat endpoint with no JSON data."""
        response = client.post("/api/chat")
        assert response.status_code == 400
        data = json.loads(response.data)
        assert "error" in data

    def test_chat_endpoint_empty_message(self, client):
        """Test chat endpoint with empty message."""
        response = client.post(
            "/api/chat",
            json={"message": "", "conversation_history": []}
        )
        assert response.status_code == 400

    @patch("backend.server.chat_service.get_response")
    def test_chat_endpoint_with_history(self, mock_response, client):
        """Test chat endpoint with conversation history."""
        mock_response.return_value = "Response with history"

        history = [
            {"role": "user", "content": "Previous"},
            {"role": "assistant", "content": "Previous response"}
        ]

        response = client.post(
            "/api/chat",
            json={"message": "Follow-up", "conversation_history": history}
        )

        assert response.status_code == 200
        data = json.loads(response.data)
        assert data["message"] == "Response with history"

    def test_chat_endpoint_not_found(self, client):
        """Test 404 error handling."""
        response = client.get("/api/nonexistent")
        assert response.status_code == 404
        data = json.loads(response.data)
        assert "error" in data
