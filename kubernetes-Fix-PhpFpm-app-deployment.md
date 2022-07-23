# Fix issue with PhpFpm Application Deployed on Kubernetes
## Problem Statement
```
We deployed a Nginx and PHPFPM based application on Kubernetes cluster last week and it had been working fine.  
This morning one of the team members was troubleshooting an issue with this stack and he was supposed to run  
Nginx welcome page for now on this stack till issue with phpfpm is fixed but he made a change somewhere which  
caused some issue and the application stopped working. Please look into the issue and fix the same:  

The deployment name is nginx-phpfpm-dp and service name is nginx-service. Figure out the issues and fix them.  
FYI Nginx is configured to use default http port, node port is 30008 and copy index.php   
under /tmp/index.php to deployment under /var/www/html. Please do not try to delete/modify any other   
existing components like deployment name, service name etc.  

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.  

```
## Discovery/solution


thor@jump_host ~$ `kubectl get ns`
```
NAME                 STATUS   AGE
default              Active   5h17m
kube-node-lease      Active   5h17m
kube-public          Active   5h17m
kube-system          Active   5h17m
local-path-storage   Active   5h17m
```

thor@jump_host ~$ `kubectl get all`
```
NAME                                   READY   STATUS    RESTARTS   AGE
pod/nginx-phpfpm-dp-5cccd45499-ltcph   2/2     Running   0          59s

NAME                    TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
service/kubernetes      ClusterIP      10.96.0.1     <none>        443/TCP          5h17m
service/nginx-service   LoadBalancer   10.96.39.53   <pending>     8091:30008/TCP   59s

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-phpfpm-dp   1/1     1            1           59s

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-phpfpm-dp-5cccd45499   1         1         1       59s
```

### Discovery: Found nginx-service has issue with type - LoadBalancer is used instead of NodePort
#### Solution: update service to use NodePort type
thor@jump_host ~$ `kubectl patch svc nginx-service -p '{"spec": {"type": "NodePort"}}'`
```
service/nginx-service patched
```

thor@jump_host ~$ `kubectl describe svc nginx-service`
```
Name:                     nginx-service
Namespace:                default
Labels:                   app=nginx-fpm
Annotations:              <none>
Selector:                 app=nginx-fpm,tier=frontend
Type:                     NodePort
IP:                       10.96.39.53
Port:                     <unset>  8091/TCP
TargetPort:               8091/TCP
NodePort:                 <unset>  30008/TCP
Endpoints:                10.244.0.5:8091
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason  Age   From                Message
  ----    ------  ----  ----                -------
  Normal  Type    15m   service-controller  LoadBalancer -> NodePort
```

thor@jump_host ~$ `kubectl get pod`
```
NAME                               READY   STATUS    RESTARTS   AGE
nginx-phpfpm-dp-5cccd45499-ltcph   2/2     Running   0          14m
```  
### Test service
thor@jump_host ~$ `curl $(kubectl get pod nginx-phpfpm-dp-5cccd45499-ltcph -o jsonpath='{.spec.nodeName}'):30008`
```
curl: (7) Failed connect to kodekloud-control-plane:30008; Connection refused
```

### Troubleshoot deployment to see what port nginx application is configured to listen on  
thor@jump_host ~$ `kubectl describe deployment nginx-phpfpm-dp`
```
Name:               nginx-phpfpm-dp
Namespace:          default
CreationTimestamp:  Fri, 22 Jul 2022 23:58:13 +0000
Labels:             app=nginx-fpm
Annotations:        deployment.kubernetes.io/revision: 1
Selector:           app=nginx-fpm,tier=frontend
Replicas:           1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:       Recreate
MinReadySeconds:    0
Pod Template:
  Labels:  `app=nginx-fpm`
           `tier=frontend`
  Containers:
   nginx-container:
    Image:        nginx:latest
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:
      /etc/nginx/nginx.conf from nginx-config-volume (rw,path="nginx.conf")
      /var/www/html from shared-files (rw)
   php-fpm-container:
    Image:        php:7.3-fpm
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:
      /var/www/html from shared-files (rw)
  Volumes:
   nginx-persistent-storage:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  nginx-pv-claim
    ReadOnly:   false
   shared-files:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
   nginx-config-volume:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      nginx-config
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  nginx-phpfpm-dp-5cccd45499 (1/1 replicas created)
NewReplicaSet:   <none>
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  4m52s  deployment-controller  Scaled up replica set nginx-phpfpm-dp-5cccd45499 to 1
```
thor@jump_host ~$ `kubectl get cm`
```
NAME               DATA   AGE
kube-root-ca.crt   1      5h42m
nginx-config       1      26m
```

