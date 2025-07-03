Project 1: Web Application Deployment
Tasks:

    Use Multi-Stage Builds to Optimize the Image

        Multi-stage builds help reduce the final image size by discarding unnecessary build dependencies.

        Example for a Flask app:
            project/
├── app/
│   ├── __init__.py
│   ├── models.py
│   ├── routes.py
│   └── ...
├── Dockerfile
├── requirements.txt
├── docker-compose.yml
└── .env (optional)

  mkdir app/ __init__.py
         app/routes.py
    app/__init__.py

from flask import Flask

def create_app():
    app = Flask(__name__)
    app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://user:password@db:5432/todo_db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    # Import and register routes
    from .routes import main
    app.register_blueprint(main)

    return app

app/routes.py:
from flask import Blueprint

main = Blueprint('main', __name__)

@main.route('/')
def index():
    return "Welcome to the Todo List App!"

@main.route('/health')
def health():
    return "OK", 200        
            
            
          # Stage 1: Build
Dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV FLASK_APP=app:create_app
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:create_app()"]

requirements.txt
DATABASE_URL=postgresql://user:password@db:5432/todo_db
# DATABASE_URL=mysql+mysqlconnector://user:password@db:3306/todo_db  # For MySQL
FLASK_ENV=development
SECRET_KEY=your_secret_key_here

docker-compose.yml file for deploying a Todo List Flask web application with PostgreSQL as the database. This setup includes the Flask app, PostgreSQL, health checks, 
logging, and multi-stage builds.

version: '3.8'

services:
  # Flask Web Application
  web:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: flask_app
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://user:password@db:5432/todo_db
      - FLASK_ENV=development
    depends_on:
      - db
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # PostgreSQL Database
  db:
    image: postgres:13
    container_name: postgres_db
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: todo_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d todo_db"]
      interval: 10s
      timeout: 5s
      retries: 5
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  postgres_data:


docker-compose up --build

Access the Flask app at http://localhost:5000.

Check the health of the services:

docker-compose ps

Stop the services:

docker-compose down


### Project 2: API with Load Balancer

#### Overview
This project involves building a REST API using **FastAPI** or **Express.js**, deploying it with **Docker Swarm** for scaling, and using **Nginx** as a reverse proxy for load balancing. Additionally, you'll monitor the system using **Prometheus** and **Grafana** and secure the API endpoints with authentication.

---

#### Step-by-Step Implementation

1. **Build the REST API**  
   - Use **FastAPI** (Python) or **Express.js** (Node.js) to create a simple REST API with endpoints like:
     - `GET /health` (for health checks)
     - `GET /data` (to return some sample data)
     - `POST /data` (to accept data)
   - Example FastAPI code:
     ```python
     from fastapi import FastAPI

     app = FastAPI()

     @app.get("/health")
     def health():
         return {"status": "healthy"}

     @app.get("/data")
     def get_data():
         return {"data": "Sample data"}

     @app.post("/data")
     def post_data(payload: dict):
         return {"received": payload}
     ```

2. **Dockerize the API**  
   - Create a `Dockerfile` using **multi-stage builds** for efficiency:
     ```dockerfile
     # Stage 1: Build
     FROM python:3.9-slim as builder
     WORKDIR /app
     COPY requirements.txt .
     RUN pip install --user -r requirements.txt

     # Stage 2: Run
     FROM python:3.9-slim
     WORKDIR /app
     COPY --from=builder /root/.local /root/.local
     COPY . .
     CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
     ```

3. **Set Up Docker Swarm**  
   - Initialize Docker Swarm:
     ```bash
     docker swarm init
     ```
   - Deploy the API as a service with multiple replicas:
     ```bash
     docker service create --name api --replicas 3 -p 8000:8000 your-docker-image
     ```

4. **Deploy Nginx as a Reverse Proxy**  
   - Create an `nginx.conf` file to load balance traffic:
     ```nginx
     events {}
     http {
         upstream api {
             server api:8000;
         }
         server {
             listen 80;
             location / {
                 proxy_pass http://api;
             }
         }
     }
     ```
   - Deploy Nginx using Docker:
     ```bash
     docker run -d --name nginx -p 80:80 -v /path/to/nginx.conf:/etc/nginx/nginx.conf nginx
     ```

5. **Monitor with Prometheus and Grafana**  
   - Set up Prometheus to scrape metrics from the API and Nginx.
   - Use Grafana to visualize the metrics.
   - Example Prometheus configuration (`prometheus.yml`):
     ```yaml
     global:
       scrape_interval: 15s
     scrape_configs:
       - job_name: 'api'
         static_configs:
           - targets: ['api:8000']
       - job_name: 'nginx'
         static_configs:
           - targets: ['nginx:80']
     ```

6. **Secure API Endpoints**  
   - Implement authentication using **JWT** (JSON Web Tokens) or **OAuth2**.
   - Example for FastAPI:
     ```python
     from fastapi import Depends, HTTPException
     from fastapi.security import OAuth2PasswordBearer

     oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

     async def get_current_user(token: str = Depends(oauth2_scheme)):
         if token != "valid-token":
             raise HTTPException(status_code=401, detail="Invalid token")
         return {"user": "authenticated"}
     ```

---

### Project 3: Log Monitoring System

#### Overview
This project involves setting up a centralized logging system using the **ELK Stack** (Elasticsearch, Logstash, Kibana). You'll stream logs from a running container, parse them, and visualize them in Kibana.

---

#### Step-by-Step Implementation

1. **Set Up ELK Stack with Docker Compose**  
   - Create a `docker-compose.yml` file:
     ```yaml
     version: '3'
     services:
       elasticsearch:
         image: docker.elastic.co/elasticsearch/elasticsearch:7.10.0
         environment:
           - discovery.type=single-node
         ports:
           - "9200:9200"
       logstash:
         image: docker.elastic.co/logstash/logstash:7.10.0
         volumes:
           - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
         ports:
           - "5000:5000"
         depends_on:
           - elasticsearch
       kibana:
         image: docker.elastic.co/kibana/kibana:7.10.0
         ports:
           - "5601:5601"
         depends_on:
           - elasticsearch
     ```

2. **Configure Logstash**  
   - Create a `logstash.conf` file to parse logs:
     ```plaintext
     input {
       tcp {
         port => 5000
         codec => json
       }
     }
     output {
       elasticsearch {
         hosts => ["elasticsearch:9200"]
       }
     }
     ```

3. **Stream Logs from a Running Container**  
   - Deploy an app that writes logs to a mounted Docker volume.
   - Example `docker-compose.yml` for the app:
     ```yaml
     version: '3'
     services:
       app:
         image: your-app-image
         volumes:
           - ./logs:/app/logs
         logging:
           driver: "syslog"
           options:
             syslog-address: "tcp://logstash:5000"
     ```

4. **Visualize Logs in Kibana**  
   - Access Kibana at `http://localhost:5601`.
   - Create an index pattern in Kibana to visualize logs from Elasticsearch.

5. **Deploy an App That Writes Logs**  
   - Example Python app that writes logs:
     ```python
     import logging
     import time

     logging.basicConfig(filename='/app/logs/app.log', level=logging.INFO)

     while True:
         logging.info("This is a log message")
         time.sleep(5)
     ```

---

### Tools and Technologies Used
- **FastAPI/Express.js**: For building the REST API.
- **Docker Swarm**: For scaling API replicas.
- **Nginx**: For load balancing.
- **Prometheus & Grafana**: For monitoring.
- **ELK Stack**: For log monitoring and visualization.
- **JWT/OAuth2**: For securing API endpoints.

Let me know if you need further clarification or assistance! 🚀
