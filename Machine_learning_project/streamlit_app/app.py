
# app.py (Streamlit)

import streamlit as st
import requests
import pandas as pd


# --- Custom CSS for a modern look with theme and logo ---
st.set_page_config(page_title="ML Model A/B Testing", layout="centered", page_icon="🌸")
st.markdown(
    """
    <style>
    body {
        background: linear-gradient(120deg, #f5f7fa 0%, #c9e7ff 100%);
    }
    .main {
        background-color: #f5f7fa;
    }
    .stButton>button {
        color: white;
        background: linear-gradient(90deg, #0072ff 0%, #00c6ff 100%);
        border-radius: 8px;
        padding: 0.5em 2em;
        font-weight: bold;
        font-size: 1.1em;
        box-shadow: 0 2px 8px rgba(0,0,0,0.10);
        transition: 0.2s;
    }
    .stButton>button:hover {
        background: linear-gradient(90deg, #00c6ff 0%, #0072ff 100%);
        transform: scale(1.04);
    }
    .stRadio>div>label {
        font-weight: 600;
    }
    .stTextInput>div>input {
        border-radius: 8px;
        border: 1.5px solid #0072ff;
        padding: 0.5em;
        background: #fafdff;
    }
    .stDataFrame {
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    }
    .stMarkdown h1, .stMarkdown h2, .stMarkdown h3 {
        color: #0072ff;
    }
    .custom-header {
        display: flex;
        align-items: center;
        gap: 18px;
        margin-bottom: 0.5em;
    }
    .custom-logo {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        box-shadow: 0 2px 8px rgba(0,0,0,0.10);
        border: 2px solid #0072ff;
        background: #fff;
        object-fit: cover;
    }
    </style>
    """,
    unsafe_allow_html=True
)

# --- Logo and custom header ---
st.markdown(
    """
    <div class="custom-header">
        <img src="https://cdn-icons-png.flaticon.com/512/2721/2721297.png" class="custom-logo" alt="ML Logo">
        <div>
            <h2 style="margin-bottom:0;">🌸 ML Model A/B Testing Dashboard</h2>
            <div style="color:#0072ff;font-size:1.1em;">Interactive platform for Iris model A/B testing, batch prediction, and feedback</div>
        </div>
    </div>
    """,
    unsafe_allow_html=True
)



input_data = st.text_input('Input (comma-separated numbers):', help='Enter 4 numbers for a single prediction')
model_choice = st.radio('Select model version for A/B testing:', ['Random (A/B)', 'A', 'B', 'Default'], help='Random will let the router pick A or B')

# --- Batch Prediction ---
uploaded_file = st.file_uploader('Upload CSV for batch prediction (4 columns, no header)', type=['csv'])
if uploaded_file is not None:
    try:
        df = pd.read_csv(uploaded_file, header=None)
        st.write('Batch input preview:', df.head())
        batch_results = []
        for i, row in df.iterrows():
            data = row.values.tolist()
            try:
                if model_choice in ['A', 'B', 'Random (A/B)']:
                    ab_url = 'http://ab_testing:7000/ab_predict'
                    payload = {'data': data}
                    if model_choice != 'Random (A/B)':
                        payload['model_version'] = model_choice
                    response = requests.post(ab_url, json=payload, timeout=5)
                else:
                    response = requests.post('http://flask_api:5000/predict', json={'data': data}, timeout=5)
                result = response.json()
                batch_results.append({**result, 'input': data, 'model_used': result.get('model_version', model_choice)})
            except Exception as e:
                batch_results.append({'input': data, 'error': str(e)})
        batch_df = pd.DataFrame(batch_results)
        st.write('Batch Prediction Results:')
        st.dataframe(batch_df)
    except Exception as e:
        st.error(f'Batch prediction error: {e}')

# --- Single Prediction ---
if st.button('Predict'):
    try:
        # Input validation
        data = [float(x) for x in input_data.split(',')]
        if len(data) != 4:
            st.error('Please enter exactly 4 numbers for the Iris model.')
        else:
            import time
            start_time = time.time()
            # Advanced A/B routing
            if model_choice in ['A', 'B', 'Random (A/B)']:
                ab_url = 'http://ab_testing:7000/ab_predict'
                payload = {'data': data}
                if model_choice != 'Random (A/B)':
                    payload['model_version'] = model_choice
                response = requests.post(ab_url, json=payload, timeout=5)
                result = response.json()
                model_used = result.get('model_version', model_choice)
                st.info(f"A/B Test: Model {model_used} used.")
            else:
                response = requests.post('http://flask_api:5000/predict', json={'data': data}, timeout=5)
                result = response.json()
                model_used = 'Default'
            elapsed = time.time() - start_time
            st.success(f"Prediction: {result['prediction']} ({result['class_name']}) | Model: {model_used} | Response time: {elapsed:.2f}s")

            # Display probabilities as a table/bar chart
            class_labels = ['setosa', 'versicolor', 'virginica']
            prob_df = pd.DataFrame({
                'Class': class_labels,
                'Probability': result['probabilities']
            })
            st.subheader('Class Probabilities')
            st.dataframe(prob_df.style.background_gradient(cmap='Blues'))
            st.bar_chart(prob_df.set_index('Class'))

            # Display feature importances as a bar chart
            if result.get('feature_importances') is not None:
                st.subheader('Feature Importances')
                feature_names = ['sepal length', 'sepal width', 'petal length', 'petal width']
                feat_df = pd.DataFrame({
                    'Feature': feature_names,
                    'Importance': result['feature_importances']
                })
                st.dataframe(feat_df.style.background_gradient(cmap='Greens'))
                st.bar_chart(feat_df.set_index('Feature'))

            # User feedback
            feedback = st.radio('Was this prediction helpful?', ['👍 Yes', '👎 No'], key=f'feedback_{time.time()}')
            if 'feedback_log' not in st.session_state:
                st.session_state['feedback_log'] = []
            st.session_state['feedback_log'].append({'input': data, 'model': model_used, 'feedback': feedback})
            st.write('Thank you for your feedback!')

            # Show raw JSON response for debugging
            with st.expander('Show raw response'):
                st.json(result)

            # Log prediction for performance tracking
            if 'prediction_log' not in st.session_state:
                st.session_state['prediction_log'] = []
            st.session_state['prediction_log'].append({
                'input': data,
                'prediction': result['prediction'],
                'class_name': result['class_name'],
                'model': model_used,
                'response_time': elapsed
            })

    except Exception as e:
        st.error(f'Error: {e}')

# --- Show Recent Predictions and Feedback ---
st.subheader('Recent Predictions')
if 'prediction_log' in st.session_state and st.session_state['prediction_log']:
    st.dataframe(pd.DataFrame(st.session_state['prediction_log']))
else:
    st.write('No predictions yet.')

st.subheader('User Feedback')
if 'feedback_log' in st.session_state and st.session_state['feedback_log']:
    st.dataframe(pd.DataFrame(st.session_state['feedback_log']))
else:
    st.write('No feedback yet.')
