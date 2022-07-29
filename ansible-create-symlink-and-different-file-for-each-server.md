# Assignment
The Nautilus DevOps team is practicing some of the Ansible modules and creating and testing different Ansible playbooks to accomplish tasks. 
Recently they started testing an Ansible file module to create soft links on all app servers. Below you can find more details about it.


Write a playbook.yml under /home/thor/ansible directory on jump host, an inventory file is already present under /home/thor/ansible 
directory on jump host itself. Using this playbook accomplish below given tasks:

Create an empty file /opt/itadmin/blog.txt on app server 1; its user owner and group owner should be tony. Create a symbolic 
link of source path /opt/itadmin to destination /var/www/html.

Create an empty file /opt/itadmin/story.txt on app server 2; its user owner and group owner should be steve. 
Create a symbolic link of source path /opt/itadmin to destination /var/www/html.

Create an empty file /opt/itadmin/media.txt on app server 3; its user owner and group owner should be banner. 
Create a symbolic link of source path /opt/itadmin to destination /var/www/html.

Note: Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml so please 
make sure playbook works this way without passing any extra arguments.

# Solution
### create block for each server
thor@jump_host ~$ `cd ansible`  
thor@jump_host ~/ansible$ `cat > playbook.yml <<EOF`
```
- hosts: all
  become: yes
  gather_facts: no
  tasks:
  - name: Ensure /var/www/ direcory exist on all servers
    file:
      path: /var/www/
      state: directory
  - name: create softlink of /var/www/html to use /opt/itadmin
    file:
      src: /opt/itadmin
      dest: /var/www/html
      state: link 
      
  - name: craate file on stapp01
    file:
        path: /opt/itadmin/blog.txt
        state: touch
        group: tony
        owner: tony
    when: inventory_hostname == 'stapp01'
      
  - name: create file on stapp02 
    file:
        path: /opt/itadmin/story.txt
        state: touch
        group: steve
        owner: steve
    when: inventory_hostname == 'stapp02'

  - name: Create file on stapp03
    file:
        path: /opt/itadmin/media.txt
        state: touch
        group: banner
        owner: banner
    when: inventory_hostname == 'stapp03'

```
EOF  
thor@jump_host ~/ansible$ `ansible-playbook -i inventory playbook.yml`
                                          
