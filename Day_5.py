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
