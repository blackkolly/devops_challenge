🔹 Challenge 1: Run EC2 and install the Nginx Server
1.	Launch an EC2 instance using Amazon Linux or Ubuntu
(Make sure to allow port 22 for SSH and generate/download the key pair required to connect to ec2 via SSH client )
2.	SSH into the instance and install Nginx
3.	Start the web server and enable it to run on startup
4.	Modify your Security Group to allow HTTP traffic (port 80).
5.	Access your EC2 public IP in a browser to see the Nginx welcome page.
6.	(Optional) Run another copy of this ec2 server in another availability zone, and add an Application load balancer (ALB) to balance traffic between these 2 ec2 servers. Load the ALB URL in the browser to check if it’s working fine.
7.	Share a screenshot of your running web server on LinkedIn or GitHub!

Here’s a step-by-step guide to complete **Challenge 1: Run EC2 and Install the Nginx Server**:

---

### **Step 1: Launch an EC2 Instance**
1. **Log in to AWS Console**:
   - Go to the [AWS Management Console](https://aws.amazon.com/console/).
   - Sign in with your credentials.

2. **Launch EC2 Instance**:
   - Navigate to the **EC2 Dashboard**.
   - Click **Launch Instance**.
   - Choose an **Amazon Linux** or **Ubuntu** AMI (e.g., Amazon Linux 2023 or Ubuntu Server 22.04 LTS).
   - Select the instance type (e.g., `t2.micro`, which is free tier eligible).
   - Configure instance details (leave defaults if unsure).
   - Add storage (default is usually sufficient).

3. **Configure Security Group**:
   - Create a new security group or use an existing one.
   - Add the following rules:
     - **SSH (Port 22)**: Allow access from your IP or `0.0.0.0/0` (for any IP, but this is less secure).
     - **HTTP (Port 80)**: Allow access from `0.0.0.0/0` (for web traffic).

4. **Create/Download Key Pair**:
   - Create a new key pair (e.g., `nginx-key.pem`) and download it.
   - Save the key pair securely; you’ll need it to SSH into the instance.

5. **Launch the Instance**:
   - Review your settings and click **Launch Instance**.

---

### **Step 2: SSH into the Instance and Install Nginx**
1. **Connect to the Instance**:
   - Open your terminal (Linux/Mac) or use an SSH client like PuTTY (Windows).
   - Navigate to the folder where your key pair is stored.
   - Run the following command to SSH into the instance:
     ```bash
     ssh -i /path/to/nginx-key.pem ec2-user@<public-ip>
     ```
     - Replace `/path/to/nginx-key.pem` with the path to your key pair.
     - Replace `<public-ip>` with the public IP of your EC2 instance.
     - For Ubuntu, use `ubuntu` instead of `ec2-user`.

2. **Update the System**:
   - Run the following commands to update the package manager:
     ```bash
     sudo yum update -y  # For Amazon Linux
     sudo apt update && sudo apt upgrade -y  # For Ubuntu
     ```

3. **Install Nginx**:
   - For Amazon Linux:
     ```bash
     sudo amazon-linux-extras install nginx1 -y
     ```
   - For Ubuntu:
     ```bash
     sudo apt install nginx -y
     ```

---

### **Step 3: Start the Web Server and Enable It on Startup**
1. **Start Nginx**:
   - Run the following command to start the Nginx server:
     ```bash
     sudo systemctl start nginx
     ```

2. **Enable Nginx on Startup**:
   - Run the following command to ensure Nginx starts automatically on system boot:
     ```bash
     sudo systemctl enable nginx
     ```

3. **Check Nginx Status**:
   - Verify that Nginx is running:
     ```bash
     sudo systemctl status nginx
     ```

---

### **Step 4: Modify Security Group to Allow HTTP Traffic**
1. **Go to EC2 Dashboard**:
   - In the AWS Console, navigate to the **EC2 Dashboard**.
   - Select **Instances** and click on your running instance.

2. **Edit Security Group**:
   - Under the **Security** tab, click on the security group linked to your instance.
   - Click **Edit Inbound Rules**.
   - Add a new rule:
     - **Type**: HTTP
     - **Port Range**: 80
     - **Source**: `0.0.0.0/0` (or restrict to specific IPs for security).

3. **Save the Rules**.

---

### **Step 5: Access Your EC2 Public IP in a Browser**
1. **Get the Public IP**:
   - Go to the EC2 Dashboard and note the public IP of your instance.

2. **Open the Browser**:
   - Enter the public IP in your browser’s address bar (e.g., `http://<public-ip>`).
   - You should see the **Nginx Welcome Page**.

---

### **Step 6: (Optional) Add Another EC2 Instance and Application Load Balancer (ALB)**
1. **Launch a Second EC2 Instance**:
   - Repeat Steps 1–5 to launch another EC2 instance in a different availability zone.

2. **Create an Application Load Balancer (ALB)**:
   - Go to the **EC2 Dashboard** and select **Load Balancers**.
   - Click **Create Load Balancer** and choose **Application Load Balancer**.
   - Configure the ALB:
     - Add both EC2 instances as targets.
     - Configure listeners for HTTP (Port 80).
   - Complete the setup and note the ALB’s DNS name.

3. **Test the ALB**:
   - Open the ALB’s DNS name in your browser.
   - Verify that the Nginx welcome page loads.

---

### **Step 7: Share a Screenshot**
1. Take a screenshot of the Nginx welcome page or the ALB working.
2. Share it on **LinkedIn** or **GitHub** with a description of your accomplishment!

---

### **Example Commands for Reference**
- SSH into EC2:
  ```bash
  ssh -i /path/to/nginx-key.pem ec2-user@<public-ip>
  ```
- Install Nginx (Amazon Linux):
  ```bash
  sudo amazon-linux-extras install nginx1 -y
  ```
- Start and Enable Nginx:
  ```bash
  sudo systemctl start nginx
  sudo systemctl enable nginx
  ```

---

Let me know if you need further assistance! 🚀


🔹 Challenge 2: Docker Mini Project 1 Deployment Tasks

1.	Launch an EC2 instance and configure security groups.
2.	Install Docker and Docker Compose on the EC2 instance.
3.	Clone Project 1 from Docker Mini Projects.
4.	Set up and run the application using Docker Compose in the background.
5.	Verify the application is accessible on port 5000.
6.	Install and configure Nginx as a reverse proxy.
7.	Forward traffic from port 80 to port 5000 using Nginx.
8.	Restart Nginx and validate reverse proxy functionality.
9.	Test application access via the EC2 public IP on port 80.
10.	Restrict direct access to port 5000 using firewall rules.
11.	(Optional) Configure SSL with Let's Encrypt for secure access.
12.	(Bonus) Improve setup with a Dockerized Nginx or AWS ALB.
13.	(Bonus) Set up a systemd service for auto-restarting Docker Compose on reboot.
14.	Terminate all the running instances to save cost / stop billing

Docker Mini Project 1 Deployment Tasks:

### 1. Launch an EC2 Instance and Configure Security Groups
- Go to the AWS Management Console and launch an EC2 instance (e.g., Amazon Linux 2 or Ubuntu).
- Configure the security group to allow inbound traffic on:
  - Port 22 (SSH)
  - Port 80 (HTTP)
  - Port 500 (Application)
  - Port 443 (HTTPS, optional for SSL)


### 2. Install Docker and Docker Compose on the EC2 Instance**
- SSH into your EC2 instance:
  
  ssh -i your-key.pem ec2-user@<public-ip>
  ```
- Install Docker:
  ```bash
  sudo yum update -y
  sudo yum install docker -y
  sudo systemctl start docker
  sudo systemctl enable docker
  ```
- Install Docker Compose:
  
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  



### 3. Clone Project 1 from Docker Mini Projects**
- Clone the project repository:
  
  git clone <project-repo-url>
  cd <project-directory>
  


### 4. Set Up and Run the Application Using Docker Compose in the Background
- Run the application in detached mode:
  
  docker-compose up -d
  

### 5. Verify the Application is Accessible on Port 5000
- Check if the application is running:
  
  curl http://localhost:5000
 Alternatively, open your browser and navigate to `http://<public-ip>:5000`.



### 6. Install and Configure Nginx as a Reverse Proxy
- Install Nginx:
  sudo yum install nginx -y
  
- Edit the Nginx configuration file:
  
  sudo nano /etc/nginx/nginx.conf
  
- Add the following configuration inside the `http` block:
  ```nginx
  server {
      listen 80;
      server_name <public-ip>;

      location / {
          proxy_pass http://localhost:5000;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
      }
  }
  



### 7. Forward Traffic from Port 80 to Port 5000 Using Nginx
The above Nginx configuration already forwards traffic from port 80 to port 5000.



### 8. Restart Nginx and Validate Reverse Proxy Functionality**
- Restart Nginx:
  
  sudo systemctl restart nginx
  sudo systemctl enable nginx
  
- Validate the reverse proxy:
  
  curl http://localhost:80
  



### 9. Test Application Access via the EC2 Public IP on Port 80
- Open your browser and navigate to `http://<public-ip>`.

### 10. Restrict Direct Access to Port 5000 Using Firewall Rules
- Update the EC2 security group to remove the inbound rule for port 5000.


### 11. (Optional) Configure SSL with Let's Encrypt for Secure Access**
- Install Certbot:

  sudo yum install certbot python3-certbot-nginx -y
  
- Obtain an SSL certificate:
  
  sudo certbot --nginx -d <your-domain>
  ```
- Follow the prompts to complete the setup.



### 12. (Bonus) Improve Setup with a Dockerized Nginx or AWS ALB
- Dockerized Nginx:
  - Add an Nginx service to your `docker-compose.yml` file.
  - Configure it to proxy requests to the application container.
- AWS ALB:
  - Create an Application Load Balancer in AWS.
  - Configure it to forward traffic to the EC2 instance on port 80.



### 13. (Bonus) Set Up a Systemd Service for Auto-Restarting Docker Compose on Reboot**
- Create a systemd service file:
  
  sudo nano /etc/systemd/system/docker-compose-app.service
  
- Add the following content:
  Description=Docker Compose Application
  Requires=docker.service
  After=docker.service

  [Service]
  WorkingDirectory=/path/to/your/project
  ExecStart=/usr/local/bin/docker-compose up
  ExecStop=/usr/local/bin/docker-compose down
  Restart=always

  [Install]
  WantedBy=multi-user.target
  ```
- Enable and start the service:

  sudo systemctl enable docker-compose-app
  sudo systemctl start docker-compose-app
  

### 14. Terminate All Running Instances to Save Cost / Stop Billing**
- Go to the AWS Management Console.
- Select the EC2 instance and click **Terminate**.
- Verify that all resources (e.g., ALB, security groups) are deleted.


