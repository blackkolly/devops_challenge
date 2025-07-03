Challenge 1: Provision EC2 Instance, Security Group, and Key Pair
import boto3
import paramiko
import time

# Initialize boto3 clients
ec2 = boto3.client('ec2', region_name='us-east-1')

# Create a key pair
key_pair_name = 'my-key-pair'
response = ec2.create_key_pair(KeyName=key_pair_name)
with open(f'{key_pair_name}.pem', 'w') as f:
    f.write(response['KeyMaterial'])

# Create a security group
security_group_name = 'my-security-group'
response = ec2.create_security_group(
    GroupName=security_group_name,
    Description='Security group for SSH access'
)
security_group_id = response['GroupId']

# Add SSH rule to the security group
ec2.authorize_security_group_ingress(
    GroupId=security_group_id,
    IpPermissions=[
        {
            'IpProtocol': 'tcp',
            'FromPort': 22,
            'ToPort': 22,
            'IpRanges': [{'CidrIp': '0.0.0.0/0'}]
        }
    ]
)

# Launch an EC2 instance
instance = ec2.run_instances(
    ImageId='ami-0c02fb55956c7d316',  # Amazon Linux 2 AMI
    MinCount=1,
    MaxCount=1,
    InstanceType='t2.micro',
    KeyName=key_pair_name,
    SecurityGroupIds=[security_group_id]
)
instance_id = instance['Instances'][0]['InstanceId']

# Wait for the instance to be running
waiter = ec2.get_waiter('instance_running')
waiter.wait(InstanceIds=[instance_id])

# Get the public IP address of the instance
instance = ec2.describe_instances(InstanceIds=[instance_id])
public_ip = instance['Reservations'][0]['Instances'][0]['PublicIpAddress']

# SSH into the instance to verify
key = paramiko.RSAKey.from_private_key_file(f'{key_pair_name}.pem')
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

try:
    ssh.connect(hostname=public_ip, username='ec2-user', pkey=key)
    stdin, stdout, stderr = ssh.exec_command('echo "Hello, World!"')
    print(stdout.read().decode())
finally:
    ssh.close()
  
  Challenge 2: Automate S3 Lifecycle Policies
import boto3

# Initialize boto3 client
s3 = boto3.client('s3')

# Define the bucket name and lifecycle policy
bucket_name = 'my-bucket'
lifecycle_policy = {
    'Rules': [
        {
            'ID': 'MoveToGlacierAfter30Days',
            'Status': 'Enabled',
            'Filter': {'Prefix': ''},
            'Transitions': [
                {
                    'Days': 30,
                    'StorageClass': 'GLACIER'
                }
            ]
        }
    ]
}

# Apply the lifecycle policy to the bucket
s3.put_bucket_lifecycle_configuration(
    Bucket=bucket_name,
    LifecycleConfiguration=lifecycle_policy
)
print(f"Lifecycle policy applied to {bucket_name}.")

Challenge 3: Start or Stop All EC2 Instances in a Specific Region

import boto3

# Initialize boto3 client
ec2 = boto3.client('ec2', region_name='us-east-1')

# Start or stop instances
action = 'stop'  # Change to 'start' to start instances
instances = ec2.describe_instances()

for reservation in instances['Reservations']:
    for instance in reservation['Instances']:
        instance_id = instance['InstanceId']
        if action == 'stop':
            ec2.stop_instances(InstanceIds=[instance_id])
            print(f"Stopped instance: {instance_id}")
        elif action == 'start':
            ec2.start_instances(InstanceIds=[instance_id])
            print(f"Started instance: {instance_id}")

Challenge 4: Check for Unused IAM Users and Disable Them

import boto3
from datetime import datetime, timedelta

# Initialize boto3 client
iam = boto3.client('iam')

# Get all IAM users
users = iam.list_users()['Users']

# Check for unused users (no login in last 90 days)
for user in users:
    username = user['UserName']
    access_keys = iam.list_access_keys(UserName=username)['AccessKeyMetadata']
    last_used = iam.get_user_last_accessed_info(UserName=username)['ServicesLastAccessed']

    if not access_keys and not last_used:
        print(f"Disabling unused user: {username}")
        iam.update_user(UserName=username, Disabled=True)

Challenge 5: Log Monitoring System for EC2 Instances
import boto3
import paramiko
import smtplib
from email.mime.text import MIMEText

# Initialize boto3 client
ec2 = boto3.client('ec2', region_name='us-east-1')

# SSH into the instance and check logs
def check_logs(public_ip, key):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=public_ip, username='ec2-user', pkey=key)
    stdin, stdout, stderr = ssh.exec_command('grep -i error /var/log/syslog')
    errors = stdout.read().decode()
    ssh.close()
    return errors

# Send email alert
def send_email(error_message):
    msg = MIMEText(error_message)
    msg['Subject'] = 'EC2 Log Error Alert'
    msg['From'] = 'sender@example.com'
    msg['To'] = 'receiver@example.com'

    with smtplib.SMTP('email-smtp.us-east-1.amazonaws.com', 587) as server:
        server.starttls()
        server.login('smtp_username', 'smtp_password')
        server.sendmail('sender@example.com', 'receiver@example.com', msg.as_string())

# Main logic
key = paramiko.RSAKey.from_private_key_file('my-key-pair.pem')
instance = ec2.describe_instances(InstanceIds=['i-1234567890abcdef0'])
public_ip = instance['Reservations'][0]['Instances'][0]['PublicIpAddress']

errors = check_logs(public_ip, key)
if errors:
    send_email(errors)
  
  Challenge 6: Automate DNS Record Updates in Route 53
import boto3

# Initialize boto3 client
route53 = boto3.client('route53')

# Update DNS record
response = route53.change_resource_record_sets(
    HostedZoneId='Z1234567890ABCDEF',
    ChangeBatch={
        'Changes': [
            {
                'Action': 'UPSERT',
                'ResourceRecordSet': {
                    'Name': 'example.com.',
                    'Type': 'A',
                    'TTL': 300,
                    'ResourceRecords': [{'Value': '192.0.2.1'}]
                }
            }
        ]
    }
)
print("DNS record updated.")

Challenge 7: Trigger AWS Lambda Function
import boto3

# Initialize boto3 client
lambda_client = boto3.client('lambda')

# Invoke Lambda function
response = lambda_client.invoke(
    FunctionName='my-lambda-function',
    InvocationType='RequestResponse',  # Use 'Event' for async
    Payload='{"key": "value"}'
)
print(response['Payload'].read().decode())

Challenge 8: Fetch AWS Billing Data and Generate PDF Report

import boto3
from fpdf import FPDF

# Initialize boto3 client
ce = boto3.client('ce')

# Fetch billing data
response = ce.get_cost_and_usage(
    TimePeriod={
        'Start': '2023-01-01',
        'End': '2023-01-31'
    },
    Granularity='MONTHLY',
    Metrics=['UnblendedCost']
)

# Generate PDF report
pdf = FPDF()
pdf.add_page()
pdf.set_font("Arial", size=12)

for result in response['ResultsByTime']:
    cost = result['Total']['UnblendedCost']['Amount']
    pdf.cell(200, 10, txt=f"Cost for {result['TimePeriod']['Start']}: ${cost}", ln=True)

pdf.output("aws_cost_report.pdf")
print("Cost report generated.")
