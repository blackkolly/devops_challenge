pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'flask-ecommerce'
        DOCKER_TAG = "${BUILD_NUMBER}"
        AWS_REGION = 'us-east-1'
        EC2_HOST = 'your-ec2-public-ip'
        EC2_USER = 'ubuntu'
        SSH_KEY = credentials('ec2-ssh-key')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup Python Environment') {
            steps {
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt
                '''
            }
        }
        
        stage('Lint Code') {
            steps {
                sh '''
                    . venv/bin/activate
                    pip install flake8
                    flake8 app.py --max-line-length=120 --ignore=E402,W503
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                sh '''
                    . venv/bin/activate
                    python -m pytest tests/ -v --junitxml=test-results.xml --cov=app --cov-report=xml
                '''
            }
            post {
                always {
                    junit 'test-results.xml'
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: false,
                        keepAll: true,
                        reportDir: 'htmlcov',
                        reportFiles: 'index.html',
                        reportName: 'Coverage Report'
                    ])
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                sh '''
                    . venv/bin/activate
                    pip install bandit safety
                    bandit -r app.py -f json -o bandit-report.json || true
                    safety check --json --output safety-report.json || true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: '*-report.json', fingerprint: true
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    def image = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                    docker.withRegistry('https://registry.hub.docker.com/', 'dockerhub-credentials') {
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                sh '''
                    docker run -d -p 5001:5000 --name staging-${BUILD_NUMBER} ${DOCKER_IMAGE}:${DOCKER_TAG}
                    sleep 10
                    curl -f http://localhost:5001/health || exit 1
                '''
            }
        }
        
        stage('Integration Tests') {
            steps {
                sh '''
                    . venv/bin/activate
                    pip install requests
                    python -m pytest tests/integration/ -v || true
                '''
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    input message: 'Deploy to production?', ok: 'Deploy'
                }
                
                sh '''
                    # Create deployment script
                    cat > deploy.sh << 'EOF'
#!/bin/bash
set -e

# Pull latest image
docker pull ${DOCKER_IMAGE}:${DOCKER_TAG}

# Stop old container
docker stop flask-ecommerce || true
docker rm flask-ecommerce || true

# Start new container
docker run -d \
    --name flask-ecommerce \
    -p 5000:5000 \
    --restart unless-stopped \
    -v /var/lib/ecommerce:/app/instance \
    ${DOCKER_IMAGE}:${DOCKER_TAG}

# Health check
sleep 15
curl -f http://localhost:5000/health

echo "Deployment successful!"
EOF

                    chmod +x deploy.sh
                '''
                
                sshagent(['ec2-ssh-key']) {
                    sh '''
                        scp -o StrictHostKeyChecking=no deploy.sh ${EC2_USER}@${EC2_HOST}:/tmp/
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} "
                            export DOCKER_IMAGE=${DOCKER_IMAGE}
                            export DOCKER_TAG=${DOCKER_TAG}
                            chmod +x /tmp/deploy.sh
                            /tmp/deploy.sh
                        "
                    '''
                }
            }
        }
        
        stage('Smoke Tests') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh '''
                        # Run smoke tests against production
                        sleep 30
                        curl -f http://${EC2_HOST}/health
                        curl -f http://${EC2_HOST}/
                        curl -f http://${EC2_HOST}/products
                    '''
                }
            }
        }
    }
    
    post {
        always {
            // Clean up staging container
            sh 'docker stop staging-${BUILD_NUMBER} || true'
            sh 'docker rm staging-${BUILD_NUMBER} || true'
            
            // Clean up workspace
            cleanWs()
        }
        
        success {
            slackSend(
                channel: '#deployments',
                color: 'good',
                message: "✅ Flask E-Commerce deployment successful! Build: ${BUILD_NUMBER}"
            )
        }
        
        failure {
            slackSend(
                channel: '#deployments',
                color: 'danger',
                message: "❌ Flask E-Commerce deployment failed! Build: ${BUILD_NUMBER}"
            )
            
            // Rollback on failure
            script {
                if (env.BRANCH_NAME == 'main') {
                    sshagent(['ec2-ssh-key']) {
                        sh '''
                            ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} "
                                # Get previous successful image
                                PREV_TAG=\$(docker images ${DOCKER_IMAGE} --format 'table {{.Tag}}' | grep -v latest | grep -v TAG | head -2 | tail -1)
                                if [ ! -z \"\$PREV_TAG\" ]; then
                                    echo \"Rolling back to ${DOCKER_IMAGE}:\$PREV_TAG\"
                                    docker stop flask-ecommerce || true
                                    docker rm flask-ecommerce || true
                                    docker run -d --name flask-ecommerce -p 5000:5000 --restart unless-stopped ${DOCKER_IMAGE}:\$PREV_TAG
                                    echo \"Rollback completed\"
                                fi
                            "
                        '''
                    }
                }
            }
        }
    }
}
