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
