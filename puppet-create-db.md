# Assignment

The Nautilus DevOps team had a meeting with development team last week to discuss about some new requirements for an application deployment. Team is working on to setup a mariadb database server on Nautilus DB Server in Stratos Datacenter. They want to setup the same using Puppet. Below you can find more details about the requirements:

Create a puppet programming file games.pp under /etc/puppetlabs/code/environments/production/manifests directory on puppet master node i.e on Jump Server. Define a class mysql_database in puppet programming code and perform below mentioned tasks:
Install package mariadb-server (whichever version is available by default in yum repo) on puppet agent node i.e on DB Server also start its service.
Create a database kodekloud_db8 , a database userkodekloud_pop and set passwordB4zNgHA7Ya for this new user also remember host should be localhost. Finally grant some usual permissions like select, update (or full) ect to this newly created user on newly created database.
Notes: :- Please make sure to run the puppet agent test using sudo on agent nodes, otherwise you can face certificate issues. In that case you will have to clean the certificates first and then you will be able to run the puppet agent test.
:- Before clicking on the Check button please make sure to verify puppet server and puppet agent services are up and running on the respective servers, also please make sure to run puppet agent test to apply/test the changes manually first.
:- Please note that once lab is loaded, the puppet server service should start automatically on puppet master server, however it can take upto 2-3 minutes to start.

# Solution
thor@jump_host ~$ `sudo -i`
```

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for thor: 
```
root@jump_host ~# tee /etc/puppetlabs/code/environments/production/manifests/games.pp<<EOF
```
class mysql_database {
   package { 'mariadb-server':
     ensure => present
   }
  
   service {'mariadb':
     ensure => running
   }
  
   mysql::db { 'kodekloud_db8':
     user     => 'kodekloud_pop',
     password => 'B4zNgHA7Ya',
     host     => 'localhost',
     grant    => ['SELECT', 'UPDATE'],
   }
}

node stdb01.stratos.xfusioncorp.com {
  include mysql_database
}

EOF
```
root@jump_host ~# `puppet parser validate /etc/puppetlabs/code/environments/production/manifests/games.pp`  
root@jump_host ~# `ssh stdb01 -l peter`
```
The authenticity of host 'stdb01 (172.16.239.10)' can't be established.
ECDSA key fingerprint is SHA256:6DDr+bqO6sNc0fofXe4hDshC6WiabBZHJT8x/qpRMJY.
ECDSA key fingerprint is MD5:8d:b4:60:13:04:c1:18:68:5f:36:a7:6c:74:dc:5e:3a.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'stdb01,172.16.239.10' (ECDSA) to the list of known hosts.
peter@stdb01's password:
```
[peter@stdb01 ~]$ `sudo -i`
```
We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for peter: 
```
[root@stdb01 ~]# `puppet agent -tv`
  
### Reference
* https://mariadb.com/kb/en/puppet-overview-for-mariadb-users
* https://forge.puppet.com/modules/puppetlabs/mysql/readme
* https://www.puppet.com/docs/puppet/7/types/service.html
     
