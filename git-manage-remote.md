# Assignment
The xFusionCorp development team added updates to the project that is maintained under /opt/ecommerce.git  
repo and cloned under /usr/src/kodekloudrepos/ecommerce. Recently some changes were made on Git server  
that is hosted on Storage server in Stratos DC. The DevOps team added some new Git remotes, so we need  
to update remote on /usr/src/kodekloudrepos/ecommerce repository as per details mentioned below:



a. In /usr/src/kodekloudrepos/ecommerce repo add a new remote dev_games and point it  
to /opt/xfusioncorp_ecommerce.git repository.

b. There is a file /tmp/index.html on same server; copy this file to the repo and add/commit to master branch.

c. Finally push master branch to this new remote origin.

# Solution
thor@jump_host ~$ `ssh natasha@ststor01`
```
The authenticity of host 'ststor01 (172.16.238.15)' can't be established.
ECDSA key fingerprint is SHA256:Mw9+4pmYFP5QcuCXL2fKJax5M+878a5ZkBA36zfqY00.
ECDSA key fingerprint is MD5:d6:34:ec:4f:a2:8d:13:5d:81:a5:63:07:1b:f2:f8:8d.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'ststor01,172.16.238.15' (ECDSA) to the list of known hosts.
natasha@ststor01's password: 
```
[natasha@ststor01 ~]$ `cd /usr/src/kodekloudrepos/ecommerce/`  
[natasha@ststor01 ecommerce]$ `git status`
```
# On branch master
nothing to commit, working directory clean
```
[natasha@ststor01 ecommerce]$ `git remote -v`
```
origin  /opt/ecommerce.git (fetch)
origin  /opt/ecommerce.git (push)
```
[natasha@ststor01 ecommerce]$ `sudo git remote add dev_ecommerce /opt/xfusioncorp_ecommerce.git`
```
We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for natasha: 
```
[natasha@ststor01 ecommerce]$ `git remote -v`
```
dev_ecommerce   /opt/xfusioncorp_ecommerce.git (fetch)
dev_ecommerce   /opt/xfusioncorp_ecommerce.git (push)
origin  /opt/ecommerce.git (fetch)
origin  /opt/ecommerce.git (push)
```
[natasha@ststor01 ecommerce]$ `sudo cp /tmp/index.html .`  
[natasha@ststor01 ecommerce]$ `sudo git add index.html `  
[natasha@ststor01 ecommerce]$ `sudo git commit -m add-index`
```
[master 8635402] add-index
 1 file changed, 10 insertions(+)
 create mode 100644 index.html
 ```
[natasha@ststor01 ecommerce]$ `sudo git push dev_ecommerce master`
```
Counting objects: 3, done.
Writing objects: 100% (3/3), 242 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To /opt/xfusioncorp_ecommerce.git
 * [new branch]      master -> master
```
[natasha@ststor01 ecommerce]$ `git branch -a`
```
* master
  remotes/dev_ecommerce/master
  remotes/origin/master
```
[natasha@ststor01 ecommerce]$ 
