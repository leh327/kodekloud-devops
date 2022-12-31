# Assignment
There is an application that needs to be deployed on Kubernetes cluster under Apache web server.  
  The Nautilus application development team has asked the DevOps team to deploy it.  
  We need to develop a template as per requirements mentioned below:

    Create a namespace named as httpd-namespace-datacenter.

    Create a deployment named as httpd-deployment-datacenter under newly created namespace.  
      For the deployment use httpd image with latest tag only and remember to mention the tag i.e httpd:latest, and make sure replica counts are 2.

    Create a service named as httpd-service-datacenter under same namespace to expose the deployment, nodePort should be 30004.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
  
# Solution
  
thor@jump_host ~$ tee httpd-deployment.yaml<<EOF
```
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: httpd-namespace-datacenter
  labels:
    app: httpd-deployment-datacenter
  name: httpd-deployment-datacenter
spec:
  replicas: 2
  selector:
    matchLabels:
      app: httpd-deployment-datacenter
  strategy: {}
  template:
    metadata:
      labels:
        app: httpd-deployment-datacenter
    spec:
      containers:
      - image: httpd:latest
        name: httpd
        resources: {}
status: {}
---
apiVersion: v1
kind: Service
metadata:
  namespace: httpd-namespace-datacenter
  labels:
    app: httpd-deployment-datacenter
  name: httpd-service-datacenter
spec:
  type: NodePort
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 30004
  selector:
    app: httpd-deployment-datacenter
EOF
```
thor@jump_host ~$ kubectl apply -f httpd-deployment.yaml                                                 
