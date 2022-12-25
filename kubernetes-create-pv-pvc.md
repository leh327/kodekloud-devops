# Assignment

The Nautilus DevOps team is working on a Kubernetes template to deploy a web application on the cluster.  
There are some requirements to create/use persistent volumes to store the application code, and the template  
needs to be designed accordingly. Please find more details below:

Create a PersistentVolume named as pv-nautilus. Configure the spec as storage class should be manual, set capacity to 4Gi,  
set access mode to ReadWriteOnce, volume type should be hostPath and set path to /mnt/dba  
(this directory is already created, you might not be able to access it directly, so you need not to worry about it).
Create a PersistentVolumeClaim named as pvc-nautilus. Configure the spec as storage class should be manual,  
request 1Gi of the storage, set access mode to ReadWriteOnce.
Create a pod named as pod-nautilus, mount the persistent volume you created with claim name pvc-nautilus at  
document root of the web server, the container within the pod should be named as container-nautilus using image  
httpd with latest tag only (remember to mention the tag i.e httpd:latest).
Create a node port type service named web-nautilus using node port 30008 to expose the web server running within the pod.
Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
### Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolume
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-datacenter
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 4Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/security"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-datacenter
  labels:
     type: local
spec:
  storageClassName: manual
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-datacenter
  labels:
    app: nginx
spec:
  volumes:
  - name: pvc-datacenter
    persistentVolumeClaim:
      claimName: pvc-datacenter
  containers:
  - image: nginx:latest
    name: container-datacenter
    volumeMounts:
    - name: pvc-datacenter
      mountPath: /usr/share/ngixn/html
---
apiVersion: v1
kind: Service
metadata:
  name: web-nautilus
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    nodePort: 30008
    targetPort: 80
  type: NodePort
```
