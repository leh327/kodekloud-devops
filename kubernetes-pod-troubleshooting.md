# Assignment
One of the junior DevOps team members was working on to deploy a stack on Kubernetes cluster. Somehow the pod is not coming up and its failing with some errors. We need to fix this as soon as possible. Please look into it.

    There is a pod named webserver and the container under it is named as httpd-container. It is using image httpd:latest

    There is a sidecar container as well named sidecar-container which is using ubuntu:latest image.

Look into the issue and fix it, make sure pod is in running state and you are able to access the app.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.


# Solution

thor@jump_host ~$ `kubectl get pod webserver -o yaml |grep latest`
```
      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"app":"web-app"},"name":"webserver","namespace":"default"},"spec":{"containers":[{"image":"httpd:latests","name":"httpd-container","volumeMounts":[{"mountPath":"/var/log/httpd","name":"shared-logs"}]},{"command":["sh","-c","while true; do cat /var/log/httpd/access.log /var/log/httpd/error.log; sleep 30; done"],"image":"ubuntu:latest","name":"sidecar-container","volumeMounts":[{"mountPath":"/var/log/httpd","name":"shared-logs"}]}],"volumes":[{"emptyDir":{},"name":"shared-logs"}]}}
  - image: httpd:latests
    image: ubuntu:latest
  - image: httpd:latests
        message: Back-off pulling image "httpd:latests"
    image: docker.io/library/ubuntu:latest
    
```

## `latests` was used instead of `latest`.  Patch pod using `latest` (use container 0)
thor@jump_host ~$ `kubectl patch pod webserver --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"httpd:latest"}]'`
```
pod/webserver patched
```
## Or using name of container
thor@jump_host ~$ `kubectl patch pod webserver -p '{"spec":{"containers":[{"name":"httpd-container","image":"httpd:latest"}]}}'`
```
pod/webserver patched
```

## Validate correct image use
thor@jump_host ~$ `kubectl get pod webserver -o yaml |grep latest`
```
{"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"app":"web-app"},"name":"webserver","namespace":"default"},"spec":{"containers":[{"image":"httpd:latests","name":"httpd-container","volumeMounts":[{"mountPath":"/var/log/httpd","name":"shared-logs"}]},{"command":["sh","-c","while true; do cat /var/log/httpd/access.log /var/log/httpd/error.log; sleep 30; done"],"image":"ubuntu:latest","name":"sidecar-container","volumeMounts":[{"mountPath":"/var/log/httpd","name":"shared-logs"}]}],"volumes":[{"emptyDir":{},"name":"shared-logs"}]}}
  - image: httpd:latest
    image: ubuntu:latest
    image: docker.io/library/httpd:latest
    image: docker.io/library/ubuntu:latest
```

## Validate service
thor@jump_host ~$ `curl $(kubectl get pod -o jsonpath='{.items[*].spec.nodeName}'):30008`
```
<html><body><h1>It works!</h1></body></html>
```
thor@jump_host ~$ 
