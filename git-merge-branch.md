# Assignment
The Nautilus application development team has been working on a project repository `/opt/apps.git`.  
This repo is cloned at `/usr/src/kodekloudrepos` on storage server in Stratos DC.  
They recently shared the following requirements with DevOps team:

a. Create a new branch devops in `/usr/src/kodekloudrepos/apps` repo from master and copy  
the `/tmp/index.html` file (on storage server itself). Add/commit this file in the new branch  
and merge back that branch to the master branch. Finally, push the changes to origin for both of the branches.

# Solution
thor@jump_host ~$ `ssh natasha@ststor01`
```
The authenticity of host 'ststor01 (172.16.238.15)' can't be established.
ECDSA key fingerprint is SHA256:RGsauVYxIum8NyU6tvIvWZ7VuNZsCceoi2W2ihOSbD8.
ECDSA key fingerprint is MD5:0f:0c:96:e9:36:b2:fa:24:39:64:dc:6f:97:a2:9c:8e.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'ststor01,172.16.238.15' (ECDSA) to the list of known hosts.
natasha@ststor01's password: 
```
[natasha@ststor01 ~]$ `sudo -i`
```
We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for natasha: 
```
[root@ststor01 ~]# `cd /usr/src/kodekloudrepos/apps`

[root@ststor01 apps]# `ls`
```
info.txt  welcome.txt
```

[root@ststor01 apps]# `git log`
```
commit 8c0aa33444992da075d0123413dea2e6563c021b
Author: Admin <admin@kodekloud.com>
Date:   Thu Aug 18 19:59:04 2022 +0000

    initial commit
```
