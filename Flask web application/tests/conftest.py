import pytest
import os
import sys
import tempfile

# Add parent directory to path to import app module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import app as app_module

@pytest.fixture
def client():
    """Create a test client"""
    # Create a temporary database file
    db_fd, db_path = tempfile.mkstemp()
    
    # Store original DATABASE value
    original_database = app_module.DATABASE
    app_module.DATABASE = db_path
    
    app_module.app.config['TESTING'] = True
    app_module.app.config['SECRET_KEY'] = 'test-secret-key'
    
    try:
        with app_module.app.test_client() as client:
            with app_module.app.app_context():
                app_module.init_db()
            yield client
    finally:
        # Restore original DATABASE value
        app_module.DATABASE = original_database
        os.close(db_fd)
        os.unlink(db_path)

@pytest.fixture
def auth_client(client):
    """Create a client with an authenticated user"""
    # Register a test user
    client.post('/register', data={
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'testpassword'
    })
    
    # Login the test user
    client.post('/login', data={
        'username': 'testuser',
        'password': 'testpassword'
    })
    
    return client
