# Assignment

The Nautilus Application development team has finished development of one of the applications and it is ready for deployment. It is a guestbook application that will be used to manage entries for guests/visitors. As per discussion with the DevOps team, they have finalized the infrastructure that will be deployed on Kubernetes cluster. Below you can find more details about it.



BACK-END TIER

Create a deployment named redis-master for Redis master.

a.) Replicas count should be 1.

b.) Container name should be master-redis-xfusion and it should use image redis.

c.) Request resources as CPU should be 100m and Memory should be 100Mi.

d.) Container port should be redis default port i.e 6379.

Create a service named redis-master for Redis master. Port and targetPort should be Redis default port i.e 6379.

Create another deployment named redis-slave for Redis slave.

a.) Replicas count should be 2.

b.) Container name should be slave-redis-xfusion and it should use gcr.io/google_samples/gb-redisslave:v3 image.

c.) Requests resources as CPU should be 100m and Memory should be 100Mi.

d.) Define an environment variable named GET_HOSTS_FROM and its value should be dns.

e.) Container port should be Redis default port i.e 6379.

Create another service named redis-slave. It should use Redis default port i.e 6379.

FRONT END TIER

Create a deployment named frontend.

a.) Replicas count should be 3.

b.) Container name should be php-redis-xfusion and it should use gcr.io/google-samples/gb-frontend:v4 image.

c.) Request resources as CPU should be 100m and Memory should be 100Mi.

d.) Define an environment variable named as GET_HOSTS_FROM and its value should be dns.

e.) Container port should be 80.

Create a service named frontend. Its type should be NodePort, port should be 80 and its nodePort should be 30009.

Finally, you can check the guestbook app by clicking on + button in the top left corner and Select port to view on Host 1 then enter your nodePort.

You can use any labels as per your choice.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
thor@jump_host ~$ `kubectl create deployment redis-master --replicas=1 --image=redis --dry-run=client -o yaml > redis-master.yaml`  
thor@jump_host ~$ `kubectl create deployment redis-slave --replicas=1 --image=gcr.io/google_samples/gb-redisslave:v3 --dry-run=client -o yaml > redis-slave.yaml`  
thor@jump_host ~$ `kubectl create deployment frontend --image=gcr.io/google-samples/gb-frontend:v4 -o yaml --dry-run=client > frontend.yaml`  
thor@jump_host ~$ `ls`  
```
frontend.yaml  redis-master.yaml  redis-slave.yaml
```
thor@jump_host ~$ `vi *.yaml`  
3 files to edit
thor@jump_host ~$ `kubectl apply -f .`
```
deployment.apps/frontend created
deployment.apps/redis-master created
deployment.apps/redis-slave created
```
thor@jump_host ~$ `kubectl get pod`
```
NAME                            READY   STATUS              RESTARTS   AGE
frontend-768858b896-dnz4v       0/1     ContainerCreating   0          24s
frontend-768858b896-vdpcv       0/1     ContainerCreating   0          24s
frontend-768858b896-wnkks       0/1     ContainerCreating   0          24s
redis-master-5578f8cc95-9jtcl   0/1     ContainerCreating   0          24s
redis-slave-dcb89478d-hc9xc     0/1     ContainerCreating   0          24s
redis-slave-dcb89478d-nkfdv     0/1     ContainerCreating   0          23s
```
thor@jump_host ~$ `kubectl expose deployment.apps/redis-master`
```
service/redis-master exposed
```
thor@jump_host ~$ `kubectl expose deployment.apps/redis-slave`
service/redis-slave exposed
thor@jump_host ~$ `kubectl expose deployment.apps/frontend --dry-run=client -o yaml > frontend-svc.yaml`
thor@jump_host ~$ `vi frontend-svc.yaml`
thor@jump_host ~$ `kubectl apply -f frontend-svc.yaml`
```
service/frontend created
```
thor@jump_host ~$ `cat redis-master.yaml `
```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: redis-master
  name: redis-master
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis-master
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: redis-master
    spec:
      containers:
      - image: redis
        name: master-redis-xfusion
        ports:
        - containerPort: 6379
        env:
        - name: GET_HOSTS_FROM
          value: dns
        resources: 
          requests:
            cpu: 100m
            memory: 100Mi
```
thor@jump_host ~$ `cat redis-slave.yaml `
```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: redis-slave
  name: redis-slave
spec:
  replicas: 2
  selector:
    matchLabels:
      app: redis-slave
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: redis-slave
    spec:
      containers:
      - image: gcr.io/google_samples/gb-redisslave:v3
        name: slave-redis-xfusion
        ports:
        - containerPort: 6379
        env:
        - name: GET_HOSTS_FROM
          value: dns
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
```
thor@jump_host ~$ cat frontend.yaml 
```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: frontend
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: frontend
    spec:
      containers:
      - image: gcr.io/google-samples/gb-frontend:v4
        name: php-redis-xfusion
        ports:
        - containerPort: 80
        env:
        - name: GET_HOSTS_FROM
          value: dns
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
```
thor@jump_host ~$ cat frontend-svc.yaml 
```
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: frontend
  name: frontend
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 30009
  selector:
    app: frontend
  type: NodePort
status:
  loadBalancer: {}
```
thor@jump_host ~$ `kubectl get all`
```
NAME                                READY   STATUS    RESTARTS   AGE
pod/frontend-768858b896-dnz4v       1/1     Running   0          4m3s
pod/frontend-768858b896-vdpcv       1/1     Running   0          4m3s
pod/frontend-768858b896-wnkks       1/1     Running   0          4m3s
pod/redis-master-5578f8cc95-9jtcl   1/1     Running   0          4m3s
pod/redis-slave-dcb89478d-hc9xc     1/1     Running   0          4m3s
pod/redis-slave-dcb89478d-nkfdv     1/1     Running   0          4m2s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/frontend       NodePort    10.96.253.194   <none>        80:30009/TCP   2m24s
service/kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP        34m
service/redis-master   ClusterIP   10.96.105.114   <none>        6379/TCP       3m31s
service/redis-slave    ClusterIP   10.96.148.155   <none>        6379/TCP       3m25s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/frontend       3/3     3            3           4m3s
deployment.apps/redis-master   1/1     1            1           4m3s
deployment.apps/redis-slave    2/2     2            2           4m3s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/frontend-768858b896       3         3         3       4m3s
replicaset.apps/redis-master-5578f8cc95   1         1         1       4m3s
replicaset.apps/redis-slave-dcb89478d     2         2         2       4m3s 
```
