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

To address the challenges you've mentioned, I'll provide solutions step by step, including the tasks in each challenge and then proceed to create a playbook for Challenge 11: "Build a Web Server Provisioning Playbook."

### Challenge 6: Create a variable file and use it in your playbook

First, create a variables file (e.g., `vars.yml`) containing any variables you want to use. Then, reference the variables in your playbook.

Example `vars.yml`:
```yaml
web_server: "nginx"
html_file_path: "/var/www/html/index.html"
```

Example playbook `web_server.yml`:
```yaml
---
- name: Install and configure web server
  hosts: localhost
  vars_files:
    - vars.yml
  tasks:
    - name: Install Nginx
      ansible.builtin.yum:
        name: "{{ web_server }}"
        state: present
```

### Challenge 7: Add a handler to restart a service only when a config file changes

Add a handler to restart the service only if the configuration file is modified.

Example:
```yaml
- name: Install Nginx
  ansible.builtin.yum:
    name: nginx
    state: present

- name: Copy custom Nginx config
  ansible.builtin.copy:
    src: /path/to/nginx.conf
    dest: /etc/nginx/nginx.conf
  notify: restart nginx

handlers:
  - name: restart nginx
    ansible.builtin.systemd:
      name: nginx
      state: restarted
```

### Challenge 8: Use ansible.builtin.user to create a new system user

To create a new user, you can use `ansible.builtin.user`.

Example:
```yaml
- name: Create a new deployment user
  ansible.builtin.user:
    name: deployer
    state: present
    shell: /bin/bash
```

### Challenge 9: Tag tasks and run only tagged tasks

You can add tags to tasks, and then run only those tagged tasks with `--tags`.

Example:
```yaml
- name: Install Nginx
  ansible.builtin.yum:
    name: nginx
    state: present
  tags:
    - install

- name: Copy HTML file
  ansible.builtin.copy:
    src: /path/to/index.html
    dest: /var/www/html/index.html
  tags:
    - install
```

You can run the playbook with `--tags` to only run tasks with the `install` tag:
```bash
ansible-playbook web_server.yml --tags install
```

### Challenge 10: Use ansible-playbook with --check mode to simulate changes

The `--check` mode simulates the playbook without making changes. You can use it to preview the actions.

Run this command to simulate changes:
```bash
ansible-playbook web_server.yml --check
```

### Challenge 11: Build a Web Server Provisioning Playbook

Now, let's build a complete playbook that:

1. Installs Nginx or Apache
2. Copies an HTML file to `/var/www/html/`
3. Ensures the service is enabled and started
4. Creates a system user for deployments
5. Sends a Slack or webhook notification (bonus)

### Full Playbook Example (`web_server.yml`)

```yaml
---
- name: Provision Web Server
  hosts: localhost
  become: true
  vars_files:
    - vars.yml

  tasks:
    - name: Install Nginx
      ansible.builtin.yum:
        name: "{{ web_server }}"
        state: present
      tags:
        - install

    - name: Copy the HTML file to /var/www/html/
      ansible.builtin.copy:
        src: /path/to/index.html
        dest: /var/www/html/index.html
      tags:
        - install

    - name: Ensure Nginx is enabled and started
      ansible.builtin.systemd:
        name: nginx
        enabled: yes
        state: started
      tags:
        - service

    - name: Create a deployment user
      ansible.builtin.user:
        name: deployer
        state: present
        shell: /bin/bash
      tags:
        - user

  handlers:
    - name: restart nginx
      ansible.builtin.systemd:
        name: nginx
        state: restarted

  # Bonus: Send Slack notification (Webhooks)
  - name: Send notification to Slack
    ansible.builtin.uri:
      url: "{{ slack_webhook_url }}"
      method: POST
      body: "{{ {'text': 'Web server provisioning complete'} | to_json }}"
      headers:
        Content-Type: "application/json"
      status_code: 200
    when: slack_webhook_url is defined
    tags:
      - notification
```

### Example `vars.yml` for Challenge 11:

```yaml
web_server: "nginx"
slack_webhook_url: "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
html_file_path: "/var/www/html/index.html"
```

### How to run the playbook:

1. Ensure your inventory file (`hosts`) points to the correct hosts (e.g., `localhost`, a VM, or EC2 instance).
2. Run the playbook with:
   ```bash
   ansible-playbook web_server.yml
   ```

### Documenting and Sharing on GitHub

To document and share the playbook on GitHub, follow these steps:

1. Create a new GitHub repository (e.g., `web-server-playbook`).
2. Push your `web_server.yml` and `vars.yml` files to the repository.
3. Add a `README.md` with details on how to use the playbook, any prerequisites, and any relevant instructions.

For example:

```markdown
# Web Server Provisioning Playbook

This Ansible playbook provisions a web server with Nginx, deploys a simple HTML page, creates a system user, and optionally sends a Slack notification upon completion.

## Requirements

- Ansible 2.9+ installed
- A valid Slack webhook URL for notifications

## How to Run

1. Clone this repository.
2. Modify `vars.yml` with your server details and Slack webhook URL.
3. Run the playbook:
   ```bash
   ansible-playbook web_server.yml
   ```

## Tasks

- Installs Nginx
- Copies an HTML file to `/var/www/html/`
- Ensures the Nginx service is enabled and started
- Creates a deployment user
- Sends a Slack notification (optional)
```

Once the repository is pushed, you can share the GitHub link with others.

Let me know if you need further clarification!
