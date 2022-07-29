# Assignment
We are working on an application that will be deployed on multiple containers within a pod on Kubernetes cluster. 
There is a requirement to share a volume among the containers to save some temporary data. The Nautilus DevOps 
team is developing a similar template to replicate the scenario. Below you can find more details about it.


Create a pod named volume-share-devops.

For the first container, use image ubuntu with latest tag only and remember to mention the tag i.e ubuntu:latest, 
container should be named as volume-container-devops-1, and run a sleep command for it so that it remains in 
running state. Volume volume-share should be mounted at path /tmp/beta.

For the second container, use image ubuntu with the latest tag only and remember to mention the tag i.e ubuntu:latest, 
container should be named as volume-container-devops-2, and again run a sleep command for it so that it remains in 
running state. Volume volume-share should be mounted at path /tmp/cluster.

Volume name should be volume-share of type emptyDir.

After creating the pod, exec into the first container i.e volume-container-devops-1, and just for testing create 
a file beta.txt with any content under the mounted path of first container i.e /tmp/beta.

The file beta.txt should be present under the mounted path /tmp/cluster on the second container 
volume-container-devops-2 as well, since they are using a shared volume.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
### Create pod with two containers share the same emptyDir volume.  Write to shared volume in one container and check in another container to make sure same file exist
thor@jump_host $ `vi volume-share-devops.yaml`
```
apiVersion: v1
kind: Pod
metadata:
  name volume-share-devops
spec:
  volumes:
  - name: volume-share
    emptyDir: {}
  containers:
  - name: volume-container-devops-1
    image: ubuntu:latest
    command: ["sleep", "infinity"]
    volumeMounts:
    - name: volume-share
      mountPath: /tmp/beta
  - name: volume-container-devops-2
    image: ubuntu:latest
    command: ["sleep", "infinity"]
    volumeMounts:
    - name: volume-share
      mountPath: /tmp/cluster
```
thor@jump_host $ `kubectl create -f volume-share-devops.yaml`  
thor@jump_host $ `kubectl wait --for=condition=ready pod volume-share-devops`
```
pod/volume-share-devops condition met
```
thor@jump_host $ `kubectl exec -it $(kubectl get pod -o name) -c volume-container-devops-1 -- touch /tmp/beta/beta.txt`  
thor@jump_host $ `kubectl exec -it $(kubectl get pod -o name) -c volume-container-devops-2 -- ls /tmp/beta/beta.txt`
```
/tmp/cluster/beta.txt
```
