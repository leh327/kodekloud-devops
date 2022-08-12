# Assignment
The Nautilus DevOps team is planning to set up a Nagios monitoring tool to monitor some applications, services etc. 
They are planning to deploy it on Kubernetes cluster. Below you can find more details.

1) Create a deployment `nagios-deployment` for Nagios core. The container name must be `nagios-container` and it must use `jasonrivers/nagios` image.

2) Create a user and password for the Nagios core web interface,
  user must be  
    `xFusionCorp`  
  and password must be:  
    `LQfKeWWxWD`  
  (you can manually perform this step after deployment)

3) Create a service `nagios-service` for Nagios, which must be of `targetPort` type. `nodePort` must be `30008`.

You can use any labels as per your choice.

Note: The kubectl on jump_host has been configured to work with the kubernetes cluster.

# Solution
thor@jump_host ~$ `cat > nagios-deployment <<EOF`
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nagios-deployment
  name: nagios-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nagios-deployment
  template:
    metadata:
      labels:
        app: nagios-deployment
    spec:
      containers:
        - image: jasonrivers/nagios
          name: nagios-container
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nagios-service
spec:
  selector:
    app: nagios-deployment
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30008
  type: NodePort
EOF
```
thor@jump_host ~$ `kubectl apply -f nagios-deployment` 
```
deployment.apps/nagios-deployment created
service/nagios-service created
```
thor@jump_host ~$ `kubectl wait --for=condition=ready pods --selector=app=nagios-deployment`
```
pod/nagios-deployment-5f6c8f586f-72zj4 condition met
```
thor@jump_host ~$ 

Add nagios webui user following this doc(https://www.ibm.com/docs/en/power8?topic=POWER8/p8ef9/p8ef9_ppim_nagios_userid.htm)  
htpasswd /usr/local/nagios/etc/htpasswd.users xFusionCorp  

