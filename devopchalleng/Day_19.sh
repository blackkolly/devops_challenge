Challenges
🔹 Challenge 1: Create a MySQL or PostgreSQL RDS instance using the AWS Console
🔹 Challenge 2: Connect to the RDS instance using DBeaver, MySQL CLI, or psql (based on what DB you have selected)
🔹 Challenge 3: Create a sample table, insert some records, and query them
🔹 Challenge 4: Enable automated backups and take a manual snapshot
🔹 Challenge 5: Create a read-only IAM user with access to RDS monitoring only

🔹 Challenge 6: Launch RDS in a private subnet and connect using a Bastion Host
🔹 Challenge 7: Configure an RDS parameter group to change a DB setting (e.g., max_connections)
🔹 Challenge 8: Set up CloudWatch Alarms for high CPU or storage usage
🔹 Challenge 9: Use RDS Snapshot Restore to clone your DB into a new instance
🔹 Challenge 10: Use AWS CLI to automate RDS snapshot creation

Scenario based:
🔹 Challenge 11: Host a Python app in EC2 with DB (MySQL) in RDS

💡 Step 1: Deploy a simple Flask or Node.js app on EC2
💡 Step 2: Store app data (users, posts, etc.) in your Amazon RDS database
💡 Step 3: Configure CloudWatch Alarms for database health
💡 Step 4: Schedule a snapshot and demonstrate recovery
💡 Step 5: Document and push your setup to GitHub

Let's break down the challenges one by one and go through the steps to complete them using AWS and a database (MySQL or PostgreSQL). I'll guide you on how to approach each one:

### **Challenge 1: Create a MySQL or PostgreSQL RDS instance using the AWS Console**

