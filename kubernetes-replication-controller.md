# Assignment

The Nautilus DevOps team wants to create a ReplicationController to deploy several pods.  
They are going to deploy applications on these pods, these applications need highly  
available infrastructure. Below you can find exact details, create the ReplicationController accordingly.

Create a ReplicationController using nginx image, preferably with latest tag, and name it as  
nginx-replicationcontroller.
Labels app should be nginx_app, and labels type should be front-end. The container should be  
named as nginx-container and also make sure replica counts are 3.
All pods should be running state after deployment.
Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
thor@jump_host ~$ `tee rep.yaml<<EOF`
```
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-replicationcontroller
  labels:
    app: nginx_app
    type: front-end
spec:
  replicas: 3
  selector:
       app: nginx_app
  template:
    metadata:
      labels:
        app: nginx_app
    spec:
      containers:
      - name: nginx-container
        image: nginx:latest
```
thor@jump_host ~$ `kubectl apply -f rep.yaml`
thor@jump_host ~$ `kubectl get all`
```
NAME                                    READY   STATUS    RESTARTS   AGE
pod/nginx-replicationcontroller-nxsm7   1/1     Running   0          20s
pod/nginx-replicationcontroller-tnwvt   1/1     Running   0          20s
pod/nginx-replicationcontroller-xmkl7   1/1     Running   0          20s

NAME                                                DESIRED   CURRENT   READY   AGE
replicationcontroller/nginx-replicationcontroller   3         3         3       20s
```
