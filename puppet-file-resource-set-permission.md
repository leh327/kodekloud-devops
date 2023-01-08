# Assignment
A file named ecommerce.txt already exists under /opt/security directory on App Server 1.

Add content Welcome to xFusionCorp Industries! in ecommerce.txt file on App Server 1.

Set its permissions to 0777.

Notes: :- Please make sure to run the puppet agent test using sudo on agent nodes, otherwise  
you can face certificate issues. In that case you will have to clean the certificates first  
and then you will be able to run the puppet agent test.

:- Before clicking on the Check button please make sure to verify puppet server and puppet  
agent services are up and running on the respective servers, also please make sure to run  
puppet agent test to apply/test the changes manually first.

:- Please note that once lab is loaded, the puppet server service should start automatically  
on puppet master server, however it can take upto 2-3 minutes to start.

# Solution
### Reference: https://www.puppet.com/docs/puppet/7/types/file.html
class ecommerce {
  file { '/opt/security/ecommerce.txt':
    content => "Welcome to xFusionCorp Industries!",
    mode => '0777',
  }
}
node 'stapp01.stratos.xfusion.com' {
  include ecommerce
}
