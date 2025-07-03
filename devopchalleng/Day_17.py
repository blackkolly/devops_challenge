🔹 Challenge 1: Create a bucket and upload files via AWS CLI
🔹 Challenge 2: Enable versioning on the bucket, upload two versions of a file, and restore an older version
🔹 Challenge 3: Write a simple shell script to sync a local logs folder to an S3 bucket
🔹 Challenge 4: Using Python Boto3 Upload a file as a Private file
🔹 Challenge 5: Using Python Boto3 generate a signed URL to download the private file
🔹 Challenge 6: Create a Backup Script (Local > S3) and set a CRON for the same (Every midnight at 1 AM)
🔹 Challenge 7: Create a lifecycle rule to transition old files to S3 Glacier after 3 days and delete them after 30 days
🔹 Challenge 8: Enable server-side encryption using SSE-KMS and test uploading encrypted files



### 🔹 Challenge 1: Create a Bucket and Upload Files via AWS CLI

1. Create an S3 Bucket:
   Use the following command to create an S3 bucket:

   ```bash
   aws s3api create-bucket --bucket my-unique-bucket-name --region us-east-1
   ```

   Replace `my-unique-bucket-name` with your unique bucket name and `us-east-1` with your desired region.

2. Upload Files to the Bucket:
   Use this command to upload a file to the newly created S3 bucket:

   ```bash
   aws s3 cp myfile.txt s3://my-unique-bucket-name/
   ```

   Replace `myfile.txt` with the path to your file.

---

### 🔹 Challenge 2: Enable Versioning on the Bucket, Upload Two Versions of a File, and Restore an Older Version

1. Enable Versioning:
   Use this command to enable versioning on the bucket:

   ```bash
   aws s3api put-bucket-versioning --bucket my-unique-bucket-name --versioning-configuration Status=Enabled
   ```

2. Upload Two Versions of a File:
   Upload the first version of the file:

   ```bash
   aws s3 cp myfile.txt s3://my-unique-bucket-name/myfile.txt
   ```

   Modify the file (e.g., `myfile_v2.txt`), then upload the second version:

   ```bash
   aws s3 cp myfile_v2.txt s3://my-unique-bucket-name/myfile.txt
   ```

3. Restore an Older Version:
   Find the version ID of the older file by listing the versions:

   ```bash
   aws s3api list-object-versions --bucket my-unique-bucket-name
   ```

   Then, restore the older version:

   ```bash
   aws s3api copy-object --copy-source my-unique-bucket-name/myfile.txt?versionId=your-version-id --bucket my-unique-bucket-name --key myfile.txt
   ```

   Replace `your-version-id` with the actual version ID of the file you want to restore.

---

### 🔹 Challenge 3: Write a Simple Shell Script to Sync a Local Logs Folder to an S3 Bucket

1. Shell Script to Sync:

   Create a file `sync_logs.sh` with the following contents:

   ```bash
   #!/bin/bash

   # Define source directory and S3 bucket
   LOCAL_DIR="/path/to/logs/"
   S3_BUCKET="s3://my-unique-bucket-name/logs/"

   # Sync the logs to the S3 bucket
   aws s3 sync $LOCAL_DIR $S3_BUCKET --delete
   ```

   Make the script executable:

   ```bash
   chmod +x sync_logs.sh
   ```

   Run the script to sync your logs:

   ```bash
   ./sync_logs.sh
   ```

---

### 🔹 Challenge 4: Using Python Boto3 Upload a File as a Private File

1. Install Boto3:

   If you don't have Boto3 installed, you can install it using pip:

   ```bash
   pip install boto3
   ```

2. Upload a File as Private:

   Use the following Python script to upload a file as private:

   ```python
   import boto3

   s3 = boto3.client('s3')

   bucket_name = 'my-unique-bucket-name'
   file_path = 'myfile.txt'
   object_name = 'myfile.txt'

   s3.upload_file(file_path, bucket_name, object_name, ExtraArgs={'ACL': 'private'})

   print("File uploaded successfully!")
   ```

---

