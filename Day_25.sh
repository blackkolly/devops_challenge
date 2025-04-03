🔥 Challenges

🔹 Challenge 1: Create a pipeline job that echoes “Hello from Jenkins Pipeline!”
🔹 Challenge 2: Add three stages: Build, Test, and Deploy
🔹 Challenge 3: Add environment variables (e.g., ENV=dev) and print them
🔹 Challenge 4: Use a post block to notify success or failure
🔹 Challenge 5: Configure Jenkins to load the Jenkinsfile from a GitHub repo

🔹 Challenge 6: Use when to conditionally skip a stage if an env variable is not set
🔹 Challenge 7: Use input block to pause the pipeline for manual approval before deploy.
🔹 Challenge 8: Parallelize two stages (Unit Test and Lint Check)
🔹 Challenge 9: Pass secrets securely using Jenkins credentials plugin
🔹 Challenge 10: Create a parameterized pipeline job and use those params inside the Jenkinsfile
🔹 Challenge 11: Build a CI/CD Pipeline for One of the Following Applications:

Python Application

Node.js Application

Final Challenge:
🔹 Challenge 12: Build a Docker Image Using Jenkins Pipeline from Challenge 10 & Push to AWS ECR (Reference Video)


# Jenkins Pipeline Solution

Here's a complete solution for all 5 challenges in a single Jenkinsfile:

## Jenkinsfile Solution

```groovy
pipeline {
    agent any
    
    // Challenge 3: Environment variables
    environment {
        ENV = 'dev'
        BUILD_NUMBER = "${currentBuild.number}"
        REPO_URL = 'https://github.com/your-username/your-repo.git'
    }
    
    stages {
        // Challenge 1: Echo hello message
        stage('Greet') {
            steps {
                echo 'Hello from Jenkins Pipeline!'
            }
        }
        
        // Challenge 2: Build stage
        stage('Build') {
            steps {
                echo 'Building the application...'
                echo "Environment: ${ENV}"
                echo "Build Number: ${BUILD_NUMBER}"
                // Add your actual build commands here
            }
        }
        
        // Challenge 2: Test stage
        stage('Test') {
            steps {
                echo 'Running tests...'
                // Add your actual test commands here
            }
        }
        
        // Challenge 2: Deploy stage
        stage('Deploy') {
            steps {
                echo 'Deploying to environment...'
                echo "Current environment: ${ENV}"
                // Add your actual deployment commands here
            }
        }
    }
    
    // Challenge 4: Post build actions
    post {
        success {
            echo 'Pipeline completed successfully!'
            // Add success notifications (email, Slack, etc.)
            slackSend(color: 'good', message: "Pipeline SUCCESS: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}")
        }
        failure {
            echo 'Pipeline failed!'
            // Add failure notifications (email, Slack, etc.)
            slackSend(color: 'danger', message: "Pipeline FAILED: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}")
        }
        always {
            echo 'Pipeline execution completed. Cleaning up...'
            // Add cleanup steps if needed
        }
    }
}
```

## Challenge 5: Configuring Jenkins to load from GitHub

To configure Jenkins to load this Jenkinsfile from a GitHub repository:

1. **Install required plugins**:
   - GitHub plugin
   - Pipeline plugin

2. **Create a new Pipeline job**:
   - Go to Jenkins dashboard → New Item
   - Enter a name and select "Pipeline"
   - Click OK

