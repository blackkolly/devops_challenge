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


