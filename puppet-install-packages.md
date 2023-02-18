# Assignment

Some new changes need to be made on some of the app servers in Stratos Datacenter. There are some packages that need to be installed on the app server 2. We want to install these packages using puppet only.



Puppet master is already installed on Jump Server.

Create a puppet programming file news.pp under /etc/puppetlabs/code/environments/production/manifests on master node i.e on Jump Server and perform below mentioned tasks using the same.

Define a class multi_package_node for agent node 2 i.e app server 2. Install vim-enhanced and zip packages on the agent node 2.

Notes: :- Please make sure to run the puppet agent test using sudo on agent nodes, otherwise you can face certificate issues. In that case you will have to clean the certificates first and then you will be able to run the puppet agent test.

:- Before clicking on the Check button please make sure to verify puppet server and puppet agent services are up and running on the respective servers, also please make sure to run puppet agent test to apply/test the changes manually first.

:- Please note that once lab is loaded, the puppet server service should start automatically on puppet master server, however it can take upto 2-3 minutes to start.
# Solution

root@jump_host ~# `tee /etc/puppetlabs/code/environments/production/manifests/news.pp`
```
class multi_package_node {
  package {'zip':
    ensure => 'installed'
  }
 
  package {'vim-enhanced':
    ensure => 'installed'
  }
}

node 'stapp02.stratos.xfusioncorp.com' {
  include multi_package_node
}
```

[root@stapp02 ~]# `puppet agent -tv`
```
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Retrieving locales
Info: Caching catalog for stapp02.stratos.xfusioncorp.com
Info: Applying configuration version '1676733684'
Notice: /Stage[main]/Multi_package_node/Package[zip]/ensure: created
Notice: /Stage[main]/Multi_package_node/Package[vim-enhanced]/ensure: created
Notice: Applied catalog in 22.54 seconds
```
[root@stapp02 ~]# `yum list installed vim-enhanced zip`
```
Loaded plugins: fastestmirror, ovl
Loading mirror speeds from cached hostfile
 * base: mirrors.xmission.com
 * epel: mirror.genesisadaptive.com
 * extras: mirror.us-midwest-1.nexcess.net
 * updates: mirror.dal.nexril.net
Installed Packages
vim-enhanced.x86_64                                      2:7.4.629-8.el7_9                                      @updates
zip.x86_64                                               3.0-11.el7                                             @base   
```
[root@stapp02 ~]#
