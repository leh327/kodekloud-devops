# Assignment
Recently some of the performance issues were observed with some applications hosted on Kubernetes cluster.  
The Nautilus DevOps team has observed some resources constraints, where some of the applications are running  
out of resources like memory, cpu etc., and some of the applications are consuming more resources than needed.  
Therefore, the team has decided to add some limits for resources utilization. Below you can find more details.

Create a pod named httpd-pod and a container under it named as httpd-container, use httpd image with latest  
tag only and remember to mention tag i.e httpd:latest and set the following limits:

Requests: Memory: 15Mi, CPU: 100m

Limits: Memory: 20Mi, CPU: 100m

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
thor@jump_host ~$ `cat <<EOF | kubectl apply -f -`
```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: httpd-pod
  name: httpd-pod
spec:
  containers:
  - image: httpd:latest
    name: httpd-container
    resources: 
      limits:
        memory: 20Mi
        cpu: 100m
      requests:
        memory: 15Mi
        cpu: 100m
EOF
```
thor@jump_host ~$ `kubectl wait --for=condition=ready pods --selector=run=httpd-pod`  
thor@jump_host ~$ `kubectl describe pod | grep -e Limits -e Requests -e httpd-container -A3 -B1`
