# Assignment

There are some files that need to be created on all app servers in Stratos DC. The Nautilus DevOps team want these files to be owned by user root only however, they also want that the app specific user to have a set of permissions on these files. All tasks must be done using Ansible only, so they need to create a playbook. Below you can find more information about the task.



Create a playbook.yml under /home/thor/ansible on jump host, an inventory file is already present under /home/thor/ansible directory on Jump Server itself.

Create an empty file blog.txt under /opt/data/ directory on app server 1. Set some acl properties for this file. Using acl provide read '(r)' permissions to group tony (i.e entity is tony and etype is group).

Create an empty file story.txt under /opt/data/ directory on app server 2. Set some acl properties for this file. Using acl provide read + write '(rw)' permissions to user steve (i.e entity is steve and etype is user).

Create an empty file media.txt under /opt/data/ on app server 3. Set some acl properties for this file. Using acl provide read + write '(rw)' permissions to group banner (i.e entity is banner and etype is group).

Note: Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml so please make sure the playbook works this way, without passing any extra arguments.

# Solution

thor@jump_host ~/ansible$ `tee playbook.yml <<EOF`
```
- hosts: all
  become: yes
  gather_facts: no
  tasks:
    - block:
      - file:
          state: touch
          path: /opt/data/blog.txt
      - acl:
          path: /opt/data/blog.txt
          entity: tony
          etype: group
          permissions: r
          state: present
      when: inventory_hostname == 'stapp01'

    - block:
      - file:
          state: touch
          path: /opt/data/story.txt
      - acl:
          path: /opt/data/story.txt
          entity: steve
          etype: user
          permissions: rw
          state: present
      when: inventory_hostname == 'stapp02'

    - block:
      - file:
          state: touch
          path: /opt/data/media.txt
      - acl:
          path: /opt/data/media.txt
          entity: banner
          etype: group
          permissions: rw
          state: present
      when: inventory_hostname == 'stapp03'
EOF
```
thor@jump_host ~/ansible$ `ansible-playbook -i inventory playbook.yml`
```
PLAY [all] *******************************************************************************************************************************************

TASK [file] ******************************************************************************************************************************************
skipping: [stapp02]
skipping: [stapp03]
changed: [stapp01]

TASK [acl] *******************************************************************************************************************************************
skipping: [stapp02]
skipping: [stapp03]
changed: [stapp01]

TASK [file] ******************************************************************************************************************************************
skipping: [stapp01]
skipping: [stapp03]
changed: [stapp02]

TASK [acl] *******************************************************************************************************************************************
skipping: [stapp03]
skipping: [stapp01]
changed: [stapp02]

TASK [file] ******************************************************************************************************************************************
skipping: [stapp01]
skipping: [stapp02]
changed: [stapp03]

TASK [acl] *******************************************************************************************************************************************
skipping: [stapp02]
skipping: [stapp01]
changed: [stapp03]

PLAY RECAP *******************************************************************************************************************************************
stapp01                    : ok=2    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0   
stapp02                    : ok=2    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0   
stapp03                    : ok=2    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0   
```
