# Assignment

The Nautilus DevOps team is planning to test several Ansible playbooks on different app servers in Stratos DC. Before that, some pre-requisites must be met. Essentially, the team needs to set up a password-less SSH connection between Ansible controller and Ansible managed nodes. One of the tickets is assigned to you; please complete the task as per details mentioned below:



a. Jump host is our Ansible controller, and we are going to run Ansible playbooks through thor user on jump host.

b.Make appropriate changes on jump host so that user thor on jump host can SSH into App Server 2 through its respective sudo user. (for example tony for app server 1).

c. There is an inventory file /home/thor/ansible/inventory on jump host. Using that inventory file test Ansible ping from jump host to App Server 2, make sure ping works.

# Solution

Add StrictHostkeyChecking=no to ssh_connection's ssh_args.
Generate ssh public keypairs and distribute public key to all hosts via ssh-copy-id


## playbook to create and distribute public key
```
- name: generate key
  hosts: localhost
  gather_facts: no
  pre_tasks:
  - name: update /etc/ansible/ansible.cfg to not check hostkey
    replace:
      regexp: "# ssh_args = *"
      replace: "ssh_args = -o StrictHostkeyChecking=no"
      path /etc/ansible/ansible.cfg
  - name: create sshkey
    openssh_keypair:
      path: /home/thor/.ssh/id_rsa
      force: true
      type: rsa
      
- name: distribute key
  hosts: apps
  gather_facts: no
  pre_tasks:
  tasks:
  - name: distribute key
    authorized_key:
      user: "{{ansible_user}}"
      key: "{{ lookup('file', '/home/thor/.ssh/id_rsa.pub') }}"
      state: present
    register: cpinfo
 
  - debug: var=cpinfo
  ```
  ansible-playbook -i inventory playbook.yaml --ask-sudo-pass
  
