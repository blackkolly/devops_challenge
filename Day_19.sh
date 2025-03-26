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

### **Challenge 4: Enable automated backups and take a manual snapshot**

1. Enable Automated Backups:
   - Go to your RDS instance in the AWS Management Console.
   - Under the Backups tab, ensure Automated backups is enabled. This will allow automatic backups to occur daily.
   - You can adjust the retention period and backup window here.

2. Take a Manual Snapshot:
   - In the RDS Console, go to your DB instance and click **Actions** > **Take snapshot**.
   - Provide a name for your snapshot (e.g., `mydb-snapshot`), and click **Take Snapshot**.
   - The snapshot will be available in the **Snapshots** section.

---

### Challenge 5: Create a read-only IAM user with access to RDS monitoring only

1. Create the IAM User:
   - In the AWS Management Console, go to IAM.
   - Click **Users** and then **Add user**.
   - Set the username (e.g., `readonly-user`) and choose **Programmatic access** and/or **AWS Management Console access**.

2. Assign Permissions:
   - In the permissions section, select Attach policies directly.
   - Attach the `AmazonRDSReadOnlyAccess` policy to give the user read-only access to RDS instances.
   - Additionally, if you want the user to have access to RDS monitoring, attach the `CloudWatchReadOnlyAccess` policy.

3. Review and Create the User:
   - Review the user’s permissions and click **Create user**.

---

