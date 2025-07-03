from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, session
from werkzeug.security import generate_password_hash, check_password_hash
import sqlite3
import os
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')

# Database configuration
DATABASE = 'ecommerce.db'

def get_db_connection():
    """Get database connection"""
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    """Initialize database with tables"""
    conn = get_db_connection()
    
    # Users table
    conn.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Products table
    conn.execute('''
        CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            price REAL NOT NULL,
            stock INTEGER DEFAULT 0,
            category TEXT,
            image_url TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Orders table
    conn.execute('''
        CREATE TABLE IF NOT EXISTS orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            total_amount REAL NOT NULL,
            status TEXT DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    ''')
    
    # Order items table
    conn.execute('''
        CREATE TABLE IF NOT EXISTS order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER,
            product_id INTEGER,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            FOREIGN KEY (order_id) REFERENCES orders (id),
            FOREIGN KEY (product_id) REFERENCES products (id)
        )
    ''')
    
    # Insert sample products
    sample_products = [
        ('Laptop', 'High-performance laptop for professionals', 999.99, 10, 'Electronics', '/static/images/laptop.jpg'),
        ('Smartphone', 'Latest smartphone with advanced features', 699.99, 15, 'Electronics', '/static/images/phone.jpg'),
        ('Headphones', 'Wireless noise-canceling headphones', 199.99, 20, 'Electronics', '/static/images/headphones.jpg'),
        ('Coffee Mug', 'Premium ceramic coffee mug', 19.99, 50, 'Home', '/static/images/mug.jpg'),
        ('T-Shirt', 'Comfortable cotton t-shirt', 29.99, 30, 'Clothing', '/static/images/tshirt.jpg')
    ]
    
    for product in sample_products:
        conn.execute('''
            INSERT OR IGNORE INTO products (name, description, price, stock, category, image_url)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', product)
    
    conn.commit()
    conn.close()
    logger.info("Database initialized successfully")

@app.route('/')
def home():
    """Home page with featured products"""
    try:
        conn = get_db_connection()
        products = conn.execute('SELECT * FROM products LIMIT 6').fetchall()
        conn.close()
        return render_template('home.html', products=products)
    except sqlite3.OperationalError as e:
        logger.error(f"Database error in home route: {e}")
        # Try to initialize database and retry
        init_db()
        try:
            conn = get_db_connection()
            products = conn.execute('SELECT * FROM products LIMIT 6').fetchall()
            conn.close()
            return render_template('home.html', products=products)
        except Exception as e2:
            logger.error(f"Failed to recover from database error: {e2}")
            return render_template('home.html', products=[])
    except Exception as e:
        logger.error(f"Unexpected error in home route: {e}")
        return render_template('home.html', products=[])

@app.route('/products')
def products():
    """All products page with filtering"""
    category = request.args.get('category')
    search = request.args.get('search')
    
    conn = get_db_connection()
    query = 'SELECT * FROM products WHERE 1=1'
    params = []
    
    if category:
        query += ' AND category = ?'
        params.append(category)
    
    if search:
        query += ' AND (name LIKE ? OR description LIKE ?)'
        params.extend([f'%{search}%', f'%{search}%'])
    
    products = conn.execute(query, params).fetchall()
    categories = conn.execute('SELECT DISTINCT category FROM products').fetchall()
    conn.close()
    
    return render_template('products.html', products=products, categories=categories)

@app.route('/product/<int:product_id>')
def product_detail(product_id):
    """Product detail page"""
    conn = get_db_connection()
    product = conn.execute('SELECT * FROM products WHERE id = ?', (product_id,)).fetchone()
    conn.close()
    
    if product is None:
        flash('Product not found', 'error')
        return redirect(url_for('products'))
    
    return render_template('product_detail.html', product=product)

@app.route('/register', methods=['GET', 'POST'])
def register():
    """User registration"""
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        password = request.form['password']
        
        if not all([username, email, password]):
            flash('All fields are required', 'error')
            return render_template('register.html')
        
        conn = get_db_connection()
        
        # Check if user already exists
        existing_user = conn.execute(
            'SELECT id FROM users WHERE username = ? OR email = ?',
            (username, email)
        ).fetchone()
        
        if existing_user:
            flash('Username or email already exists', 'error')
            conn.close()
            return render_template('register.html')
        
        # Create new user
        password_hash = generate_password_hash(password)
        conn.execute(
            'INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)',
            (username, email, password_hash)
        )
        conn.commit()
        conn.close()
        
        flash('Registration successful! Please log in.', 'success')
        return redirect(url_for('login'))
    
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    """User login"""
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        conn = get_db_connection()
        user = conn.execute(
            'SELECT * FROM users WHERE username = ?', (username,)
        ).fetchone()
        conn.close()
        
        if user and check_password_hash(user['password_hash'], password):
            session['user_id'] = user['id']
            session['username'] = user['username']
            flash('Login successful!', 'success')
            return redirect(url_for('home'))
        else:
            flash('Invalid username or password', 'error')
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    """User logout"""
    session.clear()
    flash('You have been logged out', 'info')
    return redirect(url_for('home'))

