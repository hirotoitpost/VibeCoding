"""
Configuration module for the chatbot backend.
"""
import os
from dotenv import load_dotenv

load_dotenv()

# Google Generative AI (Gemini) Configuration
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
if not GOOGLE_API_KEY:
    raise ValueError("GOOGLE_API_KEY environment variable not set")

MAX_TOKENS = 2048
TEMPERATURE = 0.7

# Flask Configuration
DEBUG = os.getenv("FLASK_DEBUG", "False") == "True"
HOST = os.getenv("FLASK_HOST", "0.0.0.0")
PORT = int(os.getenv("FLASK_PORT", 5000))
