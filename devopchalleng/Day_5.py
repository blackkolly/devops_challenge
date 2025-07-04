Challenge 1: Create a Python program that accepts a user’s name as input and prints a greeting message.
# Prompt the user to enter their name
name = input ("Please enter your name: ")

# Print a greeting message
print (f"Hello, {name}! Welcome to the program.")
How it works:
1.	The input() function is used to take the user's name as input.
2.	The print() function is used to display the greeting message, which includes the user's name using an f-string for formatting.
🔹 Challenge 2: Write a script that reads a text file and counts the number of words in it.
def count_words_in_file(file_path):
    try:
        # Open the file in read mode
        with open(file_path, 'r') as file:
            # Read the content of the file
            content = file.read()
            
            # Split the content into words using whitespace as the delimiter
            words = content.split()
            
            # Count the number of words
            word_count = len(words)
            
            # Print the result
            print(f"The file '{file_path}' contains {word_count} words.")
    
    except FileNotFoundError:
        print(f"Error: The file '{file_path}' was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

# Example usage
file_path = 'example.txt'  # Replace with your file path
count_words_in_file(file_path)
How it works:
1.	The open() function is used to open the file in read mode.
2.	The read() method reads the entire content of the file as a string.
3.	The split() method splits the content into a list of words based on whitespace.
4.	The len() function counts the number of words in the list.
5.	The result is printed, showing the total number of words in the file.
Challenge 3: Create a Python script that generates a random password of 12 characters.
import random
import string

def generate_password(length=12):
    # Define the characters to use in the password
    all_characters = string.ascii_letters + string.digits + string.punctuation
    
    # Randomly choose characters from the list
    password = ''.join(random.choice(all_characters) for _ in range(length))
    
    return password

# Generate and print a random password
random_password = generate_password()
print("Generated password:", random_password)

How it works:
•	The string.ascii_letters provides lowercase and uppercase alphabets.
•	The string.digits includes digits from 0-9.
•	The string.punctuation includes punctuation characters (like !, @, #, etc.).
•	The random.choice() function randomly selects characters from the combined list of letters, digits, and punctuation.
•	The result is a random password of 12 characters. You can adjust the length by passing a different value to the generate_password() function.

Challenge 4: Implement a Python program that checks if a number is prime.
def is_prime(num):
    if num <= 1:
        return False  # Numbers less than or equal to 1 are not prime
    for i in range(2, int(num ** 0.5) + 1):  # Check divisibility up to the square root of the number
        if num % i == 0:  # If num is divisible by i, it's not prime
            return False
    return True  # If no divisors are found, it's prime

# Example usage:
number = int(input("Enter a number to check if it's prime: "))
if is_prime(number):
    print(f"{number} is a prime number.")
else:
    print(f"{number} is not a prime number.")

Explanation:
•	A prime number is only divisible by 1 and itself.
•	The function is_prime(num) returns False if the number is less than or equal to 1, as those are not prime.
•	For numbers greater than 1, we loop from 2 to the square root of the number (int(num ** 0.5) + 1). This is because any factor larger than the square root would have a corresponding factor smaller than the square root, so it's enough to check only up to the square root.
•	If the number is divisible by any number in the range, it is not prime. Otherwise, it is prime.
🔹 Challenge 5: Write a script that reads a list of server names from a file and pings
import os
import platform

def ping(host):
    """
    Ping a server and return True if it responds, False otherwise.
    """
    # Determine the ping command based on the operating system
    param = "-n 1" if platform.system().lower() == "windows" else "-c 1"
    
    # Build the ping command
    command = f"ping {param} {host}"
    
    # Execute the ping command
    response = os.system(command)
    
    # Return True if the ping was successful (response code 0), False otherwise
    return response == 0

def read_servers_from_file(file_path):
    """
    Read a list of server names from a file.
    """
    with open(file_path, 'r') as file:
        servers = file.read().splitlines()
    return servers

def main():
    # Path to the file containing server names
    file_path = "servers.txt"
    
    # Read the list of servers from the file
    servers = read_servers_from_file(file_path)
    
    # Ping each server and print the result
    for server in servers:
        if ping(server):
            print(f"{server} is reachable.")
        else:
            print(f"{server} is not reachable.")

if __name__ == "__main__":
    main()
Explanation:
1.	ping(host) Function:
o	This function pings a given host (server) using the ping command.
o	It adjusts the ping command based on the operating system (Windows uses -n, while Unix-based systems use -c).
o	It returns True if the server responds to the ping, otherwise False.
2.	read_servers_from_file(file_path) Function:
o	This function reads a list of server names from a file.
o	Each server name should be on a new line in the file.
3.	main() Function:
o	This is the main function that reads the server names from the file and pings each server.
o	It prints whether each server is reachable or not.
🔹 Challenge 6: Use the requests module to fetch and display data from a public API
import requests

# URL of the public API
url = "https://jsonplaceholder.typicode.com/posts"

# Send a GET request to the API
response = requests.get(url)

# Check if the request was successful (status code 200)
if response.status_code == 200:
    # Convert the response to JSON
    data = response.json()

    # Display the first 5 posts
    for post in data[:5]:  # Displaying the first 5 posts
        print(f"Title: {post['title']}")
        print(f"Body: {post['body']}\n")
else:
    print(f"Failed to fetch data. Status code: {response.status_code}")
Explanation:
•	The GET request is sent using requests.get(url).
•	If the request is successful (status code 200), the response data is converted to JSON using response.json().
•	We then display the first 5 posts' titles and bodies.
🔹 Challenge 7: Automate a simple task using Python (e.g., renaming multiple files in a directory).
import os

def rename_files_in_directory(directory_path, prefix):
    # Get a list of all files in the specified directory
    for filename in os.listdir(directory_path):
        # Construct the full file path
        old_file_path = os.path.join(directory_path, filename)

        # Check if it's a file (not a subdirectory)
        if os.path.isfile(old_file_path):
            # Create the new file name with the added prefix
            new_filename = prefix + filename
            new_file_path = os.path.join(directory_path, new_filename)

            # Rename the file
            os.rename(old_file_path, new_file_path)
            print(f'Renamed: {filename} -> {new_filename}')

# Usage
directory = '/path/to/your/directory'  # Replace with your directory path
prefix = 'new_'  # Prefix to add to the file names

rename_files_in_directory(directory, prefix)
How it works:
1.	The script uses os.listdir(directory_path) to get a list of all files in the specified directory.
2.	It checks each file using os.path.isfile() to ensure it's not a subdirectory.
3.	For each file, it adds the specified prefix to the file name and renames it using os.rename().




