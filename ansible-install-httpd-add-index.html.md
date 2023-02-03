# Assignment

The Nautilus DevOps team want to install and set up a simple httpd web server on all app servers in Stratos DC. They also want to deploy a sample web page using Ansible. Therefore, write the required playbook to complete this task as per details mentioned below.



We already have an inventory file under /home/thor/ansible directory on jump host. Write a playbook playbook.yml under /home/thor/ansible directory on jump host itself. Using the playbook perform below given tasks:

Install httpd web server on all app servers, and make sure its service is up and running.

Create a file /var/www/html/index.html with content:

This is a Nautilus sample file, created using Ansible!

Using lineinfile Ansible module add some more content in /var/www/html/index.html file. Below is the content:
Welcome to Nautilus Group!

Also make sure this new line is added at the top of the file.

The /var/www/html/index.html file's user and group owner should be apache on all app servers.

The /var/www/html/index.html file's permissions should be 0755 on all app servers.

Note: Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml so please make sure the playbook works this way without passing any extra arguments.

# Solution
thor@jump_host ~/ansible$ `tee playbook.yml <<EOF`
```
- hosts: all
  become: yes
  gather_facts: no
  tasks:
  - yum:
      name: httpd
      state: present
  - copy:
      dest: /var/www/html/index.html
      content: "This is a Nautilus sample file, created using Ansible!"
      owner: apache
      group: apache
      mode: '0755'
  - lineinfile:
      path: /var/www/html/index.html
      insertafter: BOF
      line: "Welcome to Nautilus Group!"
  - service:
      name: httpd.service
      state: started
EOF
```
thor@jump_host ~/ansible$ `ansible-playbook -i inventory playbook.yml`
```
PLAY [all] *******************************************************************************************************************************************

TASK [yum] *******************************************************************************************************************************************
ok: [stapp02]
ok: [stapp03]
ok: [stapp01]

TASK [copy] ******************************************************************************************************************************************
ok: [stapp02]
ok: [stapp03]
ok: [stapp01]

TASK [lineinfile] ************************************************************************************************************************************
changed: [stapp03]
changed: [stapp01]
changed: [stapp02]

TASK [service] ***************************************************************************************************************************************
changed: [stapp03]
changed: [stapp02]
changed: [stapp01]

PLAY RECAP *******************************************************************************************************************************************
stapp01                    : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp02                    : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp03                    : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
thor@jump_host ~/ansible$ `ansible all -i inventory -m shell -a "cat /var/www/html/index.html"`
```
stapp01 | CHANGED | rc=0 >>
Welcome to Nautilus Group!
This is a Nautilus sample file, created using Ansible!
stapp02 | CHANGED | rc=0 >>
Welcome to Nautilus Group!
This is a Nautilus sample file, created using Ansible!
stapp03 | CHANGED | rc=0 >>
Welcome to Nautilus Group!
This is a Nautilus sample file, created using Ansible!
```
thor@jump_host ~/ansible$ `ansible all -i inventory -m shell -a "ls -l /var/www/html/index.html"`
```
stapp03 | CHANGED | rc=0 >>
-rwxr-xr-x 1 apache apache 81 Feb  3 23:36 /var/www/html/index.html
stapp02 | CHANGED | rc=0 >>
-rwxr-xr-x 1 apache apache 81 Feb  3 23:36 /var/www/html/index.html
stapp01 | CHANGED | rc=0 >>
-rwxr-xr-x 1 apache apache 81 Feb  3 23:36 /var/www/html/index.html
```
thor@jump_host ~/ansible$ 
