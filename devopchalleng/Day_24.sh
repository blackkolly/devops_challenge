🔥 Challenges
🔹 Challenge 1: Install Jenkins (locally or via Docker) and access the web UI
🔹 Challenge 2: Create a Freestyle job that prints Hello from Jenkins
🔹 Challenge 3: Add a GitHub repo to your job and clone it on build
🔹 Challenge 4: Add a post-build step to send a notification to the console
🔹 Challenge 5: Schedule your job to run every 5 minutes using cron syntax

🔹 Challenge 6: Create a Freestyle job to run an Ansible playbook or Docker build
🔹 Challenge 7: Install a plugin (e.g., Slack Notification or GitHub Integration)
🔹 Challenge 8: Add credentials (SSH key or token) securely to Jenkins
🔹 Challenge 9: Create a job that runs different shell scripts based on parameters
🔹 Challenge 10: Configure Jenkins global tools: Java, Git, Maven, etc.

# Jenkins Challenges Guide

## 🔹 Challenge 1: Install Jenkins and Access Web UI

### Docker Installation:
```bash
docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```

### Local Installation (Ubuntu):
```bash
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins
sudo systemctl start jenkins
```

Access Jenkins at `http://localhost:8080` and follow setup wizard.

## 🔹 Challenge 2: Create "Hello from Jenkins" Freestyle Job

1. Click "New Item"
2. Enter job name, select "Freestyle project", click OK
3. In Build section, add "Execute shell" step
4. Enter:
```bash
echo "Hello from Jenkins"
```
5. Save and click "Build Now"

## 🔹 Challenge 3: Add GitHub Repo to Job

1. Edit your existing job
2. Under "Source Code Management", select Git
3. Enter repository URL (e.g., `https://github.com/username/repo.git`)
4. Add credentials if needed
5. In Build section, add shell step:
```bash
ls -la  # Verify repo was cloned
```
6. Save and build

## 🔹 Challenge 4: Add Post-Build Notification

1. Edit your job
2. Scroll to "Post-build Actions"
3. Add "Print message to console" or similar option
4. Enter notification message
5. Save and build to see notification in console output

## 🔹 Challenge 5: Schedule Job with Cron

1. Edit your job
2. Under "Build Triggers", check "Build periodically"
3. Enter cron syntax: `H/5 * * * *` (every 5 minutes)
4. Save - job will now run automatically

## 🔹 Challenge 6: Run Ansible/Docker in Job

### For Ansible:
1. Create new freestyle job
2. Add shell build step:
```bash
ansible-playbook playbook.yml
```

### For Docker:
1. Create new freestyle job
2. Add shell build step:
```bash
docker build -t myimage .
docker run myimage
```

## 🔹 Challenge 7: Install Plugin

1. Go to "Manage Jenkins" > "Manage Plugins"
2. Select "Available" tab
3. Search for plugin (e.g., "Slack Notification")
4. Check box and click "Install without restart"
5. Configure plugin after installation

## 🔹 Challenge 8: Add Secure Credentials

1. Go to "Manage Jenkins" > "Manage Credentials"
2. Select domain (usually "global")
3. Click "Add Credentials"
4. Choose type (SSH key, username/password, secret text)
5. Enter credentials details
6. Click OK to save securely

## 🔹 Challenge 9: Parameterized Job with Shell Scripts

1. Create new freestyle job
2. Check "This project is parameterized"
3. Add choice parameter named "SCRIPT" with values: "script1,script2"
4. Add shell build step:
```bash
case $SCRIPT in
  script1)
    echo "Running script 1"
    # script1 commands
    ;;
  script2)
    echo "Running script 2"
    # script2 commands
    ;;
esac
```
5. Save - each build will prompt for parameter

## 🔹 Challenge 10: Configure Global Tools

1. Go to "Manage Jenkins" > "Global Tool Configuration"
2. Under JDK:
   - Click "Add JDK"
   - Provide name and JAVA_HOME path or let Jenkins install automatically
3. Under Git:
   - Provide path to Git executable or let Jenkins install
4. Under Maven:
   - Add Maven installation with name and version
5. Click Save

For all tools, you can either:
- Specify path if pre-installed
- Check "Install automatically" to have Jenkins manage installation
