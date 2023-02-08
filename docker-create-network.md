# Assignment
The Nautilus DevOps team needs to set up several docker environments for different applications. One of the team members has been assigned a ticket where he has been asked to create some docker networks to be used later. Complete the task based on the following ticket description:



a. Create a docker network named as blog on App Server 3 in Stratos DC.

b. Configure it to use bridge drivers.

c. Set it to use subnet 172.168.0.0/24 and iprange 172.168.0.3/24.

# solution
[root@stapp03 ~]# `docker network create --ip-range 172.168.0.3/24 --subnet 172.168.0.0/24 blog`
```
d59cea7b3bdc125e9f8d77d9f7f9d8928ccb011758d12c96b972f606f057b888
```
[root@stapp03 ~]# `docker network inspect d59`
```
[
    {
        "Name": "blog",
        "Id": "d59cea7b3bdc125e9f8d77d9f7f9d8928ccb011758d12c96b972f606f057b888",
        "Created": "2023-02-08T02:33:03.038466613Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.168.0.0/24",
                    "IPRange": "172.168.0.3/24"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```
[root@stapp03 ~]#
