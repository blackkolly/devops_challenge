🔥 Challenges
🔹 Challenge 1: Use a matrix to test across:

3 versions of Node.js or Python

2 OSs (ubuntu-latest, windows-latest)

🔹 Challenge 2: Use needs: to create a pipeline like:

build → test → deploy (conditionally run deploy if tests pass)

🔹 Challenge 3: Use actions/cache@v3 to store build dependencies and speed up CI

🔹 Challenge 4: Add workflow_dispatch inputs like environment: [dev, prod] and print them in the job

🔹 Challenge 5: Add an if: condition to only run a deployment job on the main branch

🔹 Challenge 6: Upload a build artifact in one job and download it in another

🔹 Challenge 7: Create a reusable workflow called from another workflow using workflow_call

🔹 Challenge 8: Define a protected environment with manual approval and use it in a deploy job

🔹 Challenge 9: Use output from one job (e.g., version, build_hash) in the next job

🔹 Challenge 10: Use a GitHub Action to build a Docker image, tag it, and push to Docker Hub

name: CI/CD Pipeline

on:
  push:
    branches: [ "**" ]
  pull_request:
    branches: [ "**" ]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        default: 'dev'
        type: choice
        options:
        - dev
        - prod

jobs:
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        node-version: [14.x, 16.x, 18.x]
        python-version: ['3.8', '3.9', '3.10']
        os: [ubuntu-latest, windows-latest]
        exclude:
          - os: windows-latest
            python-version: '3.10'
          - os: ubuntu-latest
            node-version: 14.x

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
    
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Cache dependencies
      uses: actions/cache@v3
      with:
        path: |
          node_modules
          **/__pycache__
        key: ${{ runner.os }}-build-${{ hashFiles('**/package-lock.json', '**/requirements.txt') }}
    
    - name: Install dependencies
      run: |
        if [ -f package.json ]; then npm ci; fi
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
    
    - name: Build
      run: |
        echo "Running build steps..."
        # Add your build commands here

  test:
    needs: build
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Run tests
      run: |
        echo "Running tests..."
        # Add your test commands here
    
    - name: Check test results
      if: always()
      run: |
        echo "Tests completed with status: ${{ job.status }}"
        if [ "${{ job.status }}" != "success" ]; then
          echo "::warning::Some tests failed"
        fi

  deploy:
    needs: test
    if: ${{ github.ref == 'refs/heads/main' && needs.test.result == 'success' }}
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Print environment input
      run: |
        echo "Deploying to ${{ inputs.environment || github.event.inputs.environment }} environment"
        # Add your deployment commands here
      env:
        ENVIRONMENT: ${{ inputs.environment || github.event.inputs.environment }}

        Explanation:

    Matrix Testing (Challenge 1):

        Tests across 3 Node.js versions (14.x, 16.x, 18.x) and 3 Python versions (3.8, 3.9, 3.10)

        Runs on both Ubuntu and Windows (with some exclusions to demonstrate matrix control)

    Job Dependencies with needs (Challenge 2):

        Pipeline flows: build → test → deploy

        Each job only runs if the previous one succeeds

    Caching Dependencies (Challenge 3):

        Uses actions/cache@v3 to cache Node.js modules and Python cache

        Cache key based on lock files for proper invalidation

    Workflow Dispatch Inputs (Challenge 4):

        Adds a dropdown input for environment (dev/prod)

        Prints the selected environment in the deploy job

    Conditional Deployment (Challenge 5):

        Deploy job only runs on main branch (github.ref == 'refs/heads/main')

        Also checks that tests passed (needs.test.result == 'success')
        
