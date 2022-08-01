# Assignment
Some of the developers from Nautilus project team have asked for SFTP access to at least one of the app server in Stratos DC.  
After going through the requirements, the system admins team has decided to configure the SFTP server on App Server 3 server  
in Stratos Datacenter. Please configure it as per the following instructions:


a. Create an SFTP user james and set its password to LQfKeWWxWD.

b. Password authentication should be enabled for this user.

c. Set its ChrootDirectory to /var/www/webapp.

d. SFTP user should only be allowed to make SFTP connections.

# Solution
### Use vi to edit /etc/ssh/sshd_config, or use ansible as follow

#### Create inventory and ansible.cfg for kodekloud-engineer servers
```
cat > inventory<<EOF
stapp01 ansible_user=tony ansible_password=Ir0nM@n ansible_sudo_pass=Ir0nM@n
stapp02 ansible_user=steve ansible_password=Am3ric@ ansible_sudo_pass=Am3ric@
stapp03 ansible_user=banner ansible_password=BigGr33n ansible_sudo_pass=BigGr33n
stmail01 ansible_user=groot ansible_password=Gr00T123 ansible_sudo_pass=Gr00T123
[test]
stapp01 ansible_user=jaems ansible_password=LQfKeWWxWD
stapp02 ansible_user=james ansible_password=LQfKeWWxWD
stapp03 ansible_user=banner ansible_password=LQfKeWWxWD
EOF

cat >ansible.cfg<<EOF
[default]
interpreter_python = /usr/bin/python3
[ssh_connection]
ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s -o strictHostkeyChecking=no
EOF
```

#### Create playbook
```
cat > configure_sftp.yml <<EOF
- name: configure sftp account
  hosts: '{{ target_host }}'
  become: yes
  gather_facts: no
  vars_prompt:
  - name: sftp_username
    private: no
    prompt: 'Enter user who will only be able to sftp to {{target_host}}'
  - name: sftp_user_pass
    prompt: 'Enter password for user sftp'
  - name: sftp_dir
    private: no
    prompt: Enter directory to send user upon login via sftp
  tasks:
  - name: 'create sftp user {{sftp_username}}'
    user:
      name: '{{ sftp_username }}'
      password: "{{ sftp_user_pass | password_hash('sha512') }}"
      state: present
  - name: 'create {{sftp_dir}} with root owner for chroot to work per manual page of sshd_config'
    file:
      path: '{{ sftp_dir }}'
      state: directory
      owner: root
      group: root
      mode: '0755'
  - name: add sftp config for user
    blockinfile:
      path: /etc/ssh/sshd_config
      block: |
        Subsystem       sftp    internal-sftp
        Match User {{sftp_username}}
        ForceCommand internal-sftp
        ChrootDirectory {{sftp_dir}}
  - name: restart ssh service
    service:
      name: sshd
      state: restarted

- hosts: test
  gather_facts: no
  tasks:
  - name: test ssh
    shell: who am i
    delegate_to: localhost
    register: ssh_test
  - debug: var=ssh_test
  
  - name: test sftp
    shell: sshpass -p {{ ansible_user_pass }} sftp -r {{ ansible_user }}@{{inventory_hostname}}/* /tmp/
    register: sftp_test
  - debug: var=sftp_test
EOF

ansible-playbook -i inventory configure_sftp.yml -e target_host=stapp03
```
