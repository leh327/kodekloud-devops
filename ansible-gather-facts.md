# Assignment
The Nautilus DevOps team is trying to setup a simple Apache web server on all app servers in Stratos DC using Ansible. 
They also want to create a sample html page for now with some app specific data on it. Below you can find more details about the task.

You will find a valid inventory file /home/thor/playbooks/inventory on jump host (which we are using as an Ansible controller).
Create a playbook index.yml under /home/thor/playbooks directory on jump host. Using blockinfile Ansible module create a file facts.txt 
under /root directory on all app servers and add the following given block in it. You will need to enable facts gathering for this task.
Ansible managed node IP is <default ipv4 address>
(You can obtain default ipv4 address from Ansible's gathered facts by using the correct Ansible variable while taking into account Jinja2 syntax)
Install httpd server on all apps. After that make a copy of facts.txt file as index.html under /var/www/html directory. 
Make sure to start httpd service after that.
Note: Do not create a separate role for this task, just add all of the changes in index.yml playbook.

# Solution

thor@jump_host ~/playbooks$ `cat > index.yml <<EOF`
```
- hosts: all
  become: yes
  gather_facts: yes
  tasks:
  - blockinfile:
      dest: /root/facts.txt
      block: "Ansible manged node IP is {{ ansible_default_ipv4.address }}"
      create: yes
      marker: ""
  - package:
      name: httpd
      state: installed
  - copy:
      src: /root/facts.txt
      dest: /var/www/html/index.html
      remote_src: yes
  - service:
      name: httpd
      state: started
EOF
```
thor@jump_host ~/playbooks$ `ansible-playbook -i inventory index.yml`
```
PLAY [all] **************************************************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************************************
ok: [stapp02]
ok: [stapp01]
ok: [stapp03]

TASK [blockinfile] ******************************************************************************************************************************************************************
changed: [stapp01]
changed: [stapp03]
changed: [stapp02]

TASK [package] **********************************************************************************************************************************************************************
changed: [stapp03]
changed: [stapp02]
changed: [stapp01]

TASK [copy] *************************************************************************************************************************************************************************
changed: [stapp01]
changed: [stapp03]
changed: [stapp02]

TASK [service] **********************************************************************************************************************************************************************
changed: [stapp03]
changed: [stapp01]
changed: [stapp02]

PLAY RECAP **************************************************************************************************************************************************************************
stapp01                    : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp02                    : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp03                    : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
thor@jump_host ~/playbooks$ `curl stapp01`
```

Ansible manged node IP is 172.16.238.10

```
thor@jump_host ~/playbooks$ `curl stapp02`
```

Ansible manged node IP is 172.16.238.11

```
thor@jump_host ~/playbooks$ `curl stapp03`
```

Ansible manged node IP is 172.16.238.12

```
thor@jump_host ~/playbooks$ 
