# Assignment
We deployed a Nginx and PHPFPM based setup on Kubernetes cluster last week and it had been working fine. This morning one of the team members made a change somewhere which caused some issues, and it stopped working. Please look into the issue and fix it:

The pod name is nginx-phpfpm and configmap name is nginx-config. Figure out the issue and fix the same.

Once issue is fixed, copy /home/thor/index.php file from jump host into nginx-container under nginx document root and you should be able to access the website using Website button on top bar.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
## checkout current config and response
### get pod definition
### get service definition
### Use curl to see the response from service
### get configmap definition
thor@jump_host ~$ `kubectl get all -o wide`
```
NAME               READY   STATUS    RESTARTS   AGE     IP           NODE                      NOMINATED NODE   READINESS GATES
pod/nginx-phpfpm   2/2     Running   0          5m10s   10.244.0.5   kodekloud-control-plane   <none>           <none>

NAME                    TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE     SELECTOR
service/kubernetes      ClusterIP   10.96.0.1     <none>        443/TCP          6h31m   <none>
service/nginx-service   NodePort    10.96.24.56   <none>        8099:30008/TCP   5m10s   app=php-app
```

thor@jump_host ~$ `curl kodekloud-control-plane:30008`
```
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.23.2</center>
</body>
</html>
```

thor@jump_host ~$ `kubectl describe pod/nginx-phpfpm |grep -i image -B3`
```
Containers:
  php-fpm-container:
    Container ID:   containerd://b4b0e9cf7f946852bcfc7ddcbbd0f6af79639c46f9a27bd7bb723902c33bbc5a
    Image:          php:7.2-fpm
    Image ID:       docker.io/library/php@sha256:9c84ae47fddb97b94d1d2e289635b7306142a5336bc4ece0a393458c5e0d2cef
--
      /var/www/html from shared-files (rw)
  nginx-container:
    Container ID:   containerd://e140507fb3091933187a05418aab051d39b041451ff387aa478bb31cd6ff96f2
    Image:          nginx:latest
    Image ID:       docker.io/library/nginx@sha256:5ffb682b98b0362b66754387e86b0cd31a5cb7123e49e7f6f6617690900d20b2
```

thor@jump_host ~$ `kubectl describe pod/nginx-phpfpm | grep -i nginx-container -A20`
```
  nginx-container:
    Container ID:   containerd://e140507fb3091933187a05418aab051d39b041451ff387aa478bb31cd6ff96f2
    Image:          nginx:latest
    Image ID:       docker.io/library/nginx@sha256:5ffb682b98b0362b66754387e86b0cd31a5cb7123e49e7f6f6617690900d20b2
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Mon, 24 Oct 2022 00:05:01 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/nginx/nginx.conf from nginx-config-volume (rw,path="nginx.conf")
      /usr/share/nginx/html from shared-files (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-krrhw (ro)
```

thor@jump_host ~$ `kubectl describe configmap nginx-config`
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
    listen 8099 default_server;
    listen [::]:8099 default_server;

    # Set nginx to serve files from the shared volume!
    root /var/www/html;
    index  index.html index.htm index.php;
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
```

## configmap for nginx indicates that it serves data at /var/www/html, but nginx-container mounted shared-files at /usr/share/nginx/html.  Change nginx-container mount path to /var/www/html, then restart pod via delete and reapply pod definition.

thor@jump_host ~$ `kubectl get pod/nginx-phpfpm -o yaml |sed 's#/usr/share/nginx/html#/var/www/html#' > nginx-phpfpm.yaml`  
thor@jump_host ~$ `kubectl delete pod/nginx-phpfpm ; kubectl apply -f nginx-phpfpm.yaml`
```
pod "nginx-phpfpm" deleted
pod/nginx-phpfpm created
```
thor@jump_host ~$ `kubectl cp /home/thor/index.php nginx-phpfpm:/var/www/html/index.php -c nginx-container`  
thor@jump_host ~$ `curl kodekloud-control-plane:30008 |grep PHP |wc -l`
```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 87947    0 87947    0     0  13.6M      0 --:--:-- --:--:-- --:--:-- 13.9M
56
```
thor@jump_host ~$
