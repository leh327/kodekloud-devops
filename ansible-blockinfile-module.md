# Assignment
The Nautilus DevOps team wants to install and set up a simple httpd web server on all app servers in Stratos DC.  
Additionally, they want to deploy a sample web page for now using Ansible only. Therefore, write the required  
playbook to complete this task. Find more details about the task below.

We already have an inventory file under /home/thor/ansible directory on jump host.  
Create a playbook.yml under /home/thor/ansible directory on jump host itself.

Using the playbook, install httpd web server on all app servers. Additionally, make sure its service should up and running.

Using blockinfile Ansible module add some content in /var/www/html/index.html file. Below is the content:

Welcome to XfusionCorp!

This is Nautilus sample file, created using Ansible!

Please do not modify this file manually!

The /var/www/html/index.html file's user and group owner should be apache on all app servers.

The /var/www/html/index.html file's permissions should be 0777 on all app servers.

Note:

i. Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml so please make sure the playbook works this way without passing any extra arguments.

ii. Do not use any custom or empty marker for blockinfile module.

# Solution
thor@jump_host ~/ansible$ `cat >playbook.yml<<EOF`
```
- name: install and create content for apache server
  hosts: all
  become: yes
  tasks:
  - name: install htpd
    yum:
      name: httpd
      state: installed
  - name: start httpd service
    service:
      name: httpd
      state: started
  - name: create index.html
    blockinfile:
      create: yes
      path: /var/www/html/index.html
      block: |
        Welcome to XfusionCorp!
        This is Nautilus sample file, created using Ansible!
      state: present
      owner: apache
      group: apache
      mode: `0777`
EOF
```
thor@jump_host ~/ansible$ `ansible-playbook -i inventory playbook.yml`  
thor@jump_host ~/ansible$ `ansible all -i inventory -m shell -a "ls -l /var/www/html/index.html; cat /var/www/html/index.html`
```
stapp01 | CHANGED | rc=0 >>
total 4
-rwxrwxrwx 1 apache apache 137 Sep  1 00:44 index.html
# BEGIN ANSIBLE MANAGED BLOCK
Welcome to XfusionCorp!
This is Nautilus sample file, created using Ansible!
# END ANSIBLE MANAGED BLOCK
stapp03 | CHANGED | rc=0 >>
total 4
-rwxrwxrwx 1 apache apache 137 Sep  1 00:44 index.html
# BEGIN ANSIBLE MANAGED BLOCK
Welcome to XfusionCorp!
This is Nautilus sample file, created using Ansible!
# END ANSIBLE MANAGED BLOCK
stapp02 | CHANGED | rc=0 >>
total 4
-rwxrwxrwx 1 apache apache 137 Sep  1 00:44 index.html
# BEGIN ANSIBLE MANAGED BLOCK
Welcome to XfusionCorp!
This is Nautilus sample file, created using Ansible!
# END ANSIBLE MANAGED BLOCK
```
