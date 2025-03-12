🔹 Challenge 1: Create a Python script that connects to a remote server via SSH using paramiko.
import paramiko

def ssh_connect(hostname, username, password):
    try:
        # Initialize SSH client
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        # Connect to the server
        ssh.connect(hostname, username=username, password=password)
        print(f"Connected to {hostname}")

        # Run a command on the server
        stdin, stdout, stderr = ssh.exec_command('uptime')
        print(stdout.read().decode())
        
        # Close the connection
        ssh.close()
    except Exception as e:
        print(f"Connection failed: {e}")

# Example usage
ssh_connect('your-server.com', 'username', 'password')

