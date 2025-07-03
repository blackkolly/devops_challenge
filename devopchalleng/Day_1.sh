Setup Task: If you’re on Windows, install a Linux VM or use WSL; on Mac/Linux, open the Terminal.
🔹 Challenge 1: List all files (including hidden ones) in your home directory and sort them by 
ls -la ~ | sort -k 6,7
You can use the following command in the terminal to list all files, including hidden ones, in your home directory and sort them by modification time:
ls -la ~ | sort -k 6,7
Explanation:
•	ls -la ~ lists all files (including hidden files) in the home directory (~). 
o	-l shows detailed file information, including permissions, ownership, size, and modification time.
o	-a includes hidden files (those starting with a dot).
•	sort -k 6,7 sorts the output by the modification time (fields 6 and 7 are typically the date and time in the ls -l output).

modification time.
🔹 Challenge 2: Create a directory named devops_challenge Day 1, navigate into it, and create an empty file named day1.txt.
mkdir "devops_challenge Day 1"
cd "devops_challenge Day 1"
touch day1.txt
🔹 Challenge 3: Find the total disk usage of the /var/log directory in human-readable format.
du -sh /var/log

🔹 Challenge 4: Create a new user called devops_user and add them to the sudo group.
sudo useradd -m devops_user
sudo usermod -aG sudo devops_user

🔹 Challenge 5: Create a group called devops_team and add devops_user to that group.
sudo groupadd devops_team
sudo usermod -aG devops_team devops_user

🔹 Challenge 6: Change the permissions of day1.txt to allow only the owner to read and write, but no permissions for others.
Sudo chmod 600 day1.txt

🔹 Challenge 7: Find all files in /etc that were modified in the last 7 days.
find /etc -type f -mtime -7
•  find: Command to search for files
•  /etc: The directory to search
•  -type f: Looks for files (not directories)
•  -mtime -7: Finds files modified in the last 7 days

🔹 Challenge 8: Write a one-liner command to find the most frequently used command in the shell history
history | awk '{print $2}' | sort | uniq -c | sort -nr | head -n 1
•  history: Shows the command history
•  awk '{print $2}': Extracts the command part (ignoring the history number)
•  sort: Sorts the commands
•  uniq -c: Counts the occurrences of each command
•  sort -nr: Sorts the counts in reverse numerical order
•  head -n 1: Shows the most frequent command
