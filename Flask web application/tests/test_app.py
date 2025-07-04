import pytest
import json
from tests.conftest import client, auth_client

def test_home_page(client):
    """Test the home page"""
    response = client.get('/')
    assert response.status_code == 200
    assert b'Welcome to Our Store' in response.data

def test_products_page(client):
    """Test the products page"""
    response = client.get('/products')
    assert response.status_code == 200
    assert b'All Products' in response.data

def test_product_detail(client):
    """Test product detail page"""
    response = client.get('/product/1')
    assert response.status_code == 200

def test_product_not_found(client):
    """Test product not found"""
    response = client.get('/product/999')
    assert response.status_code == 302  # Redirect to products page

def test_register_user(client):
    """Test user registration"""
    response = client.post('/register', data={
        'username': 'newuser',
        'email': 'newuser@example.com',
        'password': 'newpassword'
    })
    assert response.status_code == 302  # Redirect to login

def test_register_duplicate_user(client):
    """Test registering duplicate user"""
    # Register first user
    client.post('/register', data={
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'testpassword'
    })
    
    # Try to register same user again
    response = client.post('/register', data={
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'testpassword'
    })
    assert response.status_code == 200
    assert b'Username or email already exists' in response.data

def test_login_user(client):
    """Test user login"""
    # Register a user first
    client.post('/register', data={
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'testpassword'
    })
    
    # Login the user
    response = client.post('/login', data={
        'username': 'testuser',
        'password': 'testpassword'
    })
    assert response.status_code == 302  # Redirect to home

def test_login_invalid_user(client):
    """Test login with invalid credentials"""
    response = client.post('/login', data={
        'username': 'invaliduser',
        'password': 'invalidpassword'
    })
    assert response.status_code == 200
    assert b'Invalid username or password' in response.data

def test_logout_user(client):
    """Test user logout"""
    # Register and login user
    client.post('/register', data={
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'testpassword'
    })
    client.post('/login', data={
        'username': 'testuser',
        'password': 'testpassword'
    })
    
    # Logout
    response = client.get('/logout')
    assert response.status_code == 302  # Redirect to home

def test_add_to_cart(client):
    """Test adding product to cart"""
    response = client.get('/add_to_cart/1')
    assert response.status_code == 302  # Redirect to products

def test_cart_page(client):
    """Test cart page"""
    response = client.get('/cart')
    assert response.status_code == 200

def test_remove_from_cart(client):
    """Test removing product from cart"""
    # Add to cart first
    client.get('/add_to_cart/1')
    
    # Remove from cart
    response = client.get('/remove_from_cart/1')
    assert response.status_code == 302  # Redirect to cart

def test_checkout_not_logged_in(client):
    """Test checkout without being logged in"""
    response = client.get('/checkout')
    assert response.status_code == 302  # Redirect to login

def test_checkout_empty_cart(auth_client):
    """Test checkout with empty cart"""
    response = auth_client.get('/checkout')
    assert response.status_code == 302  # Redirect to cart

def test_checkout_with_items(auth_client):
    """Test checkout with items in cart"""
    # Add item to cart
    auth_client.get('/add_to_cart/1')
    
    # Access checkout
    response = auth_client.get('/checkout')
    assert response.status_code == 200

def test_place_order(auth_client):
    """Test placing an order"""
    # Add item to cart
    auth_client.get('/add_to_cart/1')
    
    # Place order
    response = auth_client.post('/checkout', data={
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
        'address': '123 Main St',
        'city': 'Anytown',
        'state': 'CA',
        'zip': '12345',
        'cardNumber': '1234567890123456',
        'expiryDate': '12/25',
        'cvv': '123',
        'cardName': 'John Doe'
    })
    assert response.status_code == 302  # Redirect to confirmation

def test_orders_page_not_logged_in(client):
    """Test orders page without being logged in"""
    response = client.get('/orders')
    assert response.status_code == 302  # Redirect to login

def test_orders_page_logged_in(auth_client):
    """Test orders page when logged in"""
    response = auth_client.get('/orders')
    assert response.status_code == 200

def test_api_products(client):
    """Test products API endpoint"""
    response = client.get('/api/products')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert isinstance(data, list)

def test_health_check(client):
    """Test health check endpoint"""
    response = client.get('/health')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['status'] == 'healthy'

def test_404_error(client):
    """Test 404 error page"""
    response = client.get('/nonexistent-page')
    assert response.status_code == 404

def test_product_search(client):
    """Test product search functionality"""
    response = client.get('/products?search=laptop')
    assert response.status_code == 200

def test_product_category_filter(client):
    """Test product category filtering"""
    response = client.get('/products?category=Electronics')
    assert response.status_code == 200

def test_session_cart_persistence(client):
    """Test that cart persists in session"""
    # Add item to cart
    client.get('/add_to_cart/1')
    
    # Check cart page
    response = client.get('/cart')
    assert response.status_code == 200
    
    # Add another item
    client.get('/add_to_cart/2')
    
    # Check cart again
    response = client.get('/cart')
    assert response.status_code == 200
