# Assignment

The Nautilus DevOps team is testing applications containerization, which issupposed  
to be migrated on docker container-based environments soon.  
In today's stand-up meeting one of the team members has been assigned a task to  
create and test a docker container with certain requirements. Below are more details:

a. On App Server 1 in Stratos DC pull nginx image (preferably latest tag but others should work too).
b. Create a new container with name official from the image you just pulled.
c. Map the host volume /opt/itadmin with container volume /tmp. There is an sample.txt file  
present on same server under /tmp; copy that file to /opt/itadmin. Also please keep the container in running state.

# Solution

thor@jump_host ~$ `ssh stapp01 -l tony`
```
The authenticity of host 'stapp01 (172.16.238.10)' can't be established.
ECDSA key fingerprint is SHA256:XoRPquvOBk2krY/XCBvOE1wh7YxUlNyQLNuwo6Cw3vQ.
ECDSA key fingerprint is MD5:e5:67:85:fb:43:e3:ab:04:1d:94:e0:79:c5:9c:75:58.
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
[root@stapp01 ~]# `docker image pull nginx`
```
Using default tag: latest
latest: Pulling from library/nginx
3f4ca61aafcd: Pull complete 
50c68654b16f: Pull complete 
3ed295c083ec: Pull complete 
40b838968eea: Pull complete 
88d3ab68332d: Pull complete 
5f63362a3fa3: Pull complete 
Digest: sha256:0047b729188a15da49380d9506d65959cce6d40291ccfb4e039f5dc7efd33286
Status: Downloaded newer image for nginx:latest
docker.io/library/nginx:latest
```

[root@stapp01 ~]# `docker run -d -v /opt/itadmin:/tmp --name official nginx:latest`
```
28eced272448002fc4aab72bdd292d569d24bb8caddf2a7beae58131a975e299
```

[root@stapp01 ~]# `cp /tmp/sample.txt /opt/itadmin`  
[root@stapp01 ~]# `docker exec -it official ls /tmp`
```
sample.txt
```
[root@stapp01 ~]#
