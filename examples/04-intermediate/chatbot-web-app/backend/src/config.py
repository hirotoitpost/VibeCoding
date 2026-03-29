"""
Configuration module for the chatbot backend.
"""
import os
from dotenv import load_dotenv

load_dotenv()

# Chatbot Configuration
MAX_TOKENS = 2048
TEMPERATURE = 0.7
CHATBOT_MODE = "MOCK"  # Using Mock responses for demonstration

# Flask Configuration
DEBUG = os.getenv("FLASK_DEBUG", "False") == "True"
HOST = os.getenv("FLASK_HOST", "0.0.0.0")
PORT = int(os.getenv("FLASK_PORT", 5000))
