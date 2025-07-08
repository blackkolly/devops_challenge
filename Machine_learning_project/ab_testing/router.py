# router.py
# Simple A/B router for model versions
import random
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/ab_predict', methods=['POST'])
def ab_predict():
    data = request.json['data']
    # Randomly route to model A or B (expand as needed)
    model_version = random.choice(['A', 'B'])
    # Simulate a realistic response for Streamlit UI compatibility
    result = {
        'model_version': model_version,
        'prediction': 1,
        'class_name': 'versicolor',
        'probabilities': [0, 1, 0],
        'feature_importances': [0.1, 0.2, 0.3, 0.4]
    }
    return jsonify(result)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=7000)
