# Assignment
While troubleshooting one of the issues on app servers in Stratos Datacenter DevOps team identified the root cause that the time isn't synchronized properly among the all app servers which causes issues sometimes. So team has decided to use a specific time server for all app servers, so that they all remain in sync. This task needs to be done using Puppet so as per details mentioned below please compete the task:



Create a puppet programming file news.pp under /etc/puppetlabs/code/environments/production/manifests directory on puppet master node i.e on Jump Server. Within the programming file define a custom class ntpconfig to install and configure ntp server on app server 3.

Add NTP Server server 2.cn.pool.ntp.org in default configuration file on app server 3, also remember to use iburst option for faster synchronization at startup.

Please note that do not try to start/restart/stop ntp service, as we already have a scheduled restart for this service tonight and we don't want these changes to be applied right now.

Notes: :- Please make sure to run the puppet agent test using sudo on agent nodes, otherwise you can face certificate issues. In that case you will have to clean the certificates first and then you will be able to run the puppet agent test.

:- Before clicking on the Check button please make sure to verify puppet server and puppet agent services are up and running on the respective servers, also please make sure to run puppet agent test to apply/test the changes manually first.

:- Please note that once lab is loaded, the puppet server service sho

# Sollution

root@jump_host ~# `tee /etc/puppetlabs/code/environments/production/manifests/news.pp <<EOF`
```
class ntpconfig {
   package {'puppetlabs-ntp':
     ensure => present
   }

  class { 'ntp':
    servers => [ 'server 2.cn.pool.ntp.org iburst' ],
  }

}
node 'stapp03.stratos.xfusioncorp.com' {
  include ntpconfig
}
EOF
```
root@jump_host ~# `puppet parser validate /etc/puppetlabs/code/environments/production/manifests/news.pp`  
root@jump_host ~# `puppet module install puppetlabs-ntp`  
root@stapp03 ~# `puppet agent -tv`  
