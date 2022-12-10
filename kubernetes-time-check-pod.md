# Assignment
The Nautilus DevOps team want to create a time check pod in a particular Kubernetes namespace and record the logs.  
This might be initially used only for testing purposes, but later can be implemented in an existing cluster.  
Please find more details below about the task and perform it.

Create a pod called time-check in the datacenter namespace. This pod should run a container called time-check,  
  container should use the busybox image with latest tag only and remember to mention tag i.e busybox:latest.
Create a config map called time-config with the data TIME_FREQ=7 in the same namespace.
The time-check container should run the command:  
   while true; do date; sleep $TIME_FREQ;done and should write the result to the location /opt/sysops/time/time-check.log.   
   Remember you will also need to add an environmental variable TIME_FREQ in the container, which should pick value from the config map TIME_FREQ key.
Create a volume log-volume and mount the same on /opt/sysops/time within the container.
Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
thor@jump_host ~$ `kubectl create ns datacenter`
```
namespace/datacenter created
```
thor@jump_host ~$ kubectl create -n datacenter cm time-config --from-literal=TIME_FREQ=7`  
```
configmap/time-config created
```
thor@jump_host ~$ `cat >pod.yaml<<EOF`
```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: time-check
  name: time-check
  namespace: datacenter
spec:
  containers:
  - name: time-check
    command:
    - sh
    - "-c"
    - while true; do date; sleep ;done | tee /opt/sysops/time/time-check.log
    image: busybox:latest
    volumeMounts:
    - mountPath: /opt/sysops/time
      name: log-volume
    env:
    - name: TIME_FREQ
      valueFrom:
        configMapKeyRef:
          name: time-config
          key: TIME_FREQ
  volumes:
  - name: log-volume
    emptyDir: {}
EOF
```
thor@jump_host ~$ `kubectl apply -f pod.yaml`
```
pod/time-check created
```
thor@jump_host ~$ `kubectl logs -n datacenter time-check`
```
Sat Dec 10 15:57:00 UTC 2022
```
thor@jump_host ~$ `kubectl logs -n datacenter time-check`
```
Sat Dec 10 15:57:00 UTC 2022
Sat Dec 10 15:57:07 UTC 2022
```
thor@jump_host ~$ 
