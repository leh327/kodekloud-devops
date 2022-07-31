# Assignment
There is a critical issue going on with the Nautilus application in Stratos DC. The production support team identified that the application is unable to connect to the database. After digging into the issue, the team found that mariadb service is down on the database server.


Look into the issue and fix the same.
# Solution
Make sure to view log under/var/log/mariadb/,  
inspect /var/lib/systemd/system/mariadb.service file,  
ensure /var/lib/mysql is owned by mysql:mysql (`chown -R mysql:mysql /var/lib/mysql`), and  
check to ensure /var/run/mariadb and /var/log/mariadb directory are owned by mysql:mysql as well.  
