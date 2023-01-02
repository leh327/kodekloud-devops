# Assignment
The Nautilus DevOps team has started practicing some pods and services deployment on Kubernetes platform as they are  
planning to migrate most of their applications on Kubernetes platform. Recently one of the team members has been  
assigned a task to create a pod as per details mentioned below:

Create a pod named pod-nginx using nginx image with latest tag only and remember to mention the tag i.e nginx:latest.
Labels app should be set to nginx_app, also container should be named as nginx-container.
Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution

thor@jump_host ~$ `kubectl run my-pod-nginx --image=nginx:latest --labels=app=nginx_app --dry-run=client -o yaml \ `  
  `| sed '0,/name: my-pod-nginx/s/name: my-pod-nginx/name: pod-nginx/' | sed 's/name: my-pod-nginx/name: nginx-container/' \ `  
  `| kubectl apply -f - `
```
pod/pod-nginx created
```
thor@jump_host ~$
