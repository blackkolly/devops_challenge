🔹 Challenge 1: Create a DynamoDB table (Users) with user_id as the partition key + other attributes: name, email.
🔹 Challenge 2: Insert 5+ records manually using AWS Console
🔹 Challenge 3: Use AWS CLI to insert a record
🔹 Challenge 4: Query a record using GetItem with the partition key

🔹 Challenge 5: Update an existing item’s attribute using AWS CLI or SDK
🔹 Challenge 6: Create a Global Secondary Index (GSI) on a different attribute (e.g., email)
🔹 Challenge 7: Set up Time To Live (TTL) to auto-expire a record
🔹 Challenge 8: Configure a CloudWatch Alarm for high read/write throughput
🔹 Challenge 9: Use Python (Boto3) to script a CRUD operation workflow for the users table

🔹 Challenge 10: Attach IAM permissions/role to allow read/write access via an EC2 and run challenge 9 codes from there

Let's break down each of the challenges and steps involved:


### Challenge 1: Create a DynamoDB table (Users) with `user_id` as the partition key + other attributes: `name`, `email`.

1. Log in to the AWS Console.
2. Navigate to DynamoDB:
   - Go to the Services tab in the AWS Management Console, and search for DynamoDB.
3. Create a new Table:
   - Click on Create Table.
   - Enter Table name: `Users`.
   - Set Partition key to `user_id` (String).
   - You can leave the rest of the settings at default (for now) or configure according to your needs (like Provisioned or On-demand mode).
   - Click Create.

---

### Challenge 2: Insert 5+ records manually using AWS Console

1. Navigate to the newly created Users table:
   - In the DynamoDB Console, click on the Users table.
2. Insert Items:
   - Click on Items in the left sidebar.
   - Click Create item
   - Add the attributes for each user:
     - user_id: Unique string (e.g., `user001`, `user002`).
     - **name**: User's name (e.g., `Alice`, `Bob`).
     - email: User's email (e.g., `alice@example.com`).
   - Click Save.
   - Repeat this process for 5+ records (using different `user_id` values).

---

### Challenge 3: Use AWS CLI to insert a record

Prerequisite: Make sure you have AWS CLI installed and configured with the proper IAM permissions.

1. **Insert a record using AWS CLI**:
   Run the following command in your terminal:

   ```bash
   aws dynamodb put-item \
     --table-name Users \
     --item '{
       "user_id": {"S": "user006"},
       "name": {"S": "Charlie"},
       "email": {"S": "charlie@example.com"}
     }'
   ```

   - This will insert a new record with `user_id` as `user006`, `name` as `Charlie`, and `email` as `charlie@example.com`.

---

### Challenge 4: Query a record using `GetItem` with the partition key

1. **Get a record by partition key using AWS CLI**:
   To retrieve a record using the partition key (`user_id`), run the following command:

   ```bash
   aws dynamodb get-item \
     --table-name Users \
     --key '{
       "user_id": {"S": "user001"}
     }'
   ```

   - This retrieves the item where `user_id` is `user001`.
   
   Example output (depending on your data):

   ```json
   {
       "Item": {
           "user_id": {"S": "user001"},
           "name": {"S": "Alice"},
           "email": {"S": "alice@example.com"}
       }
   }
   ```

---

### Challenge 5: Update an existing item’s attribute using AWS CLI or SDK

1. **Update an item’s attribute using AWS CLI**:
   To update a user’s email, for example, you can use the `update-item` command. 

   Example to update `user001`'s email:

   ```bash
   aws dynamodb update-item \
     --table-name Users \
     --key '{
       "user_id": {"S": "user001"}
     }' \
     --update-expression "SET email = :email" \
     --expression-attribute-values '{
       ":email": {"S": "alice.newemail@example.com"}
     }'
   ```

   - This updates the email for the `user_id` `user001` to `alice.newemail@example.com`.

Let's break down each of these challenges step by step:

---

### Challenge 6: Create a Global Secondary Index (GSI) on a Different Attribute (e.g., email)

To create a GSI in DynamoDB on an attribute like "email," you can use the AWS Management Console, AWS CLI, or Boto3 (Python SDK). Here's how you'd do it with Boto3:

```python
import boto3

# Initialize the DynamoDB client
dynamodb = boto3.client('dynamodb')

# Define the parameters for the GSI
table_name = 'users'
gsi_name = 'EmailIndex'
email_attribute = 'email'

# Create the GSI
response = dynamodb.update_table(
    TableName=table_name,
    AttributeDefinitions=[
        {
            'AttributeName': email_attribute,
            'AttributeType': 'S'  # 'S' stands for String
        },
    ],
    GlobalSecondaryIndexUpdates=[
        {
            'Create': {
                'IndexName': gsi_name,
                'KeySchema': [
                    {
                        'AttributeName': email_attribute,
                        'KeyType': 'HASH'  # HASH means this is the partition key
                    },
                ],
                'Projection': {
                    'ProjectionType': 'ALL'  # All attributes will be projected to the index
                },
                'ProvisionedThroughput': {
                    'ReadCapacityUnits': 5,
                    'WriteCapacityUnits': 5
                }
            }
        },
    ]
)

print(response)
```

