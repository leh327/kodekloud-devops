# Assignment

Some new developers have joined xFusionCorp Industries and have been assigned Nautilus project. They are going to start development on a new application, and some pre-requisites have been shared with the DevOps team to proceed with. Please note that all tasks need to be performed on storage server in Stratos DC.

a. Install git, set up any values for user.email and user.name globally and create a bare repository /opt/blog.git.
b. There is an update hook (to block direct pushes to master branch) under /tmp on storage server itself; use the same to block direct pushes to master branch in /opt/blog.git repo.
c. Clone /opt/blog.git repo in /usr/src/kodekloudrepos/blog directory.
d. Create a new branch xfusioncorp_blog in repo that you cloned in /usr/src/kodekloudrepos.
e. There is a readme.md file in /tmp on storage server itself; copy that to repo, add/commit in the new branch you created, and finally push your branch to origin.
f. Also create master branch from your branch and remember you should not be able to push to master as per hook you have set up.

# Solution

[root@ststor01 ~]# `yum install git -y`  
[root@ststor01 ~]# `git config --global user.email natasha@stratos.kodekloud.com`  
[root@ststor01 ~]# `git config --global user.name natasha`  
[root@ststor01 ~]# `git init --bare /opt/blog.git`
```
Initialized empty Git repository in /opt/blog.git/
```
[root@ststor01 ~]# `cat /tmp/update`
```
#!/bin/sh
if [ "$1" == refs/heads/master ];
then
  echo "Manual pushing to this repo's master branch is restricted"
  exit 1
fi
```
[root@ststor01 ~]# `cp /tmp/update /opt/blog.git/`
```
branches/    description  hooks/       objects/     
config       HEAD         info/        refs/   
```
[root@ststor01 ~]# `cp /tmp/update /opt/blog.git/hooks/`
```
applypatch-msg.sample      pre-applypatch.sample      pre-push.sample
commit-msg.sample          pre-commit.sample          pre-rebase.sample
post-update.sample         prepare-commit-msg.sample  update.sample
```
[root@ststor01 ~]# `cp /tmp/update /opt/blog.git/hooks/`  
[root@ststor01 ~]# `git clone /opt/blog.git /usr/src/kodekloudrepos/blog`
```
Cloning into '/usr/src/kodekloudrepos/blog'...
warning: You appear to have cloned an empty repository.
done.
`
[root@ststor01 ~]# `ls /usr/src/kodekloudrepos/blog`  
[root@ststor01 ~]# ls -a /usr/src/kodekloudrepos/blog`
```
.  ..  .git
```
[root@ststor01 blog]# `git checkout -b xfusioncorp_blog``
```
Switched to a new branch 'xfusioncorp_blog'
```
[root@ststor01 blog]# `cp /tmp/readme.md .`
[root@ststor01 blog]# `git add readme.md `
[root@ststor01 blog]# `git commit -m "added readme.md"`
```
[xfusioncorp_blog (root-commit) b23dbc7] added readme.md
 1 file changed, 1 insertion(+)
 create mode 100644 readme.md
 ```
 [root@ststor01 blog]# `git push -u origin xfusioncorp_blog`
 ```
Counting objects: 3, done.
Writing objects: 100% (3/3), 247 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To /opt/blog.git
 * [new branch]      xfusioncorp_blog -> xfusioncorp_blog
Branch xfusioncorp_blog set up to track remote branch xfusioncorp_blog from origin.
```
[root@ststor01 blog]# `git checkout -b master`
```
Switched to a new branch 'master'
```
[root@ststor01 blog]# `git log`
```
commit b23dbc797cf74673d2d5e4cc83ce2d4788a7444f
Author: natasha <natasha@stratos.kodekloud.com>
Date:   Wed Nov 30 12:55:52 2022 +0000

    added readme.md
```
[root@ststor01 blog]# `git push -u origin master`
```
Total 0 (delta 0), reused 0 (delta 0)
remote: Manual pushing to this repo's master branch is restricted
remote: error: hook declined to update refs/heads/master
To /opt/blog.git
 ! [remote rejected] master -> master (hook declined)
error: failed to push some refs to '/opt/blog.git'
```
[root@ststor01 blog]# 
