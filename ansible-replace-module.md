# Assignment
There is some data on all app servers in Stratos DC. The Nautilus development team shared some requirement with the DevOps team to alter some of the data as per recent changes they made. The DevOps team is working to prepare an Ansible playbook to accomplish the same. Below you can find more details about the task.



Write a playbook.yml under /home/thor/ansible on jump host, an inventory is already present under /home/thor/ansible directory on Jump host itself. Perform below given tasks using this playbook:

We have a file /opt/security/blog.txt on app server 1. Using Ansible replace module replace string xFusionCorp to Nautilus in that file.

We have a file /opt/security/story.txt on app server 2. Using Ansiblereplace module replace the string Nautilus to KodeKloud in that file.

We have a file /opt/security/media.txt on app server 3. Using Ansible replace module replace string KodeKloud to xFusionCorp Industries in that file.

Note: Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml so please make sure the playbook works this way without passing any extra arguments.

# Solution
thor@jump_host ~/ansible$ `tee playbook.yml<<EOF`
```
- hosts: all
  gather_facts: yes
  become: yes
  tasks:
    - replace:
        path: /opt/security/blog.txt
        regexp: 'xFusionCorp'
        replace: 'Nautilus'
      when: ansible_nodename == 'stapp01.stratos.xfusioncorp.com'
    - replace:
        path: /opt/security/story.txt
        replace: 'KodeKloud'
        regexp: 'Nautilus'
      when: ansible_nodename == 'stapp02.stratos.xfusioncorp.com'
    - replace:
        path: /opt/security/media.txt
        replace: 'xFusionCorp Industries'
        regexp: 'KodeKloud'
      when: ansible_nodename == 'stapp03.stratos.xfusioncorp.com'
EOF
```
thor@jump_host ~/ansible$ `ansible-playbook -i inventory playbook.yml`
```
PLAY [all] ************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************
ok: [stapp03]
ok: [stapp02]
ok: [stapp01]

TASK [replace] ********************************************************************************************************************
skipping: [stapp02]
skipping: [stapp03]
changed: [stapp01]

TASK [replace] ********************************************************************************************************************
skipping: [stapp01]
skipping: [stapp03]
changed: [stapp02]

TASK [replace] ********************************************************************************************************************
skipping: [stapp01]
skipping: [stapp02]
changed: [stapp03]

PLAY RECAP ************************************************************************************************************************
stapp01                    : ok=2    changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
stapp02                    : ok=2    changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
stapp03                    : ok=2    changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
```
