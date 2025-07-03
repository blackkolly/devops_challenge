Challenge 1: Print “Hello DevOps” with the current date and time

#!/bin/bash
echo "Hello DevOps! Today is $(date)" 
$(date) fetches the current date and time.

Challenge 2: Check if a website is reachable
#!/bin/bash
URL="https://www.learnxops.com"
if curl -Is "$URL" | head -n 1 | grep "200\|301\|302" > /dev/null; then
    echo "Success: $URL is reachable."
else
    echo "Failure: $URL is not reachable."
fi
•	Uses curl -Is to send a HEAD request and checks if the HTTP status is 200, 301, or 302.

Challenge 3: Check if a file exists and print its content
#!/bin/bash

if [ -f "$1" ]; then
    echo "File '$1' exists. Here is its content:"
    cat "$1"
else
    echo "File '$1' does not exist."
fi
•	Checks if a filename is passed as an argument ($1).
•	Uses -f to verify if the file exists before displaying its content with cat

Challenge 4: List running processes and save to a file

#!/bin/bash
ps aux > process_list.txt
echo "Process list saved to process_list.txt"
How it works:
•	Uses ps aux to list all running processes.
•	Redirects the output to process_list.txt.

Challenge 5: Install multiple packages (if not already installed)
#!/bin/bash
PACKAGES=("git" "vim" "curl")
for pkg in "${PACKAGES[@]}"; do
    if ! dpkg -l | grep -qw "$pkg"; then
        echo "Installing $pkg..."
        sudo apt-get install -y "$pkg"
    else
        echo "$pkg is already installed."
    fi
done
How it works:
•	Loops through a list of packages.
•	Uses dpkg -l | grep -qw to check if a package is installed.
•	If not installed, it installs the package using sudo apt-get install -y.

Challenge 6: Create a script that monitors CPU and memory usage every 5 seconds and logs the results to a file.

#monitor_resources.sh
#!/bin/bash

# Define the log file
LOG_FILE="resource_usage.log"

echo "Monitoring CPU and Memory usage... Logs will be saved in $LOG_FILE"
echo "Timestamp          | CPU (%) | Memory (%)" > "$LOG_FILE"

# Infinite loop to log system usage every 5 seconds
while true; do
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Get CPU usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    
    # Get Memory usage
    MEM_USAGE=$(free | awk '/Mem/ {printf "%.2f", $3/$2 * 100}')
    
    # Write data to the log file
    echo "$TIMESTAMP |  $CPU_USAGE  |  $MEM_USAGE" >> "$LOG_FILE"
    
    # Wait for 5 seconds
    sleep 5
done

Explanation:

Defines the log file (resource_usage.log).

Logs column headers (Timestamp | CPU (%) | Memory (%)).

Infinite loop (while true):

Fetches current timestamp (date command).

Fetches CPU usage using top and awk.

Fetches Memory usage using free and awk.

Appends the data to resource_usage.log.

Waits for 5 seconds before repeating.

Steps to Run the Script:
Create a script and copy the above script there:

nano monitor_resources.sh

Make it executable:

chmod +x monitor_resources.sh

Run the script in the background:

nohup ./monitor_resources.sh &

nohup → Keeps the script running even if you log out.

& → Runs it in the background.

Challenge 7: Write a script that automatically deletes log files older than 7 days from /var/log.

#clean_old_logs.sh
#!/bin/bash

# Define log directory
LOG_DIR="/var/log"

# Define file age threshold (in days)
DAYS=7

# Find and delete log files older than 7 days
find "$LOG_DIR" -type f -name "*.log" -mtime +$DAYS -exec rm -f {} \;

# Print success message
echo "✅ Deleted log files older than $DAYS days from $LOG_DIR."
Explanation:

Defines the log directory (/var/log).

Defines the threshold (DAYS=7) for old logs.

Finds and deletes old logs using find:

-type f → Selects only files.

-name "*.log" → Matches only .log files.

-mtime +7 → Files older than 7 days.

-exec rm -f {} \; → Deletes the found files.

Steps to run:

create file:

nano clean_old_logs.sh

Make it executable:

chmod +x clean_old_logs.sh

Run the script:

sudo ./clean_old_logs.sh

Challenge 8: Automate user account creation – Write a script that takes the username as an argument, checks, 
if the user exists, gives the message “user already exists“ else creates a new user, adds it to a “devops“ group, 
and sets up a default home directory

#create_user.sh
#!/bin/bash

