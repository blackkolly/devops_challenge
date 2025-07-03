#!/usr/bin/env python3
"""
Simple startup script for the Flask E-Commerce application
"""
import sys
import os

# Add the current directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    from app import app, init_db
    print("Flask app imported successfully!")
    print("Initializing database...")
    init_db()
    print("Database initialized!")
    print("Starting Flask application on http://localhost:5000")
    print("Press Ctrl+C to stop the server")
    app.run(host='0.0.0.0', port=5000, debug=True)
except ImportError as e:
    print(f"Error importing Flask app: {e}")
    sys.exit(1)
except KeyboardInterrupt:
    print("\nApplication stopped by user")
    sys.exit(0)
except Exception as e:
    print(f"Error starting application: {e}")
    sys.exit(1)
