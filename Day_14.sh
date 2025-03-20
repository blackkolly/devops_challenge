These are some excellent challenges to help you master key AWS services and skills. Let’s go through each one step by step to clarify what needs to be done for each:

### 🔹 Challenge 1: Set up an IAM Role to allow EC2 to upload logs to S3
1. **Create an IAM Role for EC2:**
   - Navigate to the IAM Console and create a new role.
   - Choose "EC2" as the trusted entity.
   - Attach the `AmazonS3FullAccess` policy or a custom policy with permissions to write to the specific S3 bucket.
   - Name the role (e.g., `EC2ToS3LogRole`) and assign it to your EC2 instance when launching or attaching it to an existing EC2 instance.
   
2. Configure EC2 to use the IAM Role:
   - If your EC2 instance is already running, assign the IAM role through the EC2 Console.
   - Modify the instance metadata and ensure that your application is able to upload logs to the S3 bucket.

🔹 Challenge 2: Modify an EBS Volume size and verify that it expands without rebooting the instance.
1. **Modify EBS Volume:**
   - Go to the EC2 console and select the instance's EBS volume.
   - Choose “Modify Volume” and increase the size (e.g., from 20GB to 40GB).
   
2. Verify Expansion:
   - Once the modification is complete, SSH into the EC2 instance.
   - Use `lsblk` or `df -h` to confirm that the system recognizes the additional space.
   - Use `sudo growpart` and `resize2fs` (for Linux) to extend the filesystem without rebooting.

🔹Challenge 3: Manually attach an Elastic IP (EIP) to your running EC2 instance.
1. **Allocate an Elastic IP:**
   - In the EC2 Console, go to "Elastic IPs" and allocate a new IP.
   
2. Associate the EIP:
   - Select the newly allocated EIP and choose "Associate Address."
   - Select the running EC2 instance and associate the EIP.

### 🔹 Challenge 4: Enable CloudWatch Monitoring on your EC2 instance and view its CPU utilization logs.
1. **Enable CloudWatch Monitoring:**
   - In the EC2 Console, select your instance.
   - Under the "Monitoring" tab, enable "Detailed Monitoring" (this may incur additional costs).
   
2. View CloudWatch Logs:
   - Navigate to the CloudWatch Console.
   - Under "Metrics," find the "EC2" section and select "Per-Instance Metrics."
   - You can now view the CPU utilization, disk I/O, and network I/O metrics.

### 🔹 Challenge 5: Set up an Auto Scaling Group (ASG) that automatically adds or removes instances based on traffic.
1. **Create Launch Configuration:**
   - Create a launch configuration for the EC2 instance (e.g., using an AMI and instance type).
   
2. Create an Auto Scaling Group:
   - In the EC2 Console, go to "Auto Scaling Groups" and create a new ASG.
   - Define desired capacity, minimum, and maximum instances.
   - Set up scaling policies based on metrics like CPU utilization, request count, etc.
   
3. Test Auto Scaling:
   - Simulate load on the instances to see if the ASG scales up or down as needed.

### 🔹 Challenge 6: Use AWS Systems Manager (SSM) Session Manager to connect to an EC2 instance without SSH keys
1. **Attach IAM Role to EC2:
   - Ensure the EC2 instance has an IAM role with the `AmazonSSMManagedInstanceCore` policy.
   
2. Configure SSM Agent:
   - Make sure that the SSM agent is installed and running on the EC2 instance (it’s pre-installed on most AMIs).
   
3. Use Session Manager:
   - In the Systems Manager Console, go to "Session Manager" and start a session to connect to the instance without needing SSH keys.

### 🔹 Challenge 7: Install Apache and Deploy a WordPress Site on one EC2 instance accessible on port 80 and install MySQL on another instance.
1. **Set Up WordPress EC2 Instance:**
   - Launch an EC2 instance (e.g., using Amazon Linux 2 or Ubuntu).
   - Install Apache and PHP (and dependencies) on the instance:
     ```bash
     sudo yum install -y httpd php php-mysqlnd
     sudo systemctl start httpd
     sudo systemctl enable httpd
     ```
   - Install WordPress:
     ```bash
     wget https://wordpress.org/latest.tar.gz
     tar -xvzf latest.tar.gz
     mv wordpress /var/www/html/
     ```
   
2. Set Up MySQL EC2 Instance:
   - Launch another EC2 instance and install MySQL:
     ```bash
     sudo yum install -y mysql-server
     sudo systemctl start mysqld
     sudo systemctl enable mysqld
     ```
   - Configure the MySQL instance to allow connections from the WordPress EC2 instance by adjusting the security group.

3. Configure Security Groups:
   - Modify the WordPress EC2 security group to allow inbound traffic on port 80.
   - Modify the MySQL EC2 security group to allow inbound traffic on port 3306 only from the WordPress instance’s security group.

4. Link WordPress to MySQL:
   - Configure the WordPress `wp-config.php` file to connect to the MySQL instance using its private IP address.

5. Store Web Server Logs in S3:
   - Set up an S3 bucket for logs.
   - Use CloudWatch Logs or configure Apache to log directly to the S3 bucket.

### 🔹 Challenge 8: Create AMI from WordPress Instance and Snapshot from MySQL Instance Volume as a backup
1. **Create AMI from WordPress Instance:**
   - In the EC2 Console, select the WordPress EC2 instance and choose "Create Image" to create an AMI.

2. Create Snapshot from MySQL Volume:
   - Go to the "Volumes" section in the EC2 Console.
   - Select the volume attached to your MySQL instance and create a snapshot.

3.Automate Backups (Optional):
   - Consider setting up an automated backup solution with CloudWatch Events or Lambda to regularly back up your WordPress AMI and MySQL snapshots.