thor@jump_host ~$ `kubectl describe cm nginx-config`
```
Name:         nginx-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
nginx.conf:
----
events {
}
http {
  server {
    listen 80 default_server;
    listen [::]:80 default_server;

    # Set nginx to serve files from the shared volume!
    root /var/www/html;
    index  index.html index.htm;
    server_name _;
    location / {
      try_files $uri $uri/ =404;
    }
    location ~ \.php$ {
      include fastcgi_params;
      fastcgi_param REQUEST_METHOD $request_method;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_pass 127.0.0.1:9000;
    }
  }
}

Events:  <none>
```

### Discovery: nginx container is using a configmap volume which nginx listen on port 80, and service's targetport is 8091.  Also index is missing index.php
#### Solution: update service's targetPort to be 80,
thor@jump_host ~$ `kubectl patch svc nginx-service -p '{"spec": {"ports": [{"nodePort": 30008, "targetPort": 80, "port": 8091}]}}'`
```
service/nginx-service patched
```
thor@jump_host ~$ `kubectl describe svc nginx-service`
```
Name:                     nginx-service
Namespace:                default
Labels:                   app=nginx-fpm
Annotations:              <none>
Selector:                 app=nginx-fpm,tier=frontend
Type:                     NodePort
IP:                       10.96.39.53
Port:                     <unset>  8091/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  30008/TCP
Endpoints:                10.244.0.5:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason  Age   From                Message
  ----    ------  ----  ----                -------
  Normal  Type    27m   service-controller  LoadBalancer -> NodePort
```
#### Solution: Update configmap to include index.php in index line
thor@jump_host ~$ `kubectl get cm nginx-config -o yaml | sed 's/index  index.html index.htm/index  index.html index.php index.htm/' | kubectl replace -f -`
```
configmap/nginx-config replaced
```

thor@jump_host ~$ `kubectl describe cm nginx-config`
```
Name:         nginx-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
nginx.conf:
----
events {
}
http {
  server {
    listen 80 default_server;
    listen [::]:80 default_server;

    # Set nginx to serve files from the shared volume!
    root /var/www/html;
    index  index.html index.php index.htm;
    server_name _;
    location / {
      try_files $uri $uri/ =404;
    }
    location ~ \.php$ {
      include fastcgi_params;
      fastcgi_param REQUEST_METHOD $request_method;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_pass 127.0.0.1:9000;
    }
  }
}

Events:  <none>
## Solution
```
#### Restart deployment instead of waiting for it self restart, and test service
thor@jump_host ~$ `kubectl rollout restart deployment nginx-phpfpm-dp`
```
deployment.apps/nginx-phpfpm-dp restarted
```
##### Test index.php and copy /tmp/index.php into nginx-container
thor@jump_host ~$ `echo a > index.php`  
thor@jump_host ~$ `kubectl cp index.php nginx-phpfpm-dp-6b978c999b-6zr2d:/var/www/html/index.php -c nginx-container`  
thor@jump_host ~$ `curl $(kubectl get pod nginx-phpfpm-dp-6b978c999b-6zr2d -o jsonpath='{.spec.nodeName}'):30008`
```
a
```
thor@jump_host ~$ `kubectl cp /tmp/index.php nginx-phpfpm-dp-6b978c999b-6zr2d:/var/www/html/index.php -c nginx-container`