This creates a GSI with the `email` attribute as the partition key.

---

### Challenge 7: Set up Time To Live (TTL) to Auto-Expire a Record

Time To Live (TTL) allows DynamoDB to automatically delete items after a specified period. You need to set up a TTL attribute on your table, usually a timestamp, and DynamoDB will automatically delete items when the timestamp expires.

Here’s how you can set TTL using Boto3:

```python
dynamodb = boto3.client('dynamodb')

# Set TTL on the 'users' table for an attribute (e.g., 'expires_at')
table_name = 'users'
ttl_attribute = 'expires_at'

response = dynamodb.update_time_to_live(
    TableName=table_name,
    TimeToLiveSpecification={
        'Enabled': True,
        'AttributeName': ttl_attribute
    }
)

print(response)
```

Make sure that the `expires_at` attribute in each item stores a timestamp (in seconds) when the record should expire.

---

### Challenge 8: Configure a CloudWatch Alarm for High Read/Write Throughput

To configure an alarm based on read or write throughput, you need to monitor the `ConsumedReadCapacityUnits` and `ConsumedWriteCapacityUnits` metrics. Here’s an example of how you can set up a CloudWatch Alarm via Boto3:

```python
import boto3

cloudwatch = boto3.client('cloudwatch')

response = cloudwatch.put_metric_alarm(
    AlarmName='HighReadThroughput',
    ComparisonOperator='GreaterThanThreshold',
    EvaluationPeriods=1,
    MetricName='ConsumedReadCapacityUnits',
    Namespace='AWS/DynamoDB',
    Period=60,  # 1 minute
    Statistic='Sum',
    Threshold=1000,  # Set your desired threshold for read throughput
    ActionsEnabled=False,
    AlarmActions=[],
    OKActions=[],
    Dimensions=[
        {
            'Name': 'TableName',
            'Value': 'users'
        }
    ]
)

print(response)
```

You can modify the metric name and thresholds to create alarms for write throughput (`ConsumedWriteCapacityUnits`) or other metrics.

---

### Challenge 9: Use Python (Boto3) to Script a CRUD Operation Workflow for the Users Table

Below is a simple example of how you can use Boto3 to create, read, update, and delete records from a DynamoDB table:

```python
import boto3
from datetime import datetime

# Initialize the DynamoDB client
dynamodb = boto3.client('dynamodb')

# Table name
table_name = 'users'

# 1. Create - Add a new user
def create_user(user_id, email):
    response = dynamodb.put_item(
        TableName=table_name,
        Item={
            'user_id': {'S': user_id},
            'email': {'S': email},
            'created_at': {'S': datetime.now().isoformat()}
        }
    )
    return response

# 2. Read - Get a user by ID
def get_user(user_id):
    response = dynamodb.get_item(
        TableName=table_name,
        Key={
            'user_id': {'S': user_id}
        }
    )
    return response.get('Item', None)

# 3. Update - Update the email of a user
def update_user_email(user_id, new_email):
    response = dynamodb.update_item(
        TableName=table_name,
        Key={
            'user_id': {'S': user_id}
        },
        UpdateExpression="SET email = :email",
        ExpressionAttributeValues={
            ':email': {'S': new_email}
        },
        ReturnValues="UPDATED_NEW"
    )
    return response

# 4. Delete - Delete a user by ID
def delete_user(user_id):
    response = dynamodb.delete_item(
        TableName=table_name,
        Key={
            'user_id': {'S': user_id}
        }
    )
    return response

# Example usage:
create_response = create_user('123', 'user@example.com')
print(f"Created user: {create_response}")

user = get_user('123')
print(f"Fetched user: {user}")

update_response = update_user_email('123', 'newuser@example.com')
print(f"Updated user email: {update_response}")

delete_response = delete_user('123')
print(f"Deleted user: {delete_response}")
```

This script demonstrates creating, reading, updating, and deleting operations for a user table in DynamoDB.

---

### Challenge 10: Attach IAM Permissions/Role to Allow Read/Write Access via an EC2 Instance

To allow an EC2 instance to interact with DynamoDB (for CRUD operations), you can:

1. Create an IAM Role with permissions for DynamoDB access.
2. Attach the IAM Role to the EC2 instance.

Here’s an example of a policy you might attach to the role:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem",
                "dynamodb:DeleteItem"
            ],
            "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/users"
        }
    ]
}
```

- Attach this IAM role to your EC2 instance via the EC2 Console or using the AWS CLI.
- From the EC2 instance, run your Python script with `Boto3`, and the EC2 instance will have the necessary permissions.

You can assign the role using the AWS Console or CLI:

```bash
aws ec2 associate-iam-instance-profile --instance-id i-xxxxxxxx --iam-instance-profile Name="DynamoDBAccessRole"
```

Once the EC2 instance has the necessary IAM permissions, it can use the script you wrote in Challenge 9 to interact with DynamoDB.

---

Let me know if you'd like further details or help on any of these!
