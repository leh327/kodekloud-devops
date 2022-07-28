# Assignment
Some directory structure in the Stratos Datacenter needs to be changed, there is a directory that needs to be linked to the default Apache document root. We need to accomplish this task using Puppet, as per the instructions given below:



Create a puppet programming file ecommerce.pp under /etc/puppetlabs/code/environments/production/manifests directory on puppet master node i.e on Jump Server. Within that define a class symlink and perform below mentioned tasks:

Create a symbolic link through puppet programming code. The source path should be /opt/security and destination path should be /var/www/html on Puppet agents 3 i.e on App Servers 3.

Create a blank file story.txt under /opt/security directory on puppet agent 3 nodes i.e on App Servers 3.

Notes: :- Please make sure to run the puppet agent test using sudo on agent nodes, otherwise you can face certificate issues. In that case you will have to clean the certificates first and then you will be able to run the puppet agent test.

:- Before clicking on the Check button please make sure to verify puppet server and puppet agent services are up and running on the respective servers, also please make sure to run puppet agent test to apply/test the changes manually first.

:- Please note that once lab is loaded, the puppet server service should start automatically on puppet master server, however it can take upto 2-3 minutes to start.

# Solution

### Solution: Shell equivalent: `ln -s /var/www/html /opt/security`

root@jump_host ~# `cat > /etc/puppetlabs/code/environments/production/manifests/ecommerce.pp <<EOF`
```
class symlink {
  file {'/opt/security/story.txt':
    ensure => 'file',
    owner => 'apache',
    mode => '0755',
    require => File['/opt/security']
  }

  file {'/opt/security':
    ensure => 'link',
    target => '/var/www/html'
  }
}

node stapp03.stratos.xfusioncorp.com {
  include symlink
}
EOF
```
  
root@jump_host ~# `puppet parser validate /etc/puppetlabs/code/environments/production/manifests/ecommerce.pp`

[root@stapp03 ~]# `puppet agent -tv`
```
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Retrieving locales
Info: Caching catalog for stapp03.stratos.xfusioncorp.com
Info: Applying configuration version '1658965186'
Notice: /Stage[main]/Symlink/File[/opt/security]/ensure: created (corrective)
Notice: /Stage[main]/Symlink/File[/opt/security/story.txt]/ensure: created (corrective)
Notice: Applied catalog in 0.08 seconds
```
[root@stapp03 ~]# `ls -l /opt/security`
```
lrwxrwxrwx 1 root root 13 Jul 27 23:39 /opt/security -> /var/www/html
```

[root@stapp03 ~]# `ls -l /opt/security/`
```
total 0
-rwxr-xr-x 1 root root 0 Jul 27 23:39 story.txt
```
[root@stapp03 ~]# 
  
### Reference (not solution for this assignment). Using `require` to ensure directory created before creating file.  Shell equivalent: `ln -s /opt/security /var/www/html/security`.

root@jump_host ~# `cat > /etc/puppetlabs/code/environments/production/manifests/ecommerce.pp <<EOF`
```
class symlink {
  file {'/opt/security':
    ensure => 'directory',
    owner => 'apache',
    mode => '0755',
  }

  file {'/opt/security/story.txt':
    ensure => 'file',
    owner => 'apache',
    mode => '0755',
    require => File['/opt/security']
  }

  file {'/var/www/html/security':
    ensure => 'link',
    target => '/opt/security',
  }
}

node stapp03.stratos.xfusioncorp.com {
  include symlink
}
EOF
```
[root@stapp03 ~]# `puppet agent -tv`  
