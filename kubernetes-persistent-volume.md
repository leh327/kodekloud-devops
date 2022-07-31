# Assignment
The Nautilus DevOps team is working on a Kubernetes template to deploy a web application on the cluster. 
There are some requirements to create/use persistent volumes to store the application code, and the 
template needs to be designed accordingly. Please find more details below:


Create a PersistentVolume named as pv-xfusion. Configure the spec as storage class should be manual, 
set capacity to 4Gi, set access mode to ReadWriteOnce, volume type should be hostPath and set path to 
/mnt/devops (this directory is already created, you might not be able to access it directly, so you need not to worry about it).

Create a PersistentVolumeClaim named as pvc-xfusion. Configure the spec as storage class should be manual, 
request 1Gi of the storage, set access mode to ReadWriteOnce.

Create a pod named as pod-xfusion, mount the persistent volume you created with claim name pvc-xfusion at 
document root of the web server, the container within the pod should be named as container-xfusion using image 
httpd with latest tag only (remember to mention the tag i.e httpd:latest).

Create a node port type service named web-xfusion using node port 30008 to expose the web server running within the pod.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
```
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-xfusion
spec:
  capacity:
    storage: 4Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  hostPath:
    path: /mnt/devops
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-xfusion
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-xfusion
  labels:
    app: pod-xfusion
spec:
  volumes:
    - name: storage-xfusion
      persistentVolumeClaim:
        claimName: pvc-xfusion
  containers:
    - name: container-xfusion
      image: httpd:latest
      ports:
        - containerPort: 80
      volumeMounts:
        - name: storage-nautilus
          mountPath: /usr/share/nginx/html
---
apiVersion: v1
kind: Service
metadata:
  name: web-xfusion
spec:
  selector:
    app: pod-xfusion
  type: NodePort
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30008
```
To test the service run:  
thor@jump\_host ~$ `curl $(kubectl get pod -o jsonpath='{.items[*].spec.nodeName}'):30008`   
If you want to test the pod on port 80 itself look into using `kubectl port-forward`, or `kubectl proxy`  
thor@jump\_host: ~$ `kubectl port-forward $(kubectl get pod -o jsonpath='{.items[*].status.podIP}') 30001:80 &`  
thor@jump\_host: ~$ `curl localhost:30001` (this lets you know that pod-xfusion is listening on port 80)  
