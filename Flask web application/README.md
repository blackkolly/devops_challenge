# Flask E-Commerce Application

A complete e-commerce web application built with Flask, featuring user authentication, product catalog, shopping cart, and order management.

## Features

- **User Authentication**: Registration, login, and session management
- **Product Catalog**: Browse products by category, search functionality
- **Shopping Cart**: Add/remove items, persistent cart sessions
- **Order Management**: Place orders, view order history
- **Responsive Design**: Mobile-friendly Bootstrap UI
- **RESTful API**: Product API endpoints
- **Health Checks**: Application monitoring endpoint

## Tech Stack

- **Backend**: Python Flask
- **Database**: SQLite (easily changeable to PostgreSQL/MySQL)
- **Frontend**: HTML5, CSS3, Bootstrap 5, JavaScript
- **Testing**: pytest, pytest-flask, pytest-cov
- **Containerization**: Docker, Docker Compose
- **CI/CD**: Jenkins
- **Deployment**: AWS EC2, Nginx

## Quick Start

### Local Development

1. Clone the repository:
```bash
git clone <repository-url>
cd flask-ecommerce
```

2. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Run the application:
```bash
python app.py
```

5. Open browser and navigate to `http://localhost:5000`

### Docker Development

1. Build and run with Docker Compose:
```bash
docker-compose up --build
```

2. Access the application at `http://localhost`

## Testing

Run all tests:
```bash
pytest tests/ -v
```

Run tests with coverage:
```bash
pytest tests/ -v --cov=app --cov-report=html
```

## Project Structure

```
flask-ecommerce/
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── Dockerfile            # Docker configuration
├── docker-compose.yml    # Multi-container setup
├── Jenkinsfile           # CI/CD pipeline
├── nginx.conf            # Nginx configuration
├── templates/            # HTML templates
│   ├── base.html
│   ├── home.html
│   ├── products.html
│   ├── cart.html
│   └── ...
├── static/               # Static files
│   ├── css/
│   ├── js/
│   └── images/
└── tests/                # Test files
    ├── conftest.py
    ├── test_app.py
    └── test_database.py
```

## API Endpoints

- `GET /` - Home page
- `GET /products` - Product listing
- `GET /product/<id>` - Product details
- `POST /register` - User registration
- `POST /login` - User login
- `GET /cart` - Shopping cart
- `POST /checkout` - Place order
- `GET /api/products` - Products API
- `GET /health` - Health check

## Environment Variables

- `SECRET_KEY` - Flask secret key for sessions
- `FLASK_ENV` - Environment (development/production)
- `PORT` - Application port (default: 5000)
- `DATABASE` - Database file path

## Deployment

### AWS EC2 Deployment

1. Launch EC2 instance (Ubuntu 20.04 recommended)
2. Install Docker and Docker Compose
3. Clone the repository
4. Set environment variables
5. Run with Docker Compose:

```bash
export SECRET_KEY="your-production-secret-key"
docker-compose up -d
```

### CI/CD Pipeline

The Jenkins pipeline includes:
- Code checkout
- Dependency installation
- Linting (flake8)
- Unit tests (pytest)
- Security scanning (bandit, safety)
- Docker image building
- Staging deployment
- Integration tests
- Production deployment (manual approval)
- Smoke tests
- Automated rollback on failure

## Database Schema

### Users
- id (PRIMARY KEY)
- username (UNIQUE)
- email (UNIQUE)
- password_hash
- created_at

### Products
- id (PRIMARY KEY)
- name
- description
- price
- stock
- category
- image_url
- created_at

### Orders
- id (PRIMARY KEY)
- user_id (FOREIGN KEY)
- total_amount
- status
- created_at

### Order Items
- id (PRIMARY KEY)
- order_id (FOREIGN KEY)
- product_id (FOREIGN KEY)
- quantity
- price

## Security Features

- Password hashing with Werkzeug
- Session management
- Input validation
- SQL injection prevention
- XSS protection
- CSRF protection (can be enhanced)

## Performance Considerations

- Database indexing on frequently queried fields
- Static file caching with Nginx
- Docker multi-stage builds
- Gunicorn WSGI server for production
- Container health checks

## Monitoring and Logging

- Health check endpoint (`/health`)
- Application logging
- Docker container health checks
- Nginx access logs
- Error tracking and alerting

## Future Enhancements

- Payment gateway integration
- Product image uploads
- Advanced search and filtering
- Product reviews and ratings
- Admin dashboard
- Email notifications
- Redis caching
- PostgreSQL/MySQL support
- Kubernetes deployment
- Prometheus monitoring

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and add tests
4. Run tests and ensure they pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository.
