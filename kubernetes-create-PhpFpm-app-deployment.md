# Assignment
The Nautilus Application Development team is planning to deploy one of the php-based application on Kubernetes cluster.  
As per discussion with DevOps team they have decided to use nginx and phpfpm. Additionally, they shared some custom  
configuration requirements. Below you can find more details. Please complete the task as per requirements mentioned below:

1) Create a service to expose this app, the service type must be NodePort, nodePort should be 30012.
2.) Create a config map nginx-config for nginx.conf as we want to add some custom settings for nginx.conf.
a) Change default port 80 to 8099 in nginx.conf.
b) Change default document root /usr/share/nginx to /var/www/html in nginx.conf.
c) Update directory index to index index.html index.htm index.php in nginx.conf.
3.) Create a pod named nginx-phpfpm .
b) Create a shared volume shared-files that will be used by both containers (nginx and phpfpm) also it should be a emptyDir volume.
c) Map the ConfigMap we declared above as a volume for nginx container. Name the volume as nginx-config-volume,  
  mount path should be /etc/nginx/nginx.conf and subPath should be nginx.conf
d) Nginx container should be named as nginx-container and it should use nginx:latest image. PhpFPM container  
  should be named as php-fpm-container and it should use php:7.2-fpm image.
e) The shared volume shared-files should be mounted at /var/www/html location in both containers.  
  Copy /opt/index.php from jump host to the nginx document root inside nginx container, once done you can  
  access the app using App button on the top bar.
Before clicking on finish button always make sure to check if all pods are in running state.
You can use any labels as per your choice.
Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
### Create configmap
thor@jump_host ~$ tee config.yaml<<EOF
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
     user  nginx;
     worker_processes  auto;
     
     error_log  /var/log/nginx/error.log notice;
     pid        /var/run/nginx.pid;
     
     
     events {
         worker_connections  1024;
     }
     
     
     http {
         include       /etc/nginx/mime.types;
         default_type  application/octet-stream;
     
         log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                           '$status $body_bytes_sent "$http_referer" '
                           '"$http_user_agent" "$http_x_forwarded_for"';
     
         access_log  /var/log/nginx/access.log  main;
     
         sendfile        on;
         #tcp_nopush     on;
     
         keepalive_timeout  65;
     
         #gzip  on;
     
         include /etc/nginx/conf.d/*.conf;
         server {
              listen       80;
              listen  [::]:80;
              server_name  localhost;
          
              #access_log  /var/log/nginx/host.access.log  main;
          
              location / {
                  root   /var/www/html;
                  index  index.html index.htm index.php;
              }
          
              #error_page  404              /404.html;
          
              # redirect server error pages to the static page /50x.html
              #
              error_page   500 502 503 504  /50x.html;
              location = /50x.html {
                  root   /usr/share/nginx/html;
              }
          }
     }
```
thor@jump_host ~$ `tee pod.yaml<<EOF`
```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx-phpfpm
  name: nginx-phpfpm
spec:
  volumes:
  - name: shared-files
    emptyDir: {}
  - name: nginx-config-volume
    configMap:
      name: nginx-config
  containers:
  - image: nginx:latest
    name: nginx-container
    ports:
    - containerPort: 8099
    volumeMounts:
    - name: nginx-config-volume
      mountPath: /etc/nginx/nginx.conf
      subPath: nginx.conf
    - name: shared-files
      mountPath: /var/www/html
  - image: "php:7.2-fpm"
    name: php-fpm-container
    volumeMounts:
    - name: shared-files
      mountPath: /var/www/html                                       
```
thor@jump_host ~$ `tee svc.yaml<<EOF`
```    
apiVersion: v1
kind: Service
metadata:
  labels:
    run: nginx-phpfpm
  name: nginx-phpfpm
spec:
  type: NodePort
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8099
    nodePort: 30012
  selector:
    run: nginx-phpfpm
```                                     
