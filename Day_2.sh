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


