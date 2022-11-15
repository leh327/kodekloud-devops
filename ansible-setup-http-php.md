# Assignment

Nautilus Application development team wants to test the Apache and PHP setup on one of the app servers in Stratos Datacenter. They want the DevOps team to prepare an Ansible playbook to accomplish this task. Below you can find more details about the task.



There is an inventory file ~/playbooks/inventory on jump host.

Create a playbook ~/playbooks/httpd.yml on jump host and perform the following tasks on App Server 2.

a. Install httpd and php packages (whatever default version is available in yum repo).

b. Change default document root of Apache to /var/www/html/myroot in default Apache config /etc/httpd/conf/httpd.conf. Make sure /var/www/html/myroot path exists (if not please create the same).

c. There is a template ~/playbooks/templates/phpinfo.php.j2 on jump host. Copy this template to the Apache document root you created as phpinfo.php file and make sure user owner and the group owner for this file is apache user.

d. Start and enable httpd service.

Note: Validation will try to run the playbook using command ansible-playbook -i inventory httpd.yml, so please make sure the playbook works this way without passing any extra arguments.


# Solution

thor@jump-host ~$ `cat >playbooks/httpd.yml<<EOF`
```
- hosts: stapp02
  become: yes
  vars:
  - document_root: '/var/www/html/myroot'

  tasks:
  - name: 'a. Install httpd and php packages (whatever default version is available in yum repo).'
    yum:
      name:
      - httpd
      - php
      state: installed

  - name: 'b. Change default document root of Apache to /var/www/html/myroot in default Apache config /etc/httpd/conf/httpd.conf.'
    replace:
      path: /etc/httpd/conf/httpd.conf
      regexp: "DocumentRoot (.*)"
      replace: 'DocumentRoot "{{document_root}}"'

  - name: 'b. Make sure /var/www/html/myroot path exists (if not please create the same).'
    file:
      path: '{{ document_root }}'
      state: directory
      force: yes

  - name: 'copy template to Apache document root'
    template:
      src: phpinfo.php.j2
      dest: "{{ document_root }}/phpinfo.php"
      owner: apache
      group: apache

  - name: 'd. start and enable httpd service'
    service:
      name: httpd
      enabled: yes
      state: started                                                
EOF
```
thor@jump_host ~/playbooks$ `cat inventory`
```
stapp01 ansible_host=172.16.238.10 ansible_ssh_pass=Ir0nM@n ansible_user=tony
stapp02 ansible_host=172.16.238.11 ansible_ssh_pass=Am3ric@ ansible_user=steve
stapp03 ansible_host=172.16.238.12 ansible_ssh_pass=BigGr33n ansible_user=banner
```
                                                
thor@jump_host ~/playbooks$ `ls`
```
ansible.cfg  httpd.yml  inventory  templates
```
thor@jump_host ~/playbooks$ `cat ansible.cfg`
```
[defaults]
host_key_checking = Falset
```
hor@jump_host ~/playbooks$ `cat templates/phpinfo.php.j2` 
```
<?php
phpinfo();
?>
```
thor@jump_host ~/playbooks$