3. **Configure the Pipeline**:
   - In the job configuration, under "Pipeline" section:
     - Select "Pipeline script from SCM"
     - Choose "Git" as SCM
     - Enter your repository URL (e.g., `https://github.com/your-username/your-repo.git`)
     - Add credentials if needed (for private repos)
     - Specify the branch (e.g., `main` or `master`)
     - Set the path to Jenkinsfile (usually just `Jenkinsfile` if it's in the root)

4. **Save and run**:
   - Click Save
   - Click "Build Now" to run the pipeline

## Additional Notes

1. For the Slack notifications to work, you'll need to:
   - Install the Slack Notification plugin
   - Configure Slack integration in Jenkins system settings

2. You can replace the placeholder commands in Build, Test, and Deploy stages with your actual commands (e.g., `mvn clean install` for Java projects or `npm test` for Node.js projects).

3. For private repositories, make sure to:
   - Add SSH keys or username/password credentials in Jenkins
   - Configure the credentials in the job configuration

4. The environment variables can be expanded as needed for your specific use case.

Here's the enhanced Jenkinsfile that incorporates all 10 challenges:

```groovy
pipeline {
    agent any
    
    // Challenge 10: Parameters
    parameters {
        string(name: 'DEPLOY_ENV', defaultValue: 'staging', description: 'Environment to deploy to')
        choice(name: 'BUILD_TYPE', choices: ['full', 'incremental'], description: 'Type of build')
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run all tests?')
    }
    
    // Challenge 3 & 9: Environment variables and secrets
    environment {
        ENV = 'dev'
        BUILD_NUMBER = "${currentBuild.number}"
        REPO_URL = 'https://github.com/your-username/your-repo.git'
        // Challenge 9: Secure credentials
        DB_PASSWORD = credentials('db-prod-password') // ID of credential in Jenkins
        API_KEY = credentials('api-key-secret')
    }
    
    stages {
        // Challenge 1: Echo hello message
        stage('Greet') {
            steps {
                echo 'Hello from Jenkins Pipeline!'
                // Challenge 10: Using parameters
                echo "Build type: ${params.BUILD_TYPE}"
                echo "Deploy environment: ${params.DEPLOY_ENV}"
            }
        }
        
        // Challenge 2: Build stage
        stage('Build') {
            steps {
                echo 'Building the application...'
                echo "Environment: ${ENV}"
                echo "Build Number: ${BUILD_NUMBER}"
                // Challenge 9: Using secrets (masked in logs)
                sh 'echo "Database password is set (not shown in logs)"'
                sh 'echo "API key is set (not shown in logs)"'
            }
        }
        
        // Challenge 8: Parallel stages
        stage('Quality Checks') {
            parallel {
                stage('Unit Test') {
                    when {
                        expression { params.RUN_TESTS == true }
                    }
                    steps {
                        echo 'Running unit tests...'
                        // Simulate test execution
                        sh 'echo "Running tests..." && sleep 5'
                    }
                }
                stage('Lint Check') {
                    steps {
                        echo 'Running lint checks...'
                        // Simulate linting
                        sh 'echo "Running linter..." && sleep 3'
                    }
                }
            }
        }
        
        // Challenge 6: Conditional stage
        stage('Integration Tests') {
            when {
                environment name: 'RUN_INTEGRATION_TESTS', value: 'true'
            }
            steps {
                echo 'Running integration tests...'
            }
        }
        
        // Challenge 7: Manual approval before deploy
        stage('Approval') {
            steps {
                script {
                    // Challenge 10: Use parameter in approval message
                    def deployMsg = "Approve deployment to ${params.DEPLOY_ENV}?"
                    timeout(time: 1, unit: 'HOURS') {
                        input(
                            message: deployMsg,
                            ok: 'Deploy',
                            submitter: 'admin,deploy-team',
                            parameters: [
                                string(defaultValue: '', description: 'Release notes', name: 'releaseNotes')
                            ]
                        )
                    }
                }
            }
        }
        
        // Challenge 2: Deploy stage
        stage('Deploy') {
            steps {
                echo "Deploying to ${params.DEPLOY_ENV}..."
                // Challenge 10: Using parameter to determine deployment
                script {
                    if (params.DEPLOY_ENV == 'production') {
                        echo 'Performing production deployment with extra checks'
                        // Add production-specific steps
                    } else {
                        echo "Deploying to ${params.DEPLOY_ENV} environment"
                    }
                }
            }
        }
    }
    
    // Challenge 4: Post build actions
    post {
        success {
            echo 'Pipeline completed successfully!'
            slackSend(color: 'good', message: "Pipeline SUCCESS: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}")
        }
        failure {
            echo 'Pipeline failed!'
            slackSend(color: 'danger', message: "Pipeline FAILED: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}")
        }
        always {
            echo 'Pipeline execution completed. Cleaning up...'
            // Cleanup steps
        }
    }
}
```

## Implementation Notes for Each Challenge:

### Challenge 6: Conditional Stage
- Added `Integration Tests` stage with `when` directive that only executes if `RUN_INTEGRATION_TESTS` environment variable is set to 'true'
- You can set this variable in Jenkins job configuration or during runtime

### Challenge 7: Manual Approval
- Added `Approval` stage with `input` step that:
  - Pauses pipeline for manual approval
  - Times out after 1 hour
  - Restricts who can approve (submitter parameter)
  - Can collect additional input (release notes)

### Challenge 8: Parallel Stages
- Created `Quality Checks` parent stage with two parallel children:
  - `Unit Test` (can be disabled via parameter)
  - `Lint Check`
- Both run simultaneously to save time

### Challenge 9: Secure Secrets
- Added credentials via `credentials()` helper:
  - `DB_PASSWORD` and `API_KEY` are securely stored in Jenkins credentials store
  - Values are automatically masked in logs
  - Accessed like regular environment variables

### Challenge 10: Parameterized Pipeline
- Added three parameters at the start:
  - `DEPLOY_ENV` (string) - deployment target environment
  - `BUILD_TYPE` (choice) - build configuration
  - `RUN_TESTS` (boolean) - whether to run tests
- Parameters are accessed via `params` object throughout pipeline

## Additional Setup Required:

1. **For Secrets (Challenge 9)**:
   - In Jenkins, go to "Manage Jenkins" → "Manage Credentials"
   - Add secrets of type "Secret text" with IDs `db-prod-password` and `api-key-secret`
   - These will be securely injected into the pipeline

2. **For GitHub Integration**:
   - Make sure your Jenkinsfile is committed to your GitHub repository
   - Configure the pipeline job to fetch from SCM as before

3. **For Slack Notifications**:
   - Install "Slack Notification" plugin
   - Configure Slack workspace integration in Jenkins system settings

4. **For Manual Approvals**:
   - The `submitter` field in the input step should contain valid Jenkins usernames or groups
   - Adjust the timeout value as needed for your workflow

This pipeline now incorporates all 10 challenges while maintaining security and flexibility for different deployment scenarios.

# Challenge 11 & 12: CI/CD Pipeline with Jenkins and Docker Deployment to AWS ECR

## Challenge 11: Building a CI/CD Pipeline

### For a Python Application:

1. **Setup Jenkins Environment**
   - Install Jenkins on your server/instance
   - Install required plugins (Git, Pipeline, Docker, AWS ECR, etc.)
   - Configure AWS credentials in Jenkins

2. **Create Jenkinsfile**
```groovy
pipeline {
    agent any
    
    environment {
        APP_NAME = 'python-app'
        AWS_ACCOUNT_ID = 'your-aws-account-id'
        AWS_REGION = 'your-aws-region'
        DOCKER_IMAGE = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}:${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo/python-app.git'
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }
        
        stage('Run Tests') {
            steps {
                sh 'python -m pytest tests/'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build(DOCKER_IMAGE)
                }
            }
        }
        
        stage('Push to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com", 'ecr:us-east-1:aws-credentials') {
                        docker.image(DOCKER_IMAGE).push()
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                // Add your deployment steps here (e.g., update ECS service)
                echo 'Deploying to production...'
            }
        }
    }
}
```

### For a Node.js Application:

```groovy
pipeline {
    agent any
    
    environment {
        APP_NAME = 'nodejs-app'
        AWS_ACCOUNT_ID = 'your-aws-account-id'
        AWS_REGION = 'your-aws-region'
        DOCKER_IMAGE = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}:${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo/nodejs-app.git'
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }
        
        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build(DOCKER_IMAGE)
                }
            }
        }
        
        stage('Push to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com", 'ecr:us-east-1:aws-credentials') {
                        docker.image(DOCKER_IMAGE).push()
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                // Add your deployment steps here
                echo 'Deploying to production...'
            }
        }
    }
}
```

## Challenge 12: Docker Image with Jenkins Pipeline & Push to AWS ECR

1. **Prerequisites**
   - AWS account with ECR repository created
   - IAM user with ECR permissions
   - Docker installed on Jenkins server
   - AWS CLI configured on Jenkins server

2. **Jenkins Pipeline Configuration**
   - Create a new Pipeline job in Jenkins
   - Point it to your SCM (GitHub, Bitbucket, etc.) containing the Jenkinsfile
   - Make sure your Jenkinsfile includes the Docker build and ECR push stages as shown above

3. **Dockerfile Example (Python)**
```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

4. **Dockerfile Example (Node.js)**
```dockerfile
FROM node:14-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000
CMD ["npm", "start"]
```

5. **AWS ECR Setup**
   - Create an ECR repository in AWS Console
   - Configure Jenkins with AWS credentials (use IAM role or access keys)
   - Ensure Jenkins has permission to push to ECR

6. **Running the Pipeline**
   - Trigger the Jenkins job manually or via webhook
   - Monitor the pipeline stages in Jenkins console output
   - Verify the image appears in your AWS ECR repository after successful run

## Additional Tips

1. **Security Best Practices**:
   - Use Jenkins credentials store for sensitive data
   - Implement IAM roles instead of hardcoding credentials
   - Scan Docker images for vulnerabilities

2. **Optimizations**:
   - Implement caching for dependencies
   - Use multi-stage Docker builds
   - Add notifications for build status

3. **Advanced Features**:
   - Add approval gates for production deployment
   - Implement blue-green deployment strategy
   - Add monitoring and logging integration

Would you like me to elaborate on any specific part of this CI/CD pipeline setup?
