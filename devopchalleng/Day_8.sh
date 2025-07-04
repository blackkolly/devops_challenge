Challenge 1: Write a simple Dockerfile
Option 1: Running a Python script

Create a file named Dockerfile with the following content:
Dockerfile
Copy

# Use the official Python 3.9 image
FROM python:3.9

# Set the working directory
WORKDIR /app

# Copy the Python script into the container
COPY script.py .

# Run the Python script
CMD ["python", "script.py"]

Create a simple Python script named script.py:
python
Copy

print("Hello from Docker!")

Option 2: Serving a static HTML page using Nginx

Create a file named Dockerfile with the following content:
Dockerfile
Copy

# Use the official Nginx image
FROM nginx:alpine

# Copy the static HTML file to the Nginx web root
COPY index.html /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

Create a simple index.html file:
html
Copy

<!DOCTYPE html>
<html>
<head>
    <title>Hello Docker</title>
</head>
<body>
    <h1>Hello from Nginx in Docker!</h1>
</body>
</html>

Run HTML

Challenge 2: Build a Docker image


Run the following command in the directory containing your Dockerfile:
bash
Copy

docker build -t myapp:v1 .

This builds the Docker image and tags it as myapp:v1.

Challenge 3: Run a container and test the app

For the Python script:
bash
Copy

docker run myapp:v1

You should see the output: Hello from Docker!
For the Nginx server:
bash
Copy

docker run -p 8080:80 myapp:v1

Open your browser and navigate to http://localhost:8080. You should see the HTML page.

Challenge 4: Push your Docker image to Docker Hub

    Log in to Docker Hub:
    bash
    Copy

    docker login

    Enter your Docker Hub username and password.

    Tag your image with your Docker Hub username:
    bash
    Copy

    docker tag myapp:v1 <your-dockerhub-username>/myapp:v1

    Push the image to Docker Hub:
    bash
    Copy

    docker push <your-dockerhub-username>/myapp:v1

Challenge 5: Enter a running container

    Start a container in detached mode:
    bash
    Copy

    docker run -d -p 8080:80 myapp:v1

    Get the container ID:
    bash
    Copy

    docker ps

    Enter the container using docker exec:
    bash
    Copy

    docker exec -it <container_id> bash

    Explore the container's filesystem and processes.

Challenge 6: Run a detached container, restart it, and check logs

    Run a detached container:
    bash
    Copy

    docker run -d -p 8080:80 myapp:v1

    Restart the container:
    bash
    Copy

    docker restart <container_id>

    Check the logs:
    bash
    Copy

    docker logs <container_id>
