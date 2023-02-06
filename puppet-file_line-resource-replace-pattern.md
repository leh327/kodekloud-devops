# Reference:
 * https://doc.wikimedia.org/puppet/puppet_types/file_line.html
# Assignment
There is some data on App Server 2 in Stratos DC. The Nautilus development team shared some requirement with the DevOps team to alter some of the data as per recent changes. The DevOps team is working to prepare a Puppet programming file to accomplish this. Below you can find more details about the task.



Create a Puppet programming file cluster.pp under /etc/puppetlabs/code/environments/production/manifests directory on Puppet master node i.e Jump Server and by using puppet file_line resource perform the following tasks.

We have a file /opt/itadmin/cluster.txt on App Server 2. Use the Puppet programming file mentioned above to replace line Welcome to Nautilus Industries! to Welcome to xFusionCorp Industries!, no other data should be altered in this file.
Notes: :- Please make sure to run the puppet agent test using sudo on agent nodes, otherwise you can face certificate issues. In that case you will have to clean the certificates first and then you will be able to run the puppet agent test.

:- Before clicking on the Check button please make sure to verify puppet server and puppet agent services are up and running on the respective servers, also please make sure to run puppet agent test to apply/test the changes manually first.

:- Please note that once lab is loaded, the puppet server service should start automatically on puppet master server, however it can take upto 2-3 minutes to start.

# Solution

root@jump_host ~# `tee /etc/puppetlabs/code/environments/production/manifests/cluster.pp <<EOF`
```
node 'stapp02.stratos.xfusioncorp.com' {
  file_line {'/opt/itadmin/cluster.txt':
    match => 'Welcome to Nautilus Industries!',
    line  => 'Welcome to xFusionCorp Industries!',
    replace => true
  }
}
EOF
```
root@jump_host ~# puppet parser validate /etc/puppetlabs/code/environments/production/manifests/cluster.pp
