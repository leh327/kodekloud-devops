# Assignment
The Puppet master and Puppet agent nodes have been set up by the Nautilus DevOps team to perform some testing.  
In Stratos DC all app servers have been configured as Puppet agent nodes.  
They want to setup a password less SSH connection between Puppet master and Puppet agent nodes and this  
task needs to be done using Puppet itself. Below are details about the task:

Create a Puppet programming file demo.pp under  
/etc/puppetlabs/code/environments/production/manifests directory on the Puppet master node i.e on Jump Server.  
Define a class ssh_node1 for agent node 1 i.e App Server 1,  
ssh_node2 for agent node 2 i.e App Server 2, ssh_node3 for agent node3 i.e App Server 3.  
You will need to generate a new ssh key for thor user on Jump Server, that needs to be added on all App Servers.

Configure a password less SSH connection from puppet master i.e jump host to all App Servers.  
However, please make sure the key is added to the authorized_keys file of each app's  
sudo user (i.e tony for App Server 1).

Notes: :- Before clicking on the Check button please make sure to verify puppet server and puppet  
agent services are up and running on the respective servers, also please make sure to run puppet  
agent test to apply/test the changes manually first.

:- Please note that once lab is loaded, the puppet server service should start automatically on  
puppet master server, however it can take upto 2-3 minutes to start.

# Solution
thor@jump_host ~$ `ssh-keygen`
```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/thor/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/thor/.ssh/id_rsa.
Your public key has been saved in /home/thor/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:t2rwRR9D+mrQSj1EHQA2C+LtUksSQ/e+//zlzjKonPc thor@jump_host.stratos.xfusioncorp.com
The key's randomart image is:
+---[RSA 2048]----+
|   .= o +..o..   |
|   . * + o. o    |
|    o + o. o     |
|     = o  + o    |
|    . o S=.o o   |
|     .. oo=.o    |
|       +.+.o .  .|
|        ++ooo o+ |
|       ...=+ooE++|
+----[SHA256]-----+
```
root@jump_host ~# `cat > /etc/puppetlabs/code/environments/production/manifests/demo.pp<<EOF`
```
\$thor_sshkey='$(awk '{print $2}' ~thor/.ssh/id_rsa.pub)'
class ssh_node1 {
  ssh_authorized_key { 'thor@jump-host.stratos.xfusioncorp.com':
    ensure => 'present',
    user   => 'tony',
    type   => 'ssh-rsa',
    key    => \$thor_sshkey,
  }
}
class ssh_node2 {
  ssh_authorized_key { 'thor@jump-host.stratos.xfusioncorp.com':
    ensure => 'present',
    user   => 'steve',
    type   => 'ssh-rsa',
    key    => \$thor_sshkey,
  }
}
class ssh_node3 {
  ssh_authorized_key { 'thor@jump-host.stratos.xfusioncorp.com':
    ensure => 'present',
    user   => 'banner',
    type   => 'ssh-rsa',
    key    => \$thor_sshkey,
  }
}

node stapp01.stratos.xfusioncorp.com {
  include ssh_node1
}
node stapp02.stratos.xfusioncorp.com {
  include ssh_node2
}
node stapp03.stratos.xfusioncorp.com {
  include ssh_node3
}
EOF
```
root@jump_host ~# `puppet parser validate /etc/puppetlabs/code/environments/production/manifests/demo.pp`  

thor@jump_host ~$ `for i in banner@stapp03 steve@stapp02 tony@stapp01; do ssh -t $i sudo puppet agent -tv; done`  

thor@jump_host ~$ `for i in banner@stapp03 steve@stapp02 tony@stapp01; do ssh -t $i; done`

# References:
- https://www.puppet.com/docs/puppet/7/lang_variables.html#lang_variables
- https://forge.puppet.com/modules/puppetlabs/sshkeys_core/readme
