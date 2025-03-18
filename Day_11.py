Project 1: Web Application Deployment
Tasks:

    Use Multi-Stage Builds to Optimize the Image

        Multi-stage builds help reduce the final image size by discarding unnecessary build dependencies.

        Example for a Flask app:
          # Stage 1: Build
FROM python:3.9-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Stage 2: Final Image
FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
ENV FLASK_APP=app.py
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
