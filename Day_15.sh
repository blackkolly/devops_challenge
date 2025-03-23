🔹 Challenge 1: Custom VPC with a /16 CIDR block.

🔹 Challenge 2: Create Two Subnets – One Public and One Private.

🔹 Challenge 3: Attach an Internet Gateway and update route tables.

🔹 Challenge 4: Launch an EC2 Instance in the Public Subnet and allow SSH access.

🔹 Challenge 5: Create a Private EC2 Instance in the Private Subnet.

🔹 Challenge 6: Set Up a NAT Gateway to allow outbound traffic from the Private Subnet.

🔹 Challenge 7: Create and Configure Security Groups for EC2 instances.

🔹 Challenge 8: Test Connectivity between Public and Private EC2 instances.

🔹 Challenge 9: Enable VPC Flow Logs to monitor traffic.

Scenario Based:
🔹 Challenge 10:
Your firm’s security head asked you to implement a Bastion host setup and connect to other ec2 instances via this Bastion host only.

Tasks:
Set up a Bastion Host to securely access private instances inside your AWS VPC without exposing them directly to the internet.

🔹 Steps to Complete the Challenge:

Create a Public Subnet and launch an EC2 instance (Bastion Host) with only SSH access enabled from your IP. (You can use existing Ec2 instance on Public Subnet)

Create another EC2 instance (target instance) in a Private Subnet with NO direct internet access.

Attach Security Groups:

Bastion Host: Allow inbound SSH (port 22) from your IP.

Private EC2: Allow inbound SSH (port 22) only from the Bastion Host’s Security Group.

Configure SSH Access:

SSH into the Bastion Host.

From the Bastion Host, SSH into the private instance using its private IP.

Test Connectivity:

Verify that the Private EC2 instance is NOT directly accessible from the internet.

Ensure the Bastion Host is the only way to access it.






Here’s a step-by-step guide to completing the challenges you’ve outlined using **Amazon Web Services (AWS)**:

---

### **Challenge 1: Custom VPC with a /16 CIDR Block**
1. **Log in to AWS Management Console** and navigate to the **VPC Dashboard**.
2. Click **Create VPC**.
3. Under **Resources to create**, select **VPC only**.
4. Configure the VPC:
   - **Name tag**: Enter a name (e.g., `MyCustomVPC`).
   - **IPv4 CIDR block**: Enter a `/16` CIDR block (e.g., `10.0.0.0/16`).
   - Leave other settings as default.
5. Click **Create VPC**.

---

### **Challenge 2: Create Two Subnets – One Public and One Private**
1. In the **VPC Dashboard**, go to **Subnets** and click **Create subnet**.
2. Select the VPC you created in Challenge 1 (e.g., `MyCustomVPC`).
3. **Create the Public Subnet**:
   - **Subnet name**: Enter a name (e.g., `PublicSubnet`).
   - **Availability Zone**: Select an AZ (e.g., `us-east-1a`).
   - **IPv4 CIDR block**: Enter a smaller CIDR block within the VPC’s range (e.g., `10.0.1.0/24`).
4. **Create the Private Subnet**:
   - Repeat the process, but name it `PrivateSubnet` and use a different CIDR block (e.g., `10.0.2.0/24`).
5. Click **Create subnet** for both.

---

### **Challenge 3: Attach an Internet Gateway and Update Route Tables**
1. **Create an Internet Gateway (IGW)**:
   - In the **VPC Dashboard**, go to **Internet Gateways** and click **Create internet gateway**.
   - Name it (e.g., `MyIGW`) and click **Create**.
   - Select the IGW, click **Actions**, and choose **Attach to VPC**.
   - Select your VPC (e.g., `MyCustomVPC`) and click **Attach**.
2. **Update Route Tables**:
   - Go to **Route Tables** in the VPC Dashboard.
   - Locate the route table associated with your VPC (it will be created by default).
   - **Edit Routes**:
     - Add a route with:
       - **Destination**: `0.0.0.0/0`
       - **Target**: Select the IGW you created (e.g., `MyIGW`).
   - **Associate the Public Subnet**:
     - Go to **Subnet Associations**, click **Edit subnet associations**, and associate the `PublicSubnet`.

---

### **Challenge 4: Launch an EC2 Instance in the Public Subnet and Allow SSH Access**
1. **Launch an EC2 Instance**:
   - Go to the **EC2 Dashboard** and click **Launch Instance**.
   - Choose an AMI (e.g., Amazon Linux 2).
   - Select an instance type (e.g., `t2.micro`).
   - In the **Network settings**, select your VPC (`MyCustomVPC`) and the `PublicSubnet`.
   - Enable **Auto-assign Public IP**.
   - Configure a **Security Group**:
     - Add a rule to allow SSH (port 22) from your IP or `0.0.0.0/0` (for testing purposes).
   - Launch the instance.
