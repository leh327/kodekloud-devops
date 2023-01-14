# Assignment

security team has raised a concern that right now Apache’s port i.e 8086 is open for all since there is no firewall installed on these hosts. So we have decided to add some security layer for these hosts and after discussions and recommendations we have come up with the following requirements:



Install iptables and all its dependencies on each app host.

Block incoming port 8086 on all apps for everyone except for LBR host.

Make sure the rules remain, even after system reboot.

# Solution
root@jump_host ~# `yum -y install ansible`  
root@jump_host ~# `tee inventory <<EOF`
```                                      
[apps]
stapp01 ansible_user=tony ansible_password=Ir0nM@n ansible_sudo_pass=Ir0nM@n
stapp02 ansible_user=steve ansible_password=Am3ric@ ansible_sudo_pass=Am3ric@
stapp03 ansible_user=banner ansible_password=BigGr33n ansible_sudo_pass=BigGr33n
[lb]
stlb01 ansible_user=loki ansible_password=Mischi3f                                     
EOF
```
root@jump_host ~# `tee ansible.cfg <<EOF`
```
[ssh_connection]
ssh_args = -o StrictHostkeyChecking=no
EOF
```                                        
root@jump_host ~# `tee playbook.yaml <<EOF`
```
---
- hosts: apps
  become: yes
  gather_facts: no
  tasks:
  - yum:
     name:
     - iptables
     - iptables-services
  - service:
      name: iptables
      state: started
  - name: Insert a rule to accept stlb01 on line 4
    iptables:
      chain: INPUT
      protocol: tcp
      destination_port: 8086
      source: stlb01
      jump: ACCEPT
      action: insert
      rule_num: 4
  - name: Insert a rule to drop all others on line 5
    iptables:
      chain: INPUT
      protocol: tcp
      destination_port: 8086
      jump: DROP
      action: insert
      rule_num: 5
  - name: save rules
    shell: service iptables save                                         
```
root@jump_host ~# tee test.yaml <<EOF
```
---
- hosts: all
  become: no
  gather_facts: no
  tasks:
  - name: test access
    uri:
     url: "http://{{ item }}:8086"
     timeout: 2
    with_items: 
    - "{{ groups['apps'] }}"
    when: inventory_hostname in groups['apps']
    ignore_errors: yes

  - name: test access on lb host
    uri:
     url: "http://{{ item }}:8086"
     timeout: 2
    with_items:
    - "{{ groups['apps'] }}"
    when: inventory_hostname in groups['lb']                                         
```                                          
root@jump_host ~# `ansible-playbook -i inventory playbook.yaml`  
                                         
root@jump_host ~# `ansible-playbook -i inventory test.yaml `
```
PLAY [all] ***********************************************************************************

TASK [test access] ***************************************************************************
skipping: [stlb01] => (item=stapp01) 
skipping: [stlb01] => (item=stapp02) 
skipping: [stlb01] => (item=stapp03) 
ok: [stapp01] => (item=stapp01)
failed: [stapp03] (item=stapp01) => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "ansible_loop_var": "item", "changed": false, "content": "", "elapsed": 2, "item": "stapp01", "msg": "Status code was -1 and not [200]: Request failed: <urlopen error timed out>", "redirected": false, "status": -1, "url": "http://stapp01:8086"}
failed: [stapp02] (item=stapp01) => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "ansible_loop_var": "item", "changed": false, "content": "", "elapsed": 2, "item": "stapp01", "msg": "Status code was -1 and not [200]: Request failed: <urlopen error timed out>", "redirected": false, "status": -1, "url": "http://stapp01:8086"}
failed: [stapp01] (item=stapp02) => {"ansible_loop_var": "item", "changed": false, "content": "", "elapsed": 2, "item": "stapp02", "msg": "Status code was -1 and not [200]: Request failed: <urlopen error timed out>", "redirected": false, "status": -1, "url": "http://stapp02:8086"}
ok: [stapp02] => (item=stapp02)
failed: [stapp03] (item=stapp02) => {"ansible_loop_var": "item", "changed": false, "content": "", "elapsed": 2, "item": "stapp02", "msg": "Status code was -1 and not [200]: Request failed: <urlopen error timed out>", "redirected": false, "status": -1, "url": "http://stapp02:8086"}
ok: [stapp03] => (item=stapp03)
...ignoring
failed: [stapp01] (item=stapp03) => {"ansible_loop_var": "item", "changed": false, "content": "", "elapsed": 2, "item": "stapp03", "msg": "Status code was -1 and not [200]: Request failed: <urlopen error timed out>", "redirected": false, "status": -1, "url": "http://stapp03:8086"}
...ignoring
failed: [stapp02] (item=stapp03) => {"ansible_loop_var": "item", "changed": false, "content": "", "elapsed": 2, "item": "stapp03", "msg": "Status code was -1 and not [200]: Request failed: <urlopen error timed out>", "redirected": false, "status": -1, "url": "http://stapp03:8086"}
...ignoring

TASK [test access on lb host] ****************************************************************
skipping: [stapp01] => (item=stapp01) 
skipping: [stapp01] => (item=stapp02) 
skipping: [stapp01] => (item=stapp03) 
skipping: [stapp03] => (item=stapp01) 
skipping: [stapp03] => (item=stapp02) 
skipping: [stapp03] => (item=stapp03) 
skipping: [stapp02] => (item=stapp01) 
skipping: [stapp02] => (item=stapp02) 
skipping: [stapp02] => (item=stapp03) 
ok: [stlb01] => (item=stapp01)
ok: [stlb01] => (item=stapp02)
ok: [stlb01] => (item=stapp03)

PLAY RECAP ***********************************************************************************
stapp01                    : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=1   
stapp02                    : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=1   
stapp03                    : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=1   
stlb01                     : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
```
root@jump_host ~#                                          
                                         
