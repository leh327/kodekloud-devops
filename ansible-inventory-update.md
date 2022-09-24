# Assignment

The Nautilus DevOps team has started testing their Ansible playbooks on different servers within the stack.  
They have placed some playbooks under /home/thor/playbook/ directory on jump host which they want to test.  
Some of these playbooks have already been tested on different servers,  
but now they want to test them on app server 2 in Stratos DC. However, they first need to create an  
inventory file so that Ansible can connect to the respective app. Below are some requirements:

a. Create an ini type Ansible inventory file `/home/thor/playbook/inventory` on jump host.

b. Add App Server 2 in this inventory along with required variables that are needed to make it work.

c. The inventory hostname of the host should be the server name as per the wiki, for example `stapp01` for app server 1 in Stratos DC.

Note: Validation will try to run the playbook using command `ansible-playbook -i inventory playbook.yml` 
so please make sure the playbook works this way without passing any extra arguments.

# Solution
thor@jump_host ~/playbook$ `cat ansible.cfg`
```
[defaults]
host_key_checking = False
```
thor@jump_host ~/playbook$ `cat inventory`
```
stapp02 ansible_user=steve ansible_ssh_pass=Am3ric@ ansible_sudo_pass=Am3ric@
```
thor@jump_host ~/playbook$ `ansible-playbook -i inventory playbook.yml`
```

PLAY [all] ***************************************************************************************

TASK [Gathering Facts] ***************************************************************************
ok: [stapp02]

TASK [Install httpd package] *********************************************************************
changed: [stapp02]

TASK [Start service httpd] ***********************************************************************
changed: [stapp02]

PLAY RECAP ***************************************************************************************
stapp02                    : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
thor@jump_host ~/playbook$
