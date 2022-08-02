# Assignment
The Nautilus application development team has shared that they are planning to deploy one newly developed application on Nautilus infra in Stratos DC. The application uses PostgreSQL database, so as a pre-requisite we need to set up PostgreSQL database server as per requirements shared below:


a. Install and configure PostgreSQL database on Nautilus database server.

b. Create a database user kodekloud_joy and set its password to 8FmzjvFU6S.

c. Create a database kodekloud_db3 and grant full permissions to user kodekloud_joy on this database.

d. Make appropriate settings to allow all local clients (local socket connections) to connect to the kodekloud_db3 database through kodekloud_joy user using md5 method (Please do not try to encrypt password with md5sum).

e. At the end its good to test the db connection using these new credentials from root user or server's sudo user.

# Solution

#### Test session should look like the following:  
[root@stdb01 ~]# `psql -Ukodekloud_joy  -h localhost -d kodekloud_db3`
````
Password for user kodekloud_joy: 
psql (9.2.24)
Type "help" for help.
kodekloud_db3=> \q
````

### Shell script to create ansible playbook  
```
#!/bin/bash
yum install ansible -y
cat >hosts.txt<<EOF
stdb01 ansible_user=peter ansible_password=Sp!dy ansible_sudo_pass=Sp!dy
EOF
cat >ansible.cfg<<EOF
[default]
interpreter_python = /usr/bin/python3
[ssh_connection]
ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s -o strictHostkeyChecking=no
EOF
echo Enter database user
read db_user
echo Enter datbase user password
read db_user_pass
echo Enter database name
read db_name
cat>postgresql.yml<<EOF
---
- hosts: stdb01
  become: yes
  tasks:
  - name: install postgresql
    yum:
      name: postgresql-server
  - name: install postgresql module prereq
    pip:
      name: psycopg2-binary==2.8.6
  - name: check if pg_hba.conf exist to indicate if db initialized
    stat:
      path: /var/lib/pgsql/data/pg_hba.conf
    register: db_initialized
  - name: initialize postgresql
    shell: postgresql-setup initdb
    when: not db_initialized.stat.exists
  - name: start postgresql service
    service:
      name: postgresql
      state: started
      enabled: yes
  - name: create db {{ db_name }}
    postgresql_db:
      name: '{{ db_name }}'
    become_user: postgres
  - name: create db_user {{ db_user }}
    postgresql_user:
      name: '{{ db_user }}'
      db: '{{ db_name }}'
      password: '{{ db_user_pass }}'
      priv: 'ALL'
      state: present
    become_user: postgres
  - name: update pg_hba.conf to set host to use md5
    postgresql_pg_hba:
      dest: /var/lib/pgsql/data/pg_hba.conf
      contype: host
      databases: all
      method: md5
      users: all
      create: true
  - name: update pg_hba.conf to set local md5
    postgresql_pg_hba:
      dest: /var/lib/pgsql/data/pg_hba.conf
      contype: local
      databases: all
      method: md5
      users: all
      create: true
  - name: restart postgresql service
    service:
      name: postgresql
      state: restarted
EOF
ansible-playbook -i hosts.txt postgresql.yml -e db_user=$db_user -e db_user_pass=$db_user_pass -e db_name=$db_name
```
