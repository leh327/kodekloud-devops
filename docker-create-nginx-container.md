# Assignment
Nautilus DevOps team is testing some applications deployment on some of the application servers.  
They need to deploy a nginx container on Application Server 1. Please complete the task as per details given below:

    On Application Server 1 create a container named nginx_1 using image nginx with alpine tag and make  
    sure container is in running state.

# Solution
thor@jump_host ~$ `ssh tony@stapp01`
```
The authenticity of host 'stapp01 (172.16.238.10)' can't be established.
ECDSA key fingerprint is SHA256:NyneGsaRTOfCyx9dxgNP5HEqE0twPqCqcufiCFngE68.
ECDSA key fingerprint is MD5:76:ba:c2:6e:92:6a:db:12:53:4e:de:f3:d9:d4:37:3c.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'stapp01,172.16.238.10' (ECDSA) to the list of known hosts.
tony@stapp01's password: 
```

[tony@stapp01 ~]$ `sudo -i`
```
We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for tony: 
```

[root@stapp01 ~]# `docker ps`
```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

[root@stapp01 ~]# `docker run -d --name nginx_1 nginx:alpine`
```
Unable to find image 'nginx:alpine' locally
alpine: Pulling from library/nginx
530afca65e2e: Pull complete 
323a7915bc04: Pull complete 
b5b558620e40: Pull complete 
b37be0d2bf3c: Pull complete 
ba036c7f95ec: Pull complete 
a46fd6a16a7c: Pull complete 
Digest: sha256:9c2030e1ff2c3fef7440a7fb69475553e548b9685683bdbf669ac0829b889d5f
Status: Downloaded newer image for nginx:alpine
5dfedb927659e80b139f1f571568b958abf758037a623be5c33af3625367d926
```

[root@stapp01 ~]# `docker ps`
```
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS     NAMES
5dfedb927659   nginx:alpine   "/docker-entrypoint.…"   7 seconds ago   Up 3 seconds   80/tcp    nginx_1
```

[root@stapp01 ~]# `docker exec -it nginx_1 ps`
```
PID   USER     TIME  COMMAND
    1 root      0:00 nginx: master process nginx -g daemon off;
  103 nginx     0:00 nginx: worker process
  104 nginx     0:00 nginx: worker process
  105 nginx     0:00 nginx: worker process
  106 nginx     0:00 nginx: worker process
  107 nginx     0:00 nginx: worker process
  108 nginx     0:00 nginx: worker process
  109 nginx     0:00 nginx: worker process
  110 nginx     0:00 nginx: worker process
  111 nginx     0:00 nginx: worker process
  112 nginx     0:00 nginx: worker process
  113 nginx     0:00 nginx: worker process
  114 nginx     0:00 nginx: worker process
  115 nginx     0:00 nginx: worker process
  116 nginx     0:00 nginx: worker process
  117 nginx     0:00 nginx: worker process
  118 nginx     0:00 nginx: worker process
  119 nginx     0:00 nginx: worker process
  120 nginx     0:00 nginx: worker process
  121 nginx     0:00 nginx: worker process
  122 nginx     0:00 nginx: worker process
  123 nginx     0:00 nginx: worker process
  124 nginx     0:00 nginx: worker process
  125 nginx     0:00 nginx: worker process
  126 nginx     0:00 nginx: worker process
  127 nginx     0:00 nginx: worker process
  128 nginx     0:00 nginx: worker process
  129 nginx     0:00 nginx: worker process
  130 nginx     0:00 nginx: worker process
  131 nginx     0:00 nginx: worker process
  132 nginx     0:00 nginx: worker process
  133 nginx     0:00 nginx: worker process
  134 nginx     0:00 nginx: worker process
  135 nginx     0:00 nginx: worker process
  136 nginx     0:00 nginx: worker process
  137 nginx     0:00 nginx: worker process
  138 nginx     0:00 nginx: worker process
  145 root      0:00 ps
```

[root@stapp01 ~]#