@app.route('/cart')
def cart():
    """Shopping cart page"""
    if 'cart' not in session:
        session['cart'] = []
    
    cart_items = []
    total = 0
    
    if session['cart']:
        conn = get_db_connection()
        cart_ids = [item['product_id'] for item in session['cart']]
        placeholders = ','.join('?' * len(cart_ids))
        products = conn.execute(
            f'SELECT * FROM products WHERE id IN ({placeholders})', cart_ids
        ).fetchall()
        conn.close()
        
        for cart_item in session['cart']:
            for product in products:
                if product['id'] == cart_item['product_id']:
                    item_total = product['price'] * cart_item['quantity']
                    cart_items.append({
                        'product': product,
                        'quantity': cart_item['quantity'],
                        'total': item_total
                    })
                    total += item_total
                    break
    
    return render_template('cart.html', cart_items=cart_items, total=total)

@app.route('/add_to_cart/<int:product_id>')
def add_to_cart(product_id):
    """Add product to cart"""
    if 'cart' not in session:
        session['cart'] = []
    
    # Check if product exists
    conn = get_db_connection()
    product = conn.execute('SELECT * FROM products WHERE id = ?', (product_id,)).fetchone()
    conn.close()
    
    if not product:
        flash('Product not found', 'error')
        return redirect(url_for('products'))
    
    # Check if product already in cart
    for item in session['cart']:
        if item['product_id'] == product_id:
            item['quantity'] += 1
            break
    else:
        session['cart'].append({'product_id': product_id, 'quantity': 1})
    
    session.modified = True
    flash(f'{product["name"]} added to cart!', 'success')
    return redirect(url_for('products'))

@app.route('/remove_from_cart/<int:product_id>')
def remove_from_cart(product_id):
    """Remove product from cart"""
    if 'cart' in session:
        session['cart'] = [item for item in session['cart'] if item['product_id'] != product_id]
        session.modified = True
        flash('Item removed from cart', 'info')
    
    return redirect(url_for('cart'))

@app.route('/checkout', methods=['GET', 'POST'])
def checkout():
    """Checkout process"""
    if 'user_id' not in session:
        flash('Please log in to checkout', 'error')
        return redirect(url_for('login'))
    
    if 'cart' not in session or not session['cart']:
        flash('Your cart is empty', 'error')
        return redirect(url_for('cart'))
    
    if request.method == 'POST':
        # Process order
        conn = get_db_connection()
        
        # Calculate total
        cart_items = session['cart']
        cart_ids = [item['product_id'] for item in cart_items]
        placeholders = ','.join('?' * len(cart_ids))
        products = conn.execute(
            f'SELECT * FROM products WHERE id IN ({placeholders})', cart_ids
        ).fetchall()
        
        total_amount = 0
        order_items = []
        
        for cart_item in cart_items:
            for product in products:
                if product['id'] == cart_item['product_id']:
                    item_total = product['price'] * cart_item['quantity']
                    total_amount += item_total
                    order_items.append({
                        'product_id': product['id'],
                        'quantity': cart_item['quantity'],
                        'price': product['price']
                    })
                    break
        
        # Create order
        cursor = conn.execute(
            'INSERT INTO orders (user_id, total_amount) VALUES (?, ?)',
            (session['user_id'], total_amount)
        )
        order_id = cursor.lastrowid
        
        # Add order items
        for item in order_items:
            conn.execute(
                'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)',
                (order_id, item['product_id'], item['quantity'], item['price'])
            )
        
        conn.commit()
        conn.close()
        
        # Clear cart
        session['cart'] = []
        session.modified = True
        
        flash('Order placed successfully!', 'success')
        return redirect(url_for('order_confirmation', order_id=order_id))
    
    return render_template('checkout.html')

@app.route('/order_confirmation/<int:order_id>')
def order_confirmation(order_id):
    """Order confirmation page"""
    if 'user_id' not in session:
        flash('Access denied', 'error')
        return redirect(url_for('home'))
    
    conn = get_db_connection()
    order = conn.execute(
        'SELECT * FROM orders WHERE id = ? AND user_id = ?',
        (order_id, session['user_id'])
    ).fetchone()
    conn.close()
    
    if not order:
        flash('Order not found', 'error')
        return redirect(url_for('home'))
    
    return render_template('order_confirmation.html', order=order)

@app.route('/orders')
def orders():
    """User's order history"""
    if 'user_id' not in session:
        flash('Please log in to view orders', 'error')
        return redirect(url_for('login'))
    
    conn = get_db_connection()
    orders = conn.execute(
        'SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC',
        (session['user_id'],)
    ).fetchall()
    conn.close()
    
    return render_template('orders.html', orders=orders)

@app.route('/api/products')
def api_products():
    """API endpoint for products"""
    conn = get_db_connection()
    products = conn.execute('SELECT * FROM products').fetchall()
    conn.close()
    
    return jsonify([dict(product) for product in products])

@app.route('/health')
def health_check():
    """Health check endpoint for monitoring"""
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})

@app.errorhandler(404)
def not_found(error):
    """404 error handler"""
    return render_template('404.html'), 404

@app.errorhandler(500)
def internal_error(error):
    """500 error handler"""
    logger.error(f"Internal server error: {error}")
    return render_template('500.html'), 500

# Initialize database when app starts
def init_db_if_needed():
    """Initialize database if it doesn't exist or is empty"""
    try:
        conn = get_db_connection()
        # Check if tables exist
        tables = conn.execute(
            "SELECT name FROM sqlite_master WHERE type='table'"
        ).fetchall()
        conn.close()
        
        if not tables:
            logger.info("Database is empty, initializing...")
            init_db()
    except Exception as e:
        logger.info(f"Database needs initialization: {e}")
        init_db()

# Initialize database on app startup
try:
    init_db_if_needed()
except Exception as e:
    logger.error(f"Failed to initialize database: {e}")

if __name__ == '__main__':
    init_db()
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)