### 🔹 Challenge 5: Using Python Boto3 Generate a Signed URL to Download the Private File

1. Generate a Signed URL for the Private File:

   Use the following Python script to generate a signed URL:

   ```python
   import boto3

   s3 = boto3.client('s3')

   bucket_name = 'my-unique-bucket-name'
   object_name = 'myfile.txt'
   expiration = 3600  # URL valid for 1 hour

   signed_url = s3.generate_presigned_url('get_object',
                                          Params={'Bucket': bucket_name, 'Key': object_name},
                                          ExpiresIn=expiration)

   print("Signed URL:", signed_url)
   ```

   This will output a URL that can be used to download the private file for a limited time.

---
Let's break down the challenges and go through each step by step:

---

### Challenge 6: Create a Backup Script (Local > S3) and set a CRON for the same (Every midnight at 1 AM)

To create a backup script that uploads files from your local system to an S3 bucket and schedule it to run daily at 1 AM using `cron`, follow these steps:

#### 1. Create the Backup Script
First, let's create a simple shell script that uploads files from a local directory to an S3 bucket using the AWS CLI.

```bash
#!/bin/bash

# Set variables
LOCAL_DIRECTORY="/path/to/local/files"
S3_BUCKET="s3://your-bucket-name/backup/$(date +%F)"

# Create a backup directory on S3 using the current date
aws s3 mkdir "$S3_BUCKET"

# Sync local directory to S3 bucket
aws s3 sync "$LOCAL_DIRECTORY" "$S3_BUCKET"

# Optional: If you want to delete files from the local machine after upload
# rm -rf $LOCAL_DIRECTORY/*
```

#### 2. Make the Script Executable
After creating the script, make it executable.

```bash
chmod +x /path/to/your/backup_script.sh
```

#### 3. Set a CRON Job
To schedule the script to run every day at 1 AM, you need to add a cron job.

Open the crontab file:

```bash
crontab -e
```

Add the following line to run the script at 1 AM every day:

```bash
0 1  /path/to/your/backup_script.sh
```

This will run the backup script every day at 1 AM.

---

### Challenge 7: Create a lifecycle rule to transition old files to S3 Glacier after 3 days and delete them after 30 days

To configure an S3 lifecycle rule to transition files to Glacier after 3 days and delete them after 30 days:

#### 1. Create a Lifecycle Policy in S3

1. Go to the S3 Console.
2. Navigate to the S3 bucket where your backup is stored.
3. Under the Management tab, select Lifecycle rules.
4. Click on Create lifecycle rule.

#### 2. Define the Rule
- Rule Name: Transition to Glacier and Delete After 30 Days.
- Under Filter, you can select whether to apply it to all objects or specific prefixes/tags.
- Choose Transition actions:
  - Transition to Glacier after 3 days.
- Choose Expiration actions:
  - **Expire objects after 30 days**.

#### 3. Review and Save
Once you've configured the transitions and expiration actions, click Save.

This lifecycle rule will automatically move objects older than 3 days to Glacier and delete them after 30 days.

---

### Challenge 8: Enable server-side encryption using SSE-KMS and test uploading encrypted files

To enable server-side encryption using AWS KMS and upload encrypted files, follow these steps:

#### 1. Enable SSE-KMS Encryption for Your Bucket

1. Go to the S3 console.
2. Navigate to your S3 bucket.
3. Go to the Properties tab and scroll down to Default encryption.
4. Choose **AWS-KMS** as the encryption type.
5. Select the KMS key (you can use the default `aws/s3` key or create a custom key).
6. Save the changes.

#### 2. Test Uploading Encrypted Files

To test uploading files encrypted with SSE-KMS, you can use the AWS CLI:

```bash
aws s3 cp /path/to/local/file.txt s3://your-bucket-name/path/to/file.txt --sse aws:kms --sse-kms-key-id your-kms-key-id
```

Replace `your-kms-key-id` with your specific KMS key ID.

This command uploads the file with SSE-KMS encryption.

You can verify the encryption by checking the object properties in the S3 console. The encryption type should show SSE-KMS.


                                                               
