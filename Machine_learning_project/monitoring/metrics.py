# metrics.py
# Example: Custom Prometheus metrics for model monitoring
from prometheus_client import Counter, Histogram

prediction_counter = Counter('model_predictions_total', 'Total predictions made')
prediction_latency = Histogram('model_prediction_latency_seconds', 'Prediction latency')
