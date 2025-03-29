🔥 Challenges
🔹 Challenge 1: Create an inventory file with one host (localhost or a VM)
🔹 Challenge 2: Run ansible all -m ping and verify connectivity
🔹 Challenge 3: Use the copy module to transfer a file to the target node
🔹 Challenge 4: Use package module to install Nginx or Apache
🔹 Challenge 5: Write a playbook to:

Update the package cache

Install Nginx

Ensure it is running

🔹 Challenge 6: Create a variable file and use it in your playbook (vars: or vars_files:)
🔹 Challenge 7: Add a handler to restart a service only when a config file changes
🔹 Challenge 8: Use ansible.builtin.user to create a new system user
🔹 Challenge 9: Tag tasks (tags: install) and run only tagged tasks
🔹 Challenge 10: Use ansible-playbook with --check mode to simulate changes

Challange 11: Build a Web Server Provisioning Playbook
📌 Create a complete playbook that:

Installs Nginx or Apache

Copies an HTML file to /var/www/html/

Ensures the service is enabled and started

Creates a system user for deployments

Sends a Slack or webhook notification (bonus)

📌 Run it on your localhost, VM, or AWS EC2 instance
📌 Document and share on GitHub



### Challenge 1: Create an inventory file with one host (localhost or a VM)

Create a file called `inventory.ini` to define the host:

```ini
[webservers]
localhost ansible_connection=local
```

This file defines a host called `localhost` and specifies that Ansible should use a local connection for this host.

---

### Challenge 2: Run `ansible all -m ping` and verify connectivity

To test the connection to your hosts, run the following command:

```bash
ansible all -m ping -i inventory.ini
```

- This will send a ping module to all hosts defined in the `inventory.ini` file.
- If successful, you should see an output like this:

```
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

### Challenge 3: Use the `copy` module to transfer a file to the target node

You can use the `copy` module to transfer a file from your local machine to the target node. For example, if you want to transfer a file called `example.txt` to `/tmp` on the target:

```bash
ansible all -m copy -a "src=example.txt dest=/tmp/example.txt" -i inventory.ini
```

This command will copy the `example.txt` file from your local machine to the `/tmp` directory on the `localhost` (or the VM).

---

### Challenge 4: Use the `package` module to install Nginx or Apache

You can use the `package` module to install Nginx (or Apache) on the target host. Here's an example of how to install Nginx:

```bash
ansible all -m package -a "name=nginx state=present" -i inventory.ini
```

- This will install the `nginx` package on the target node (in this case, `localhost`).
- You can replace `nginx` with `apache2` if you'd like to install Apache instead.

---

### Challenge 5: Write a playbook to:

- Update the package cache
- Install Nginx
- Ensure it is running

Create a playbook called `setup_nginx.yml`:

```yaml
---
- name: Setup Nginx
  hosts: all
  become: true  # Run as root
  tasks:
    - name: Update the package cache
      apt:
        update_cache: yes
      when: ansible_os_family == "Debian"  # Ensure it runs only on Debian-based systems (e.g., Ubuntu)

    - name: Install Nginx
      apt:
        name: nginx
        state: present
      when: ansible_os_family == "Debian"

    - name: Ensure Nginx is running
      service:
        name: nginx
        state: started
        enabled: yes
```

You can run this playbook using:

```bash
ansible-playbook -i inventory.ini setup_nginx.yml
```

### Explanation:

1. **Update the package cache**: This task updates the package cache on Debian-based systems using the `apt` module.
2. **Install Nginx**: Installs the Nginx package on the target host if it’s not already installed.
3. **Ensure Nginx is running**: Ensures that Nginx is started and enabled to start on boot.

---

### Additional Notes:

- For a Red Hat-based system (e.g., CentOS or RHEL), replace the `apt` module with the `yum` module.
  
---

This should complete all the challenges you've outlined. Let me know if you need further clarification!
