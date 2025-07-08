# app.py

from flask import Flask, request, jsonify
import pickle
import numpy as np
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

# Load model and class names
with open('model/model.pkl', 'rb') as f:
    model = pickle.load(f)
try:
    from sklearn.datasets import load_iris
    class_names = load_iris().target_names.tolist()
except Exception:
    class_names = ["setosa", "versicolor", "virginica"]


@app.route('/predict', methods=['POST'])
def predict():
    data = request.json['data']
    arr = np.array(data).reshape(1, -1)
    prediction = int(model.predict(arr)[0])
    probabilities = model.predict_proba(arr)[0].tolist()
    class_name = class_names[prediction] if prediction < len(class_names) else str(prediction)
    # Feature importances (if available)
    feature_importances = getattr(model, 'feature_importances_', None)
    if feature_importances is not None:
        feature_importances = feature_importances.tolist()
    return jsonify({
        'prediction': prediction,
        'class_name': class_name,
        'probabilities': probabilities,
        'feature_importances': feature_importances
    })

@app.route('/')
def home():
    return 'ML Model API is running!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
