# ML Model A/B Testing Platform

This project is a full MLOps pipeline for an Iris classification model, featuring model training, API serving, Streamlit UI, A/B testing, monitoring, batch prediction, user feedback, and a modern web UI. It is containerized with Docker Compose and ready for CI/CD, cloud, and monitoring integrations.

---

## Features

- **Model Training**: Trains a RandomForest model on the Iris dataset and saves as `model.pkl`.
- **Flask API**: Serves predictions and Prometheus metrics.
- **Streamlit UI**: Modern dashboard for single/batch prediction, A/B testing, feedback, and visualization.
- **A/B Testing Router**: Routes prediction requests to different model versions for experimentation.
- **Monitoring**: Prometheus metrics endpoint for API monitoring.
- **Batch Prediction**: Upload CSV for multiple predictions.
- **User Feedback**: Collects and displays user feedback on predictions.
- **Modern UI**: Custom CSS, logo, and dashboard header.
- **Docker Compose**: All services run together with simple commands.

---

## Project Structure

```
machine_learning_project/
├── model/
│   ├── train_model.py
│   └── model.pkl
├── flask_api/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── streamlit_app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── ab_testing/
│   ├── router.py
│   └── Dockerfile
├── monitoring/
│   └── prometheus.yml
├── jenkins/
│   └── Jenkinsfile
├── terraform/
│   └── main.tf
├── docker-compose.yml
└── README.md
```

---

## Quick Start (Local Docker Compose)

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd machine_learning_project
   ```

2. **Build and start all services**
   ```bash
   docker-compose up --build
   ```
   This will start:
   - Flask API (http://localhost:5000)
   - Streamlit UI (http://localhost:8501)
   - A/B Testing Router (internal, port 7000)
   - Prometheus (if configured)

3. **Access the Streamlit UI**
   Open your browser and go to: [http://localhost:8501](http://localhost:8501)

---

## How It Works

- **Single Prediction**: Enter 4 comma-separated numbers (Iris features) in the input box and click "Predict". The request is routed (A/B/Default) and the prediction, probabilities, and feature importances are displayed.
- **Batch Prediction**: Upload a CSV file (no header, 4 columns per row) for multiple predictions at once.
- **A/B Testing**: Select model version (A, B, or Random) to test different models or let the router decide.
- **User Feedback**: After each prediction, provide feedback (Yes/No) to help improve the model.
- **Recent Predictions**: View a log of recent predictions and feedback at the bottom of the dashboard.

---

## Example Input Values

You can use these values for single or batch prediction:

```
5.1,3.5,1.4,0.2
7.0,3.2,4.7,1.4
6.3,3.3,6.0,2.5
```

- **Single Prediction**: Paste one line (e.g., `5.1,3.5,1.4,0.2`) into the input box and click Predict.
- **Batch Prediction**: Save all three lines in a CSV file (no header) and upload it.

---

## Implementation Steps

1. **Model Training**: `model/train_model.py` trains and saves the model as `model.pkl`.
2. **Flask API**: `flask_api/app.py` loads the model and exposes `/predict` and `/metrics` endpoints.
3. **A/B Testing Router**: `ab_testing/router.py` routes prediction requests to different model versions (mock or real).
4. **Streamlit UI**: `streamlit_app/app.py` provides a modern dashboard for interacting with the model, batch prediction, and feedback.
5. **Docker Compose**: `docker-compose.yml` defines all services and their networking.
6. **Monitoring**: Prometheus scrapes metrics from the Flask API.
7. **CI/CD & Cloud**: Jenkins and Terraform files are provided for further automation and cloud deployment (optional).

---

## Customization

- To change the logo, update the image URL in `streamlit_app/app.py`.
- To add new models or A/B logic, update `ab_testing/router.py` and retrain as needed.
- For cloud deployment, use the provided Jenkins and Terraform templates.

---

## Troubleshooting

- If you see port conflicts, change the ports in `docker-compose.yml`.
- If a service fails to start, check its logs with `docker-compose logs <service>`.
- For UI/networking issues, ensure Docker Desktop is running and ports are not blocked by a firewall.

---

## Credits

- Built with Python, Flask, Streamlit, Docker, Prometheus, Jenkins, and Terraform.
- UI icons from Flaticon.

---

For questions or contributions, please open an issue or pull request!
# Machine Learning MLOps Project

## Features
- Model training and serving (Flask API)
- Streamlit UI for testing
- Dockerized microservices
- Jenkins CI/CD pipeline
- AWS EKS deployment (Terraform)
- Prometheus monitoring
- A/B testing endpoint

## Quick Start (Local)
1. Train the model:
   ```bash
   cd model
   python train_model.py
   ```
2. Build and run all services:
   ```bash
   docker-compose up --build
   ```
3. Access:
   - Flask API: http://localhost:5000
   - Streamlit: http://localhost:8501
   - Prometheus: http://localhost:9090

## Jenkins & EKS
- See `jenkins/Jenkinsfile` and `terraform/main.tf` for pipeline and infra setup.

## A/B Testing
- POST to `/ab_predict` on the A/B router for model version routing.

## Monitoring
- Prometheus scrapes Flask API metrics at `/metrics`.

---
Expand each component for full production use (security, scaling, drift detection, etc).
