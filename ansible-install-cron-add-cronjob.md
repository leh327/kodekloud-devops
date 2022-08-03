# Assignment

The Nautilus system admins team has prepared scripts to automate several day-to-day tasks. They want them to be deployed on  
all app servers in Stratos DC on a set schedule. Before that they need to test similar functionality with a sample cron job.  
Therefore, perform the steps below:


a. Install cronie package on all Nautilus app servers and start crond service.

b. Add a cron */5 * * * * echo hello > /tmp/cron_text for root user.

# Solution


thor@jump_host ~$ `cat>ansible.cfg<<EOF`
```
[ssh_connection]                                                                                                                                            
ssh_args = -o StrictHostkeyChecking=no                                                                                                                      
                                                                                                                                                             
[defaults]                                                                                                                                                  
fact_caching = yaml                                                                                                                                         
fact_caching_connection = .ansible_facts                                                                                                                    
gathering = smart                                                                                                                                           
[inventory]                                                                                                                                                 
cache=true                                                                                                                                                  
EOF
```
thor@jump_host ~$ `cat >inventory <<EOF`
```
stapp01 ansible_user=tony ansible_ssh_pass=Ir0nM@n ansible_sudo_pass=Ir0nM@n                                                                                
stapp02 ansible_user=steve ansible_ssh_pass=Am3ric@ ansible_sudo_pass=Am3ric@                                                                               
stapp03 ansible_user=banner ansible_ssh_pass=BigGr33n ansible_sudo_pass=BigGr33n                                                                            
EOF                                   
```

[thor@jump_host ~]$ `cat >cron.yml<<EOF `
```
---                                                                                                                                                           
 - hosts: all
   tasks:
     - name: Install cronie
       yum: name=cronie state=installed update_cache=true
                                                                                                                                                              
     - name: Cron job
       cron:
        user: "root"
        minute: "*/5"
        job: "echo hello > /tmp/cron_text"
                                                                                                                                                              
     - name: start cron
       service: name=crond state=started enabled=yes
EOF
```
ansible-playbook -i inventory cron.yml  



[thor@jump_host ~]$ `ansible all -i inventory -m shell -a "crontab -l" --become`
```
stapp01 | CHANGED | rc=0 >>
#Ansible: None
*/5 * * * * echo hello > /tmp/cron_text

stapp01 | CHANGED | rc=0 >>
#Ansible: None
*/5 * * * * echo hello > /tmp/cron_text

stapp03 | CHANGED | rc=0 >>
#Ansible: None
*/5 * * * * echo hello > /tmp/cron_text
```
