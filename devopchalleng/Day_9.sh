Challenge 1: Create a custom bridge network and connect two containers (alpine and nginx).
1.	Create a custom bridge network:
bash
Copy
docker network create my_bridge_network
2.	Run the alpine and nginx containers and connect them to the network:
bash
Copy
docker run -d --name alpine_container --network my_bridge_network alpine sleep 3600
docker run -d --name nginx_container --network my_bridge_network nginx
3.	Verify the containers are connected:
bash
Copy
docker network inspect my_bridge_network

Challenge 2: Run a MySQL container with a named volume (mysql_data) and confirm data persistence after container restart.

1.	Run the MySQL container with a named volume:
bash
Copy
docker run -d --name mysql_container -e MYSQL_ROOT_PASSWORD=mysecretpassword -v mysql_data:/var/lib/mysql mysql
2.	Restart the container and verify data persistence:
bash
Copy
docker restart mysql_container
docker exec -it mysql_container mysql -uroot -pmysecretpassword -e "SHOW DATABASES;"

Challenge 3: Create a docker-compose.yml file to launch a Flask API and a PostgreSQL database together.

1.	Create a docker-compose.yml file:
yaml
Copy
version: '3.8'
services:
  flask_app:
    image: my_flask_app_image
    build: ./flask_app
    ports:
      - "5000:5000"
    depends_on:
      - postgres_db
  postgres_db:
    image: postgres:latest
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydatabase
    volumes:
      - postgres_data:/var/lib/postgresql/data
volumes:
  postgres_data:
2.	Build and run the setup:
bash
Copy
docker-compose up -d

Challenge 4: Implement environment variables in your Docker Compose file to configure database credentials securely.

1.	Use environment variables in docker-compose.yml:
yaml
Copy
version: '3.8'
services:
  flask_app:
    image: my_flask_app_image
    build: ./flask_app
    ports:
      - "5000:5000"
    environment:
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
    depends_on:
      - postgres_db
  postgres_db:
    image: postgres:latest
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: mydatabase
    volumes:
      - postgres_data:/var/lib/postgresql/data
volumes:
  postgres_data:
2.	Create a .env file:
Copy
DB_USER=user
DB_PASSWORD=password
3.	Run the setup:
bash
Copy
docker-compose up -d

Challenge 5: Deploy a WordPress site using Docker Compose (WordPress + MySQL).

1.	Create a docker-compose.yml file:
yaml
Copy
version: '3.8'
services:
  wordpress:
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
    depends_on:
      - db
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
    volumes:
      - mysql_data:/var/lib/mysql
volumes:
  mysql_data:
2.	Run the setup:
bash
Copy
docker-compose up –d

🔹 Challenge 6: Create a multi-container setup where an Nginx container acts as a reverse proxy for a backend service.

1.	Create a docker-compose.yml file:
yaml
Copy
version: '3.8'
services:
  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - backend
  backend:
    image: my_backend_image
    expose:
      - "5000"
2.	Create an nginx.conf file:
nginx
Copy
events {}
http {
    server {
        listen 80;
        location / {
            proxy_pass http://backend:5000;
        }
    }
}
3.	Run the setup:
bash
Copy
docker-compose up –d


🔹 Challenge 7: Set up a network alias for a database container and connect an application container to it.

1.	Create a custom network:
bash
Copy
docker network create my_network
2.	Run the database container with a network alias:
bash
Copy
docker run -d --name db --network my_network --network-alias mydb mysql
3.	Run the application container and connect it to the network:
bash
Copy
docker run -d --name app --network my_network my_app_image

🔹 Challenge 8: Use docker inspect to check the assigned IP address of a running container and communicate with it manually.

1.	Inspect the container:
bash
Copy
docker inspect <container_id> | grep IPAddress
2.	Use the IP address to communicate with the container:
bash
Copy
curl <container_ip>:<port>


🔹 Challenge 9: Deploy a Redis-based caching system using Docker Compose with a Python or Node.js app.

1.	Create a docker-compose.yml file:
yaml
Copy
version: '3.8'
services:
  app:
    image: my_app_image
    ports:
      - "5000:5000"
    depends_on:
      - redis
  redis:
    image: redis:latest
2.	Run the setup:
bash
Copy
docker-compose up -d

🔹 Challenge 10: Implement container health checks in Docker Compose (healthcheck: section).

1.	Add a healthcheck section to your docker-compose.yml:
yaml
Copy
version: '3.8'
services:
  web:
    image: nginx:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3
2.	Run the setup and check health status:
bash
Copy
docker-compose up -d
docker ps --filter "health=healthy"





