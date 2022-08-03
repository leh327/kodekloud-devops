# Assignment

The Nautilus development team has completed development of one of the node applications, which they are planning to deploy on a Kubernetes cluster. They recently had a meeting with the DevOps team to share their requirements. Based on that, the DevOps team has listed out the exact requirements to deploy the app. Find below more details:


Create a deployment using gcr.io/kodekloud/centos-ssh-enabled:node image, replica count must be 2.

Create a service to expose this app, the service type must be NodePort, targetPort must be 8080 and nodePort should be 30012.

Make sure all the pods are in Running state after the deployment.

You can check the application by clicking on NodeApp button on top bar.

You can use any labels as per your choice.

Note: The kubectl on jump_host has been configured to work with the kubernetes cluster.

# Solution

thor@jump_host ~$ cat > node.yaml<<EOF
```
apiVersion: v1                                                                                                                                        
kind: Service                                                                                                                                         
metadata:                                                                                                                                             
  name: node-service-datacenter                                                                                                                                                                                                                                      
spec:                                                                                                                                                 
  type: NodePort                                                                                                                                      
  selector:                                                                                                                                           
    app: node-app-datacenter                                                                                                                          
  ports:                                                                                                                                              
    - port: 80                                                                                                                                        
      targetPort: 8080                                                                                                                                
      nodePort: 30012                                                                                                                                 
---                                                                                                                                                   
apiVersion: apps/v1                                                                                                                                   
kind: Deployment                                                                                                                                      
metadata:                                                                                                                                             
  name: node-deployment-datacenter                                                                                                                                                                                                                                 
spec:                                                                                                                                                 
  replicas: 2                                                                                                                                         
  selector:                                                                                                                                           
    matchLabels:                                                                                                                                      
      app: node-app-datacenter                                                                                                                        
  template:                                                                                                                                           
    metadata:                                                                                                                                         
      labels:                                                                                                                                         
        app: node-app-datacenter                                                                                                                      
    spec:                                                                                                                                             
      containers:                                                                                                                                     
        - name: node-container-datacenter                                                                                                             
          image: gcr.io/kodekloud/centos-ssh-enabled:node                                                                                             
          ports:                                                                                                                                      
            - containerPort: 80   
  
```

thor@jump_host ~$ `kubectl create -f /tmp/node.yaml`
```
service/node-service-datacenter created                                                                                                               
deployment.apps/node-deployment-datacenter created

```
thor@jump_host ~$ `kubectl get pods`
```
NAME                                          READY   STATUS    RESTARTS   AGE                                                                        
node-deployment-datacenter-868b948f74-965xz   1/1     Running   0          114s                                                                       
node-deployment-datacenter-868b948f74-qnrt8   1/1     Running   0          114s                                                                       
thor@jump_host ~$
```
