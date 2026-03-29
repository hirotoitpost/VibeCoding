"""
Configuration module for the chatbot backend.
"""
import os
from dotenv import load_dotenv

load_dotenv()

# OpenAI API Configuration
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
if not OPENAI_API_KEY:
    raise ValueError("OPENAI_API_KEY environment variable not set")

OPENAI_MODEL = "gpt-3.5-turbo"
MAX_TOKENS = 2048
TEMPERATURE = 0.7

# Flask Configuration
DEBUG = os.getenv("FLASK_DEBUG", "False") == "True"
HOST = os.getenv("FLASK_HOST", "0.0.0.0")
PORT = int(os.getenv("FLASK_PORT", 5000))