1. **Login to AWS Console:**
   - Open the [AWS Management Console](https://aws.amazon.com/console/) and log in with your credentials.

2. **Navigate to Amazon RDS:**
   - In the search bar at the top, type “RDS” and click on the Amazon RDS service.

3. **Create a New DB Instance:**
   - In the left-hand menu, click on “Databases.”
   - Click on the “Create database” button.
   - Select either **MySQL** or **PostgreSQL** depending on which you want to use.
   - Choose a **DB instance class** (e.g., db.t3.micro for a free-tier eligible instance).
   - Set the **DB instance identifier** (e.g., `mydb-instance`).
   - Set the **Master username** and **Master password** (you’ll use these credentials to connect to the database).

4. **Configure Advanced Settings:**
   - Choose the **VPC** and **Subnet** where the instance will be deployed.
   - Set up other configurations such as storage size, backup, maintenance, etc.

5. **Launch the DB Instance:**
   - After configuring all options, click on “Create database.”
   - The DB instance will take a few minutes to launch.

---

### **Challenge 2: Connect to the RDS instance using DBeaver, MySQL CLI, or psql**

Once your DB instance is available, you can connect to it using different tools.

#### **Using DBeaver (GUI for MySQL/PostgreSQL):**

1. **Install DBeaver:**
   - If you don’t have it, download and install [DBeaver](https://dbeaver.io/download/).

2. **Open DBeaver and Create a New Connection:**
   - Open DBeaver and click on the **New Database Connection** button.
   - Select either **MySQL** or **PostgreSQL** based on your instance.
   - In the connection settings, enter the following details:
     - **Host:** The endpoint of your RDS instance (you can find this in the AWS RDS Console under your DB instance details).
     - **Port:** Default is 3306 for MySQL, 5432 for PostgreSQL.
     - **Database name:** (You can leave this blank if it’s the default database).
     - **Username & Password:** The credentials you set up when creating the RDS instance.
   - Click **Test Connection** to ensure it works and then click **Finish**.

#### Using MySQL CLI:

1. Open the terminal and run the following command:
   ```bash
   mysql -h <RDS-endpoint> -u <username> -p
   ```
   Replace `<RDS-endpoint>` with your RDS instance’s endpoint, and `<username>` with your master username.
   Enter the password when prompted.

#### Using psql (for PostgreSQL):

1. Open the terminal and run the following command:
   ```bash
   psql -h <RDS-endpoint> -U <username> -d <database-name>
   ```
   Replace `<RDS-endpoint>`, `<username>`, and `<database-name>` accordingly.

---

### Challenge 3: Create a sample table, insert some records, and query them

#### Creating a Sample Table and Inserting Data:

1. MySQL:
   ```sql
   CREATE DATABASE mydb;
   USE mydb;

   CREATE TABLE users (
       id INT AUTO_INCREMENT PRIMARY KEY,
       name VARCHAR(100),
       email VARCHAR(100)
   );

   INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com');
   INSERT INTO users (name, email) VALUES ('Jane Smith', 'jane@example.com');
   ```

2. PostgreSQL:
   ```sql
   CREATE DATABASE mydb;
   \c mydb  -- Connect to the database

   CREATE TABLE users (
       id SERIAL PRIMARY KEY,
       name VARCHAR(100),
       email VARCHAR(100)
   );

   INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com');
   INSERT INTO users (name, email) VALUES ('Jane Smith', 'jane@example.com');
   ```

#### Querying the Data:
- MySQL:
  ```sql
  SELECT * FROM users;
  ```

- **PostgreSQL:
  ```sql
  SELECT * FROM users;
  ```

---

### Challenge 4: Enable automated backups and take a manual snapshot

1. Enable Automated Backups:
   - Go to your RDS instance in the AWS Management Console.
   - Under the Backups tab, ensure Automated backups is enabled. This will allow automatic backups to occur daily.
   - You can adjust the retention period and backup window here.

2. Take a Manual Snapshot:
   - In the RDS Console, go to your DB instance and click Actions > Take snapshot.
   - Provide a name for your snapshot (e.g., `mydb-snapshot`), and click Take Snapshot.
   - The snapshot will be available in the Snapshots section.

---

### Challenge 5: Create a read-only IAM user with access to RDS monitoring only

1. Create the IAM User:
   - In the AWS Management Console, go to IAM.
   - Click Users and then **Add user.
   - Set the username (e.g., `readonly-user`) and choose Programmatic access and/or AWS Management Console access.

2. Assign Permissions:
   - In the permissions section, select Attach policies directly.
   - Attach the `AmazonRDSReadOnlyAccess` policy to give the user read-only access to RDS instances.
   - Additionally, if you want the user to have access to RDS monitoring, attach the `CloudWatchReadOnlyAccess` policy.

3. Review and Create the User:
   - Review the user’s permissions and click Create user.

These are excellent challenges that focus on different aspects of AWS RDS (Relational Database Service) and associated AWS services. Below are step-by-step guides for each challenge:

---

### 🔹 **Challenge 6: Launch RDS in a Private Subnet and Connect Using a Bastion Host

1. Create a VPC:
   - Set up a new Virtual Private Cloud (VPC) with at least two subnets (one public and one private).
   - Ensure that the private subnet does not have a direct route to the internet.

2. Launch a Bastion Host:
   - In the public subnet, launch an EC2 instance (e.g., an Amazon Linux 2 instance) and configure it as a Bastion Host.
   - Attach a security group to the Bastion Host that allows SSH access (port 22) only from your IP address.

3. Launch RDS in a Private Subnet:
   - Launch an RDS instance (e.g., MySQL, PostgreSQL) within the private subnet.
   - Make sure the RDS instance does not have a public IP address.
   - Configure the security group of the RDS instance to allow inbound traffic only from the Bastion Host.

4. Connect to the RDS Instance:
   - SSH into the Bastion Host.
   - From the Bastion Host, use `ssh` or an RDS client tool (like MySQL CLI or pgAdmin) to connect to the RDS instance using its private IP address.

---

### 🔹 Challenge 7: Configure an RDS Parameter Group to Change a DB Setting (e.g., max_connections)

1. Create a Custom Parameter Group:
   - In the RDS Console, go to Parameter Groups.
   - Create a new custom parameter group for the DB engine you are using (e.g., MySQL, PostgreSQL).
   - Set parameters like `max_connections` according to your needs.

2. Modify RDS Instance to Use the Custom Parameter Group:
   - Go to the RDS console and select your RDS instance.
   - Under the "Configuration" tab, modify the instance to use the newly created custom parameter group.
   - Save and apply the changes. Some parameters may require a reboot of the RDS instance.

3. Verify the Changes:
   - Connect to your database instance and run SQL commands like `SHOW VARIABLES LIKE 'max_connections';` (for MySQL) to verify the new setting.

---

### 🔹 Challenge 8: Set Up CloudWatch Alarms for High CPU or Storage Usage

1. Navigate to CloudWatch:
   - In the AWS Management Console, go to **CloudWatch** and select **Alarms**.

2. Create a New Alarm:
   - Click on **Create Alarm** and select the **RDS** namespace.
   - Choose a metric like `CPUUtilization` or `FreeStorageSpace`.
   - Set a threshold for the alarm (e.g., CPU utilization > 80% for 5 minutes).

3. Set Notification Actions:
   - Choose an SNS topic to receive notifications if the alarm is triggered.
   - You can create a new SNS topic if one does not exist.
   
4. Confirm and Review:
   - Review the alarm configuration and create the alarm.

5. Verify:
   - Once the alarm is created, check the Alarms section in CloudWatch to monitor CPU and storage utilization.

---

### 🔹 Challenge 9: Use RDS Snapshot Restore to Clone Your DB into a New Instance

1. Create a Snapshot of the Existing DB:
   - Go to the RDS console and select your DB instance.
   - Click Actions and then Take snapshot.
   - Provide a name for the snapshot and create it.

2. Restore the Snapshot:
   - Once the snapshot is complete, go to the Snapshots section in the RDS console.
   - Select the snapshot and choose Restore Snapshot.
   - Configure the settings for the new DB instance (e.g., instance type, storage type).
   - Click Restore DB Instance to create a new instance based on the snapshot.

3. **Verify**:
   - Once the restore is complete, you can connect to the new instance to ensure it is a clone of the original database.

---

### 🔹 Challenge 10: Use AWS CLI to Automate RDS Snapshot Creation

1. Install AWS CLI
   - Ensure that the AWS CLI is installed and configured with the necessary IAM permissions to create snapshots.

2. Create a Snapshot Using the AWS CLI:
   - Use the following command to create a snapshot of an RDS instance:
     ```bash
     aws rds create-db-snapshot --db-snapshot-identifier <snapshot-name> --db-instance-identifier <db-instance-id>
     ```
   - Replace `<snapshot-name>` with a unique snapshot name and `<db-instance-id>` with the ID of the RDS instance.

3. Automate Snapshot Creation (e.g., using a cron job):
   - You can automate snapshot creation by scheduling the above command using cron (Linux) or Task Scheduler (Windows) to run at specific intervals.

4. Verify:
   - Use the following command to verify the snapshot status:
     ```bash
     aws rds describe-db-snapshots --db-instance-identifier <db-instance-id>
     ```
🔹 Challenge 11: Host a Python app in EC2 with DB (MySQL) in RDS

### Step 1: Deploy a Simple Flask App on EC2
1. **Launch an EC2 Instance:**
   - Go to the AWS EC2 dashboard and launch a new instance.
   - Select the Amazon Linux 2 AMI or any other preferred OS.
   - Choose an instance type (e.g., `t2.micro` if you're using the free tier).
   - Configure security groups to allow inbound traffic on port `22` (for SSH) and port `80` (for HTTP).
   - Generate a new key pair to access your instance and download it.

2. SSH into Your EC2 Instance:
   - Open a terminal and use the SSH command to access your EC2 instance:
     ```bash
     ssh -i /path/to/your-key.pem ec2-user@<your-ec2-public-ip>
     ```

3. Install Required Dependencies:
   - Update the instance and install necessary tools (Python, Flask, pip, etc.):
     ```bash
     sudo yum update -y
     sudo yum install python3 -y
     sudo yum install git -y
     sudo yum install gcc python3-dev -y
     ```

4. Create a Flask Application:
   - Create a simple Flask app that displays a "Hello World" message.
     ```bash
     mkdir myflaskapp
     cd myflaskapp
     python3 -m venv venv
     source venv/bin/activate
     pip install flask
     ```

   - Create a `app.py` file:
     ```python
     from flask import Flask
     app = Flask(__name__)

     @app.route('/')
     def hello_world():
         return 'Hello World from EC2 and Flask!'

     if __name__ == '__main__':
         app.run(host='0.0.0.0', port=80)
     ```

5. Run the Flask App:
   - Run your Flask app on EC2:
     ```bash
     python app.py
     ```

6. Test the Flask App:
   - Open your web browser and go to your EC2 instance’s public IP (e.g., `http://<your-ec2-public-ip>`). You should see the "Hello World" message.

### Step 2: Store App Data in Amazon RDS (MySQL)
1. **Create an RDS Instance:**
   - Go to the AWS RDS dashboard and click **Create database.
   - Choose MySQL as the database engine.
   - Select the version and instance size (e.g., `db.t2.micro` for the free tier).
   - Set up the master username, password, and DB name (e.g., `flaskdb`).
   - In the "Connectivity" section, make sure the VPC, subnet, and security groups are configured to allow access from your EC2 instance.

2. Connect EC2 to RDS:
   - Make sure your EC2 instance can connect to the RDS instance by modifying the security group rules to allow inbound MySQL traffic on port 3306.
   - Install `mysql` client on your EC2 instance:
     ```bash
     sudo yum install mysql -y
     ```
   - Test the connection from EC2 to RDS:
     ```bash
     mysql -h <your-rds-endpoint> -u <your-username> -p
     ```

3. **Configure Flask to Use RDS:**
   - Install MySQL client libraries for Python:
     ```bash
     pip install mysql-connector
     ```
   - Modify the `app.py` to connect to MySQL and store data:
     ```python
     import mysql.connector
     from flask import Flask, request

     app = Flask(__name__)

     def get_db_connection():
         conn = mysql.connector.connect(
             host='<your-rds-endpoint>',
             user='<your-username>',
             password='<your-password>',
             database='<your-database>'
         )
         return conn

     @app.route('/')
     def hello_world():
         return 'Hello World from EC2 and Flask!'

     @app.route('/add_user', methods=['POST'])
     def add_user():
         name = request.form['name']
         conn = get_db_connection()
         cursor = conn.cursor()
         cursor.execute('INSERT INTO users (name) VALUES (%s)', (name,))
         conn.commit()
         cursor.close()
         conn.close()
         return f'User {name} added to the database!'

     if __name__ == '__main__':
         app.run(host='0.0.0.0', port=80)
     ```

### Step 3: Configure CloudWatch Alarms for Database Health
1. Create a CloudWatch Alarm for RDS:
   - Go to the **CloudWatch** dashboard in AWS.
   - Navigate to Alarms > Create Alarm.
   - Choose the metric `RDS > Per-Database Metrics > DBInstance > CPUUtilization` or any other relevant metric for your database.
   - Set the threshold (e.g., CPU utilization over 90% for 5 minutes) to trigger the alarm.
   - Choose an action, such as sending an SNS notification.

2. Verify Alarm Configuration:
   - Once the alarm is set, check CloudWatch to see if it triggers correctly under the alarm conditions.

### Step 4: Schedule a Snapshot and Demonstrate Recovery
1. Create an RDS Snapshot:
   - In the **RDS** dashboard, select your RDS instance.
   - Choose **Actions** > **Take Snapshot** to create a manual backup.

2. Restore the Snapshot:
   - To simulate recovery, restore the snapshot by selecting Actions > Restore Snapshot and choose the appropriate options.

3. Verify Database Recovery:
   - After restoring, verify that the data is intact and the database is operational.

### Step 5: Document and Push to GitHub
1. Create a Git Repository:**
   - In the `myflaskapp` directory, initialize a Git repository:
     ```bash
     git init
     git add .
     git commit -m "Initial commit for Flask app with RDS"
     ```

2. Push to GitHub:
   - Create a new repository on GitHub.
   - Add the remote and push your changes:
     ```bash
     git remote add origin https://github.com/your-username/repository-name.git
     git push -u origin master
     ```

3. Document the Process:
   - In the GitHub repository, create a `README.md` file to document the entire process, including:
     - EC2 setup
     - Flask app creation
     - RDS database setup
     - CloudWatch alarm configuration
     - Snapshot and recovery demonstration




