🔹 Challenge 1: Convert an existing Dockerfile into a multi-stage build and compare image sizes.

Multi-Stage Dockerfile:
Dockerfile
Copy

# Stage 1: Build stage
FROM python:3.9 as builder

# Set working directory
WORKDIR /app

# Copy requirements first to leverage Docker layer caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Stage 2: Final stage
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /app /app
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages

# Expose port 5000
EXPOSE 5000

# Run the Flask app
CMD ["python", "app.py"]

Comparison:

    Single-stage image size: Likely larger because it includes build tools and dependencies.

    Multi-stage image size: Smaller because it only includes the runtime dependencies and application code.

To compare sizes:

    Build both images:
    bash
    Copy

    docker build -t single-stage -f Dockerfile.single .
    docker build -t multi-stage -f Dockerfile.multi .

    Check image sizes:
    bash
    Copy

    docker images

🔹 Challenge 2: Run a lightweight Alpine-based container.

For a Python app:
bash
Copy

docker run -it --rm python:3.9-alpine sh

For a Node.js app:
bash
Copy

docker run -it --rm node:14-alpine sh

Alpine-based images are significantly smaller than their default counterparts.

🔹 Challenge 3: Add a HEALTHCHECK in a Dockerfile for a web application.

Add this to your Dockerfile:
Dockerfile
Copy

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:5000/ || exit 1

This checks the health of the web app every 30 seconds using curl.

🔹 Challenge 4: Run a container without root privileges.

Modify your Dockerfile:
Dockerfile
Copy

# Add a non-root user
RUN adduser -D myuser
USER myuser

# Ensure the app runs correctly
CMD ["python", "app.py"]

Run the container:
bash
Copy

docker run --user myuser <image-name>

🔹 Challenge 5: Scan your Docker image using docker scan or Trivy.

Using docker scan:
bash
Copy

docker scan <image-name>

Using Trivy:
bash
Copy

trivy image <image-name>

Fix vulnerabilities by updating dependencies or base images.

🔹 Challenge 6: Implement log management by redirecting container logs to a file.

Run the container with log redirection:
bash
Copy

docker run <image-name> > app.log 2>&1

Or use Docker's logging driver:
bash
Copy

docker run --log-driver=json-file --log-opt max-size=10m <image-name>

🔹 Challenge 7: Set up resource limits (memory, CPU) for a container.

Run the container with resource limits:
bash
Copy

docker run --memory="512m" --cpus="1.5" <image-name>

🔹 Challenge 8: Use docker build --progress=plain to analyze layer caching and optimize the build process.

Build the image with plain progress output:
bash
Copy

docker build --progress=plain -t <image-name> .

