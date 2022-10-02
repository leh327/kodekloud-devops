# Assignment
The Nautilus DevOps team has started practicing some pods, and services deployment on Kubernetes platform, as they are planning to migrate most of their applications on Kubernetes. Recently one of the team members has been assigned a task to create a deploymnt as per details mentioned below:

Create a deployment named nginx to deploy the application nginx using the image nginx:latest (remember to mention the tag as well)

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
thor@jump_host ~$ `kubectl get all`
```
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   4h9m
```
thor@jump_host ~$ `kubectl create deployment nginx --image=nginx:latest`
```
deployment.apps/nginx created
```
thor@jump_host ~$ `kubectl wait --for=condition=ready pod --selector=app=nginx`
```
pod/nginx-55649fd747-ghfnp condition met
```
thor@jump_host ~$ `kubectl get all`
```
NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-55649fd747-ghfnp   1/1     Running   0          34s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   4h10m

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   1/1     1            1           35s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-55649fd747   1         1         1       34s
```
thor@jump_host ~$ 
