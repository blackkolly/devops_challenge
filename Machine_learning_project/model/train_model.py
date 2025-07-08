# train_model.py
# Example: Train and save a simple model (Iris dataset)
import pickle
from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier

X, y = load_iris(return_X_y=True)
model = RandomForestClassifier()
model.fit(X, y)

with open('model.pkl', 'wb') as f:
    pickle.dump(model, f)