# Check if a username is provided
if [ $# -eq 0 ]; then
    echo "❌ Error: No username provided."
    echo "Usage: sudo ./create_user.sh <username>"
    exit 1
fi

USERNAME="$1"
GROUP="devops"

# Check if user already exists
if id "$USERNAME" &>/dev/null; then
    echo "✅ User '$USERNAME' already exists."
else
    # Create the group if it doesn't exist
    if ! getent group "$GROUP" > /dev/null; then
        echo "⏳ Creating group '$GROUP'..."
        sudo groupadd "$GROUP"
    fi

    # Create user with home directory and add to group
    echo "⏳ Creating user '$USERNAME'..."
    sudo useradd -m -s /bin/bash -G "$GROUP" "$USERNAME"

    # Set a default password (optional, force change on first login)
    echo "$USERNAME:ChangeMe123" | sudo chpasswd
    sudo passwd --expire "$USERNAME"

    echo "✅ User '$USERNAME' created successfully and added to group '$GROUP'."
    echo "ℹ️ Default password: ChangeMe123 (User must change it on first login)"
fi

Explanation:

Checks if a username is provided ($# -eq 0).

Stores username and group (devops).

Checks if the user already exists using id "$USERNAME" &>/dev/null.

If yes, prints "User already exists".

Creates the devops group if it doesn't exist.

Creates the user with:

-m → Creates a home directory.

-s /bin/bash → Sets Bash as the default shell.

-G devops → Adds the user to the devops group.

Sets a default password (ChangeMe123) and forces a password change on first login.

Steps to run the script:

Create the script file & copy the above code there:

nano create_user.sh

Make it executable:

chmod +x create_user.sh

Run the script with a username:

sudo ./create_user.sh devops_user


Challenge 9: Use awk or sed in a script to process a log file 
and extract only error messages.

#extract_errors.sh
#!/bin/bash

# Define log file path
LOG_FILE="/var/log/syslog"  # Change this to your log file
OUTPUT_FILE="error_messages.log"

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "❌ Error: Log file '$LOG_FILE' not found!"
    exit 1
fi

# Extract error messages using awk
awk '/error|ERROR|Error/ {print}' "$LOG_FILE" > "$OUTPUT_FILE"

# Alternatively, use sed:
# sed -n '/error\|ERROR\|Error/p' "$LOG_FILE" > "$OUTPUT_FILE"

echo "✅ Extracted error messages saved to '$OUTPUT_FILE'."

Explanation:

Defines the log file (LOG_FILE) and output file (OUTPUT_FILE).

Checks if the log file exists before processing.

Extracts error messages & saves extracted errors to error_messages.log:

awk '/error|ERROR|Error/ {print}' "$LOG_FILE" → Searches for "error" in any case and prints matching lines.

Alternative using sed:

sed -n '/error\|ERROR\|Error/p' "$LOG_FILE" > "$OUTPUT_FILE"

To run the script:

Create the script file & copy-paste the script above and save it.:

nano extract_errors.sh

Make it executable:

chmod +x extract_errors.sh

Run the script:

./extract_errors.sh

Challenge 10: Set up a cron job that runs a script to back up (zip/tar) a directory daily.

Answer:
#backup.sh
#!/bin/bash

# Define backup directory and destination
SOURCE_DIR="/path/to/directory"  # Change this to the directory you want to back up
BACKUP_DIR="/path/to/backup"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create the backup archive
tar -czf "$BACKUP_FILE" "$SOURCE_DIR"

# Print success message
echo "✅ Backup created: $BACKUP_FILE"

Steps:

Create the “backup.sh“ file and copy the above code there:

nano backup.sh

Make the Script Executable:

chmod +x backup.sh

Schedule a Daily Cron Job:

Open the cron editor:

crontab -e

Add the following line to run the script daily at 2 AM:

0 2 * * * /path/to/backup.sh >> /var/log/backup.log 2>&1

Verify the Cron Job:

crontab -l

💡 Bonus Challenge: Customize your Bash prompt to display the current user and working directory. 
(Hint: export PS1="\u@\h:\w\$ "), try to make it permanent, so terminal closing and opening don’t default!

echo 'export PS1="\u@\h:\w\$ "' >> ~/.bashrc
source ~/.bashrc
Explanation:

\u → Displays the current user.

\h → Displays the hostname.

\w → Displays the current working directory.

\$ → Displays $ for normal users and # for root.

To persist the prompt customization, add the line to ~/.bashrc 

Since you read till the end, here’s extra bonus: to make the prompt colorful, try:

echo 'export PS1="\[\e[1;32m\]\u@\h:\w\$ \[\e[0m\]"' >> ~/.bashrc
source ~/.bashrc




