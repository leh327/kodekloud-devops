# Reference
* https://www.puppet.com/docs/puppet/7/metaparameter.html

# Assignment

The Nautilus DevOps team has put some data on all app servers in Stratos DC. jump host is configured as Puppet master server, and all app servers are already been configured as Puppet agent nodes. The team needs to update the content of some of the exiting files, as well as need to update their permissions etc. Please find below more details about the task:



Create a Puppet programming file cluster.pp under /etc/puppetlabs/code/environments/production/manifests directory on the master node i.e Jump Server. Using puppet file resource, perform the below mentioned tasks.

A file named news.txt already exists under /opt/itadmin directory on App Server 1.

Add content Welcome to xFusionCorp Industries! in news.txt file on App Server 1.

Set its permissions to 0777.

Notes: :- Please make sure to run the puppet agent test using sudo on agent nodes, otherwise you can face certificate issues. In that case you will have to clean the certificates first and then you will be able to run the puppet agent test.

:- Before clicking on the Check button please make sure to verify puppet server and puppet agent services are up and running on the respective servers, also please make sure to run puppet agent test to apply/test the changes manually first.

:- Please note that once lab is loaded, the puppet server service should start automatically on puppet master server, however it can take upto 2-3 minutes to start.

# Solution

root@jump_host ~# `tee /etc/puppetlabs/code/environments/production/manifests/cluster.pp <<EOF`
```
node 'stapp01.stratos.xfusioncorp.com' {
  file {'/opt/itadmin/news.txt':
    content => 'Welcome to xFusionCorp Industries!',
    mode => '0777'
  }
}
EOF
```
root@jump_host ~# `puppet parser validate /etc/puppetlabs/code/environments/production/manifests/cluster.pp`  
root@jump_host ~#
[root@stapp01 ~]# `puppet agent -tv`
```
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Retrieving locales
Info: Caching catalog for stapp01.stratos.xfusioncorp.com
Info: Applying configuration version '1675523270'
Notice: /Stage[main]/Main/Node[stapp01.stratos.xfusioncorp.com]/File[/opt/itadmin/news.txt]/content: 
--- /opt/itadmin/news.txt       2023-02-04 15:00:07.865690981 +0000
+++ /tmp/puppet-file20230204-586-4y96e  2023-02-04 15:07:51.379748183 +0000
@@ -0,0 +1 @@
+Welcome to xFusionCorp Industries!
\ No newline at end of file

Info: Computing checksum on file /opt/itadmin/news.txt
Info: /Stage[main]/Main/Node[stapp01.stratos.xfusioncorp.com]/File[/opt/itadmin/news.txt]: Filebucketed /opt/itadmin/news.txt to puppet with sum d41d8cd98f00b204e9800998ecf8427e
Notice: /Stage[main]/Main/Node[stapp01.stratos.xfusioncorp.com]/File[/opt/itadmin/news.txt]/content: content changed '{md5}d41d8cd98f00b204e9800998ecf8427e' to '{md5}b899e8a90bbb38276f6a00012e1956fe'
Notice: /Stage[main]/Main/Node[stapp01.stratos.xfusioncorp.com]/File[/opt/itadmin/news.txt]/mode: mode changed '0644' to '0777'
Notice: Applied catalog in 0.07 seconds
```
[root@stapp01 ~]# `cat /opt/itadmin/news.txt`
```
Welcome to xFusionCorp Industries!
```
[root@stapp01 ~]# `ls -l /opt/itadmin/news.txt`
```
-rwxrwxrwx 1 root root 34 Feb  4 15:07 /opt/itadmin/news.txt
```
[root@stapp01 ~]# 
