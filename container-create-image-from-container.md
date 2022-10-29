# Assignment
One of the Nautilus developer was working to test new changes on a container. He wants to keep a backup of his changes to the container. A new request has been raised for the DevOps team to create a new image from this container. Below are more details about it:

a. Create an image news:datacenter on Application Server 2 from a container ubuntu_latest that is running on same server.

# Solution

[root@stapp02 ~]# `docker ps`
```
CONTAINER ID   IMAGE     COMMAND   CREATED         STATUS         PORTS     NAMES
ef83de4ff870   ubuntu    "bash"    5 minutes ago   Up 4 minutes             ubuntu_latest
```
[root@stapp02 ~]#  `docker container commit ef83 news:datacenter`
```
sha256:81dfcb61367e0e1b882d801326ad882db7ff940077da354c928f0c84a509a218
```
[root@stapp02 ~]# `docker images`
```
REPOSITORY   TAG          IMAGE ID       CREATED         SIZE
news         datacenter   81dfcb61367e   4 seconds ago   117MB
ubuntu       latest       cdb68b455a14   4 days ago      77.8MB
[root@stapp02 ~]# 
```
