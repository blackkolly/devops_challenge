🔹 Challenge 1: Create a Python script that connects to a remote server via SSH using paramiko.
import paramiko

def ssh_connect(hostname, username, password):
    try:
        # Initialize SSH client
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        # Connect to the server
        ssh.connect(hostname, username=username, password=password)
        print(f"Connected to {hostname}")

        # Run a command on the server
        stdin, stdout, stderr = ssh.exec_command('uptime')
        print(stdout.read().decode())
        
        # Close the connection
        ssh.close()
    except Exception as e:
        print(f"Connection failed: {e}")

# Example usage
ssh_connect('your-server.com', 'username', 'password')

Challenge 2: Build a simple Flask API with an endpoint that returns system health (CPU/memory usage).
 from flask import Flask, jsonify
import psutil

app = Flask(__name__)

@app.route('/health', methods=['GET'])
def health_check():
    cpu = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory().percent
    return jsonify({'cpu_usage': cpu, 'memory_usage': memory})

if __name__ == '__main__':
    app.run(debug=True)
    
 Challenge 3: Create a Django app, set up models, views, and templates for a basic CRUD operation.
     # Create a new Django project
django-admin startproject myproject

# Create an app within the project
python manage.py startapp myapp

 Inside the models.py:

from django.db import models

class Item(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()

    def __str__(self):
        return self.name

Inside the views.py:

from django.shortcuts import render
from .models import Item

def item_list(request):
    items = Item.objects.all()
    return render(request, 'item_list.html', {'items': items})

Inside the urls.py:

from django.urls import path
from . import views

urlpatterns = [
    path('items/', views.item_list, name='item_list'),
]

Inside item_list.html:

<!DOCTYPE html>
<html>
<head>
    <title>Item List</title>
</head>
<body>
    <h1>Items</h1>
    <ul>
        {% for item in items %}
            <li>{{ item.name }}: {{ item.description }}</li>
        {% endfor %}
    </ul>
</body>
</html>

Challenge 4: Use Python subprocess to execute system commands and capture output.
import subprocess

def run_command(command):
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        print("Output:", result.stdout)
        print("Error:", result.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")

# Example usage
run_command(['ls', '-l'])
Challenge 6: Deploy a Django application on AWS EC2 with Nginx & Gunicorn.

    Set up an EC2 instance on AWS.
    Install dependencies like Python, Nginx, Gunicorn.
    Configure Gunicorn to serve the Django app.
    Set up Nginx to reverse proxy traffic to Gunicorn.
    Make sure to configure security groups and other AWS settings to allow web traffic.
sudo apt update
sudo apt install python3-pip python3-dev libpq-dev nginx
pip install gunicorn

Run Gunicorn:

gunicorn --workers 3 myproject.wsgi:application

Configure Nginx:

server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
    }
}



