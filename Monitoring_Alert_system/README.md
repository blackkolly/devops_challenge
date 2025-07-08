# Monitoring & Alert System for Flask App (Docker Compose)

This project provides a complete monitoring, logging, and alerting stack for a Flask web application using Docker Compose. It includes Prometheus, Grafana, ELK Stack, and Alertmanager.

## Prerequisites
- Docker & Docker Compose installed
- This directory contains:
  - `docker-compose.yml`
  - `prometheus.yml`
  - `alert.rules.yml`
  - `alertmanager.yml`
  - `logstash.conf`
  - Flask app source in `../flask web application`

## Steps to Deploy

1. **Build and Start All Services**
   ```bash
   cd monitoring_alert_system
   docker-compose up --build
   ```

2. **Access Service UIs**
   - **Flask App:** http://localhost:5000
   - **Prometheus:** http://localhost:9090
   - **Grafana:** http://localhost:3000 (login: admin / admin)
   - **Kibana:** http://localhost:5601
   - **Alertmanager:** http://localhost:9093
   - **Elasticsearch:** http://localhost:9200

3. **Configure Grafana**
   - Go to Configuration → Data Sources → Add data source → Prometheus
   - Set URL to `http://prometheus:9090` and Save & Test
   - Import or create dashboards for your metrics

4. **Prometheus Targets**
   - Visit http://localhost:9090/targets
   - Ensure `flask_app:5000` is listed and status is UP

5. **Metrics Endpoint**
   - Your Flask app must expose `/metrics` (using `prometheus_flask_exporter`)
   - Test: `curl http://localhost:5000/metrics`

6. **Troubleshooting**
   - If a service is not up, run `docker-compose ps` and `docker-compose logs <service>`
   - Ensure you run `docker-compose` from this directory
   - If ports are in use, change the host port in `docker-compose.yml`

7. **Stopping the Stack**
   ```bash
   docker-compose down
   ```

## Notes
- Alertmanager is pre-configured for PagerDuty (edit `alertmanager.yml` for your integration key)
- Logstash and Kibana are set up for log aggregation (configure your Flask app to send logs to Logstash if needed)
- All config files are mounted into their respective containers via volumes

---

**Enjoy full-stack monitoring and alerting for your Flask app!**
