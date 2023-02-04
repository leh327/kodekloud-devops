# Assignment
Some directory structure in the Stratos Datacenter needs to be changed, there is a directory that needs to be linked to the default Apache document root. We need to accomplish this task using Puppet, as per the instructions given below:



Create a puppet programming file demo.pp under /etc/puppetlabs/code/environments/production/manifests directory on puppet master node i.e on Jump Server. Within that define a class symlink and perform below mentioned tasks:

Create a symbolic link through puppet programming code. The source path should be /opt/data and destination path should be /var/www/html on Puppet agents 3 i.e on App Servers 3.

Create a blank file story.txt under /opt/data directory on puppet agent 3 nodes i.e on App Servers 3.

Notes: :- Please make sure to run the puppet agent test using sudo on agent nodes, otherwise you can face certificate issues. In that case you will have to clean the certificates first and then you will be able to run the puppet agent test.

:- Before clicking on the Check button please make sure to verify puppet server and puppet agent services are up and running on the respective servers, also please make sure to run puppet agent test to apply/test the changes manually first.

:- Please note that once lab is loaded, the puppet server service should start automatically on puppet master server, however it can take upto 2-3 minutes to start.

# Solution
root@jump_host ~# `tee /etc/puppetlabs/code/environments/production/manifests/demo.pp <<EOF`
```
node 'stapp03.stratos.xfusioncorp.com' {
  file {'/opt/data':
    ensure => link,
    target => '/var/www/html'
  }

  file {'/opt/data/story.txt':
    ensure => present
  }
}
EOF
```
[root@stapp03 ~]# `puppet agent -tv`
```
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Retrieving locales
Info: Caching catalog for stapp03.stratos.xfusioncorp.com
Info: Applying configuration version '1675543286'
Notice: /Stage[main]/Main/Node[stapp03.stratos.xfusioncorp.com]/File[/opt/data]/ensure: created
Notice: /Stage[main]/Main/Node[stapp03.stratos.xfusioncorp.com]/File[/opt/data/story.txt]/ensure: created
Notice: Applied catalog in 0.08 seconds
```
[root@stapp03 ~]# `ls /var/www/html`  
story.txt
[root@stapp03 ~]# `ls -l /opt/data`
```
lrwxrwxrwx 1 root root 13 Feb  4 20:41 /opt/data -> /var/www/html
```
[root@stapp03 ~]#
