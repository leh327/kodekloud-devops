# Assignment

Nautilus project developers are planning to start testing on a new project. As per their meeting with the DevOps team,  
they want to test containerized environment application features. As per details shared with DevOps team, we need to accomplish the following task:

a. Pull busybox:musl image on App Server 2 in Stratos DC and re-tag (create new tag) this image as busybox:local.

# Solution

[root@stapp02 ~]# `docker image pull busybox:musl`
```
musl: Pulling from library/busybox
aebc59bbd946: Pull complete 
Digest: sha256:bc35e2207454b3e9e2d1345b0f93eb3c20eaf87da05aa13238a5a8d4ab8aa93c
Status: Downloaded newer image for busybox:musl
docker.io/library/busybox:musl
```
[root@stapp02 ~]# `docker images`
```
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
busybox      musl      886b6935b1b9   3 weeks ago   1.4MB
```
[root@stapp02 ~]# `docker tag busybox:musl busybox:local`  
[root@stapp02 ~]# `docker images`
```
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
busybox      local     886b6935b1b9   3 weeks ago   1.4MB
busybox      musl      886b6935b1b9   3 weeks ago   1.4MB
```
[root@stapp02 ~]# `docker image rm busybox:musl`
```
Untagged: busybox:musl
```