2. **SSH into the Instance**:
   - Use the public IP of the instance and your private key to SSH into it:
     ```bash
     ssh -i your-key.pem ec2-user@<public-ip>
     ```

---

### **Challenge 5: Create a Private EC2 Instance in the Private Subnet**
1. **Launch an EC2 Instance**:
   - Go to the **EC2 Dashboard** and click **Launch Instance**.
   - Choose an AMI (e.g., Amazon Linux 2).
   - Select an instance type (e.g., `t2.micro`).
   - In the **Network settings**, select your VPC (`MyCustomVPC`) and the `PrivateSubnet`.
   - Disable **Auto-assign Public IP** (since it’s private).
   - Configure a **Security Group**:
     - Add a rule to allow SSH (port 22) from the `PublicSubnet` CIDR (e.g., `10.0.1.0/24`).
   - Launch the instance.
2. **Access the Private Instance**:
   - Since the private instance has no public IP, you’ll need to SSH into it via the public instance (using SSH tunneling or a bastion host setup).
   - SSH into the public instance first, then SSH into the private instance using its private IP:
     ```bash
     ssh -i your-key.pem ec2-user@<private-ip>
     ```
     Here’s a breakdown of how you can approach and implement each challenge step-by-step:

---

### **Challenge 6: Set Up a NAT Gateway to Allow Outbound Traffic from the Private Subnet**

A NAT Gateway allows EC2 instances in a private subnet to access the internet (for example, for software updates or accessing S3 buckets) without allowing incoming traffic from the internet.

**Steps:**
1. **Create a NAT Gateway:**
   - Ensure you have an **Elastic IP** allocated for the NAT Gateway.
   - Create the NAT Gateway in a **public subnet** and associate the Elastic IP with it.
   
2. **Update Route Table for Private Subnet:**
   - Go to the **Route Tables** section in the VPC dashboard.
   - Select the route table associated with your private subnet.
   - Add a route that directs all internet-bound traffic (0.0.0.0/0) to the NAT Gateway.

3. **Ensure Internet Access for the Public Subnet:**
   - Make sure the public subnet’s route table directs outbound traffic (0.0.0.0/0) to an **Internet Gateway**.

---

### **Challenge 7: Create and Configure Security Groups for EC2 Instances**

Security groups act as virtual firewalls to control the inbound and outbound traffic for your EC2 instances.

**Steps:**
1. **Create a Security Group for the EC2 Instances:**
   - Go to **Security Groups** in the VPC dashboard.
   - Click on **Create Security Group**, and name it appropriately (e.g., `SG-EC2-Public` for public-facing EC2 instances).
   
2. **Configure Inbound Rules:**
   - For a public EC2 instance (web server), allow HTTP (port 80) and SSH (port 22) from trusted sources, like your IP address.
   - For a private EC2 instance, you might not need inbound rules for the internet but need access from other instances in the VPC.

3. **Configure Outbound Rules:**
   - By default, security groups allow all outbound traffic. You can adjust this if needed.
   
4. **Associate Security Groups with EC2 Instances:**
   - When launching an EC2 instance, you can associate the appropriate security group.
   
5. **Create Separate Security Groups for Different Roles:**
   - You can create distinct security groups for private EC2s (restricting inbound traffic to only allow communication from public EC2s) and public EC2s.

---

### **Challenge 8: Test Connectivity Between Public and Private EC2 Instances**

After setting up your network and security groups, you can test communication between the public and private EC2 instances.

**Steps:**
1. **Launch EC2 Instances:**
   - Ensure you have one EC2 instance in the public subnet and one in the private subnet.
   - Attach the appropriate security groups to these instances (as discussed above).

2. **Testing Connectivity:**
   - **From the public EC2 instance**, try to SSH into the private EC2 instance if it’s allowed by security groups.
     - You will likely use a bastion host (or jump box) in the public subnet to SSH into the private instance.
   - **Check the Network ACLs and Security Groups**: Ensure they allow the traffic from public EC2 to private EC2 on the required ports.
   
3. **Testing the NAT Gateway:**
   - **From the private EC2 instance**, try to ping an external IP (like Google’s 8.8.8.8) to ensure outbound traffic works through the NAT Gateway.

---

### **Challenge 9: Enable VPC Flow Logs to Monitor Traffic**

VPC Flow Logs capture information about the IP traffic going to and from network interfaces in your VPC, which can be helpful for debugging and monitoring network traffic.

**Steps:**
1. **Enable Flow Logs:**
   - Go to **VPC** in the AWS Management Console.
   - In the left menu, select **Flow Logs**.
   - Click on **Create Flow Log**.
   
