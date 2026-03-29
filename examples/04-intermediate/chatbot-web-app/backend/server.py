"""
Flask server for the chatbot application.
"""
from flask import Flask, request, jsonify
from flask_cors import CORS
from src.config import DEBUG, HOST, PORT
from src.chat_service import ChatService

app = Flask(__name__)
CORS(app)

# Initialize chat service
chat_service = ChatService()


@app.route("/api/health", methods=["GET"])
def health_check():
    """Health check endpoint."""
    return jsonify({"status": "ok", "message": "Server is running"}), 200


@app.route("/api/chat", methods=["POST"])
def chat():
    """
    Chat endpoint.
    
    Request body:
    {
        "message": "user message",
        "conversation_history": [
            {"role": "user", "content": "..."},
            {"role": "assistant", "content": "..."}
        ]
    }
    """
    try:
        data = request.get_json()

        if not data:
            return jsonify({"error": "No JSON data provided"}), 400

        user_message = data.get("message", "").strip()
        conversation_history = data.get("conversation_history", [])

        # Validate message
        if not chat_service.validate_message(user_message):
            return jsonify({"error": "Invalid message"}), 400

        # Get response from OpenAI
        response_text = chat_service.get_response(user_message, conversation_history)

        return jsonify(
            {
                "message": response_text,
                "success": True,
            }
        ), 200

    except ValueError as e:
        return jsonify({"error": str(e)}), 401
    except RuntimeError as e:
        return jsonify({"error": str(e)}), 503
    except Exception as e:
        return jsonify({"error": f"Unexpected error: {str(e)}"}), 500


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    return jsonify({"error": "Endpoint not found"}), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors."""
    return jsonify({"error": "Internal server error"}), 500


if __name__ == "__main__":
    app.run(host=HOST, port=PORT, debug=DEBUG)
