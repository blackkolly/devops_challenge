import pytest
import sqlite3
import tempfile
import os
import app as app_module

@pytest.fixture
def db_connection():
    """Create a test database connection"""
    db_fd, db_path = tempfile.mkstemp()
    
    # Set up test database
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    
    # Temporarily change the DATABASE constant
    original_database = app_module.DATABASE
    app_module.DATABASE = db_path
    
    try:
        # Create tables using the init_db function
        app_module.init_db()
        
        # Return a fresh connection to the test database
        conn.close()
        conn = sqlite3.connect(db_path)
        conn.row_factory = sqlite3.Row
        
        yield conn
        
    finally:
        conn.close()
        app_module.DATABASE = original_database
        os.close(db_fd)
        os.unlink(db_path)

def test_database_initialization(db_connection):
    """Test that database tables are created properly"""
    cursor = db_connection.cursor()
    
    # Check if tables exist
    tables = cursor.execute(
        "SELECT name FROM sqlite_master WHERE type='table'"
    ).fetchall()
    
    table_names = [table['name'] for table in tables]
    
    assert 'users' in table_names
    assert 'products' in table_names
    assert 'orders' in table_names
    assert 'order_items' in table_names

def test_sample_products_inserted(db_connection):
    """Test that sample products are inserted"""
    cursor = db_connection.cursor()
    products = cursor.execute('SELECT COUNT(*) as count FROM products').fetchone()
    assert products['count'] >= 5  # We insert 5 sample products in init_db

def test_user_creation():
    """Test user creation in database"""
    db_fd, db_path = tempfile.mkstemp()
    
    try:
        conn = sqlite3.connect(db_path)
        conn.row_factory = sqlite3.Row
        
        # Create users table
        conn.execute('''
            CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE NOT NULL,
                email TEXT UNIQUE NOT NULL,
                password_hash TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Insert test user
        conn.execute(
            'INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)',
            ('testuser', 'test@example.com', 'hashed_password')
        )
        conn.commit()
        
        # Verify user was created
        user = conn.execute(
            'SELECT * FROM users WHERE username = ?', ('testuser',)
        ).fetchone()
        
        assert user is not None
        assert user['username'] == 'testuser'
        assert user['email'] == 'test@example.com'
        
    finally:
        conn.close()
        os.close(db_fd)
        os.unlink(db_path)

def test_product_queries():
    """Test product database queries"""
    db_fd, db_path = tempfile.mkstemp()
    
    try:
        conn = sqlite3.connect(db_path)
        conn.row_factory = sqlite3.Row
        
        # Create products table
        conn.execute('''
            CREATE TABLE products (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                price REAL NOT NULL,
                stock INTEGER DEFAULT 0,
                category TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Insert test products
        test_products = [
            ('Test Laptop', 'A test laptop', 999.99, 5, 'Electronics'),
            ('Test Phone', 'A test phone', 699.99, 10, 'Electronics'),
            ('Test Shirt', 'A test shirt', 29.99, 20, 'Clothing')
        ]
        
        for product in test_products:
            conn.execute(
                'INSERT INTO products (name, description, price, stock, category) VALUES (?, ?, ?, ?, ?)',
                product
            )
        conn.commit()
        
        # Test queries
        all_products = conn.execute('SELECT * FROM products').fetchall()
        assert len(all_products) == 3
        
        electronics = conn.execute(
            'SELECT * FROM products WHERE category = ?', ('Electronics',)
        ).fetchall()
        assert len(electronics) == 2
        
        search_results = conn.execute(
            'SELECT * FROM products WHERE name LIKE ?', ('%laptop%',)
        ).fetchall()
        assert len(search_results) == 1
        
    finally:
        conn.close()
        os.close(db_fd)
        os.unlink(db_path)

def test_order_creation():
    """Test order creation in database"""
    db_fd, db_path = tempfile.mkstemp()
    
    try:
        conn = sqlite3.connect(db_path)
        conn.row_factory = sqlite3.Row
        
        # Create necessary tables
        conn.execute('''
            CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE NOT NULL,
                email TEXT UNIQUE NOT NULL,
                password_hash TEXT NOT NULL
            )
        ''')
        
        conn.execute('''
            CREATE TABLE orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                total_amount REAL NOT NULL,
                status TEXT DEFAULT 'pending',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id)
            )
        ''')
        
        conn.execute('''
            CREATE TABLE order_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                order_id INTEGER,
                product_id INTEGER,
                quantity INTEGER NOT NULL,
                price REAL NOT NULL,
                FOREIGN KEY (order_id) REFERENCES orders (id)
            )
        ''')
        
        # Insert test user
        conn.execute(
            'INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)',
            ('testuser', 'test@example.com', 'hashed_password')
        )
        
        # Create test order
        cursor = conn.execute(
            'INSERT INTO orders (user_id, total_amount) VALUES (?, ?)',
            (1, 99.99)
        )
        order_id = cursor.lastrowid
        
        # Add order items
        conn.execute(
            'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)',
            (order_id, 1, 2, 49.99)
        )
        conn.commit()
        
        # Verify order was created
        order = conn.execute(
            'SELECT * FROM orders WHERE id = ?', (order_id,)
        ).fetchone()
        
        assert order is not None
        assert order['user_id'] == 1
        assert order['total_amount'] == 99.99
        assert order['status'] == 'pending'
        
        # Verify order items
        order_items = conn.execute(
            'SELECT * FROM order_items WHERE order_id = ?', (order_id,)
        ).fetchall()
        
        assert len(order_items) == 1
        assert order_items[0]['quantity'] == 2
        assert order_items[0]['price'] == 49.99
        
    finally:
        conn.close()
        os.close(db_fd)
        os.unlink(db_path)