2. **Configure Flow Log Settings:**
   - Choose the **VPC** where you want to monitor the traffic.
   - Set the **Filter** to `ALL`, `ACCEPT`, or `REJECT` depending on the level of detail you want.
   - Choose a **CloudWatch Log Group** or create a new one to store the logs.
   - Choose an **IAM role** that allows VPC Flow Logs to publish to CloudWatch.

3. **Review Flow Logs:**
   - Once the logs are set up, go to **CloudWatch Logs** and review the logs to monitor traffic between EC2 instances and other resources.
   
   The flow logs will give you detailed information about the source, destination, ports, and protocols of traffic going through your VPC.

---
To complete this challenge, the task is to set up a **Bastion Host** and configure secure SSH access from the Bastion Host to another **private EC2 instance** in your AWS VPC. Here's a step-by-step guide to help you set it up:

---10 CHALLENGE

### **Step 1: Set Up VPC and Subnets**
1. **Create a VPC** (if one doesn't already exist):
   - Open the **VPC dashboard** in the AWS console.
   - Click on **Create VPC**, and follow the steps to create a VPC.
   - You can use the default settings or customize CIDR blocks as needed.
   
2. **Create Public and Private Subnets** within the VPC:
   - In the **VPC dashboard**, go to **Subnets**.
   - Create a **Public Subnet** in one availability zone.
     - Set the CIDR block for this subnet (e.g., `10.0.1.0/24`).
     - Enable **Auto-assign public IP** for this subnet.
   - Create a **Private Subnet** in another availability zone.
     - Set the CIDR block for this subnet (e.g., `10.0.2.0/24`).
     - Do **NOT** enable **Auto-assign public IP** for this subnet.

---

### **Step 2: Launch the Bastion Host (Public Subnet)**
1. **Create an EC2 instance** for the Bastion Host:
   - Go to **EC2 Dashboard** → **Launch Instance**.
   - Select an **Amazon Linux 2** or other preferred AMI.
   - Choose an instance type (e.g., **t2.micro** for the free tier).
   - For the **VPC**, select the one you created earlier.
   - In the **Subnet**, select the **Public Subnet**.
   - Assign a **public IP** to this instance.
   - Add **SSH** Key Pair for secure SSH access (make sure you download and store the private key securely).

2. **Configure Security Group for Bastion Host**:
   - Create a security group for the Bastion Host (or use an existing one).
   - Add an inbound rule to allow SSH (port 22) from **your IP address** only:
     - **Type:** SSH
     - **Protocol:** TCP
     - **Port Range:** 22
     - **Source:** Your IP (e.g., `203.0.113.1/32`).

---

### **Step 3: Launch the Target EC2 Instance (Private Subnet)**
1. **Create an EC2 instance** for the target (private) instance:
   - Go to **EC2 Dashboard** → **Launch Instance**.
   - Choose an AMI (e.g., **Amazon Linux 2** or similar).
   - Select the **Private Subnet** for this instance.
   - **Do NOT assign a public IP** to this instance.
   - Use the **same VPC** as the Bastion Host.

2. **Configure Security Group for Private EC2**:
   - Create a security group for the private EC2 instance (or use an existing one).
   - Add an inbound rule to allow SSH (port 22) **only from the Bastion Host's security group**:
     - **Type:** SSH
     - **Protocol:** TCP
     - **Port Range:** 22
     - **Source:** The security group of the Bastion Host.

---

### **Step 4: Testing SSH Access**

1. **SSH into the Bastion Host**:
   - Open your terminal or an SSH client.
   - Use the **private key** associated with the Bastion Host EC2 instance to SSH into it:
     ```bash
     ssh -i /path/to/bastion-key.pem ec2-user@<Bastion-Host-Public-IP>
     ```

2. **SSH from Bastion Host to Private EC2 Instance**:
   - Once logged into the Bastion Host, SSH into the private EC2 instance using its **private IP**:
     ```bash
     ssh ec2-user@<Private-EC2-IP>
     ```
   - This will connect to the private EC2 instance via the Bastion Host.

---

### **Step 5: Verify Security Group Rules**
- **Bastion Host Security Group** should only allow inbound SSH (port 22) from your IP.
- **Private EC2 Security Group** should only allow inbound SSH (port 22) from the **Bastion Host's Security Group**.

This ensures that the **Private EC2 instance** is not directly accessible from the internet, and all SSH connections must go through the **Bastion Host**.

---

### **Summary of Setup**

- **Bastion Host**: Public EC2 instance with SSH access allowed only from your IP.
- **Private EC2**: Private EC2 instance without internet access and SSH access allowed only from the Bastion Host.
- **Security Groups**: Carefully configured to ensure no direct access to the private instance from the public internet.

This setup provides a secure way to access private instances by using the Bastion Host as a jump point, enhancing security for your AWS infrastructure.
