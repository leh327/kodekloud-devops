# Assignment
The Nautilus DevOps team is working on a Kubernetes template to deploy a web application on the cluster.  
There are some requirements to create/use persistent volumes to store the application code, and the  
template needs to be designed accordingly. Please find more details below:



Create a PersistentVolume named as pv-datacenter. Configure the spec as storage class should be manual,  
set capacity to 4Gi, set access mode to ReadWriteOnce, volume type should be hostPath and set path to  
/mnt/security (this directory is already created, you might not be able to access it directly,  
so you need not to worry about it).

Create a PersistentVolumeClaim named as pvc-datacenter. Configure the spec as storage class should be manual,  
request 3Gi of the storage, set access mode to ReadWriteOnce.

Create a pod named as pod-datacenter, mount the persistent volume you created with claim name  
pvc-datacenter at document root of the web server, the container within the pod should be named as  
container-datacenter using image nginx with latest tag only (remember to mention the tag i.e nginx:latest).

Create a node port type service named web-datacenter using node port 30008 to expose the web server running within the pod.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
root@jump_host ~# `cat .bash_history`
```
yum -y install ansible kubernetes-client python3 python3-pip
pip3 install --upgrade pip
pip3 install openshift
```

thor@jump_host ~$ `ansible-galaxy collection install kubernetes.core`
```
Process install dependency map
Starting collection install process
Installing 'kubernetes.core:2.3.2' to '/home/thor/.ansible/collections/ansible_collections/kubernetes/core'
```

thor@jump_host ~$ `tee ansible.cfg<<EOF`
```
[defaults]
collections_path = .ansible/collections
EOF
```
thor@jump_host ~$ `tee pod_with_pv.yaml<<EOF`
```
---
- hosts: localhost
  gather_facts: no
  tasks:
  - kubernetes.core.k8s:
      state: present
      definition:
        apiVersion: v1
        kind: PersistentVolume
        metadata:
          name: pv-datacenter
        spec:
          capacity:
            storage: 4Gi
          accessModes:
          - ReadWriteOnce
          storageClassName: manual
          hostPath:
            path: /mnt/security
  - kubernetes.core.k8s:
      state: present
      definition:
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: pvc-datacenter
          namespace: default
        spec:
          resources:
            requests:
              storage: 4Gi
          accessModes:
          - ReadWriteOnce
          storageClassName: manual
  - kubernetes.core.k8s:
      state: present
      definition:
        apiVersion: v1
        kind: Pod
        metadata:
          name: pod-datacenter
          app: nginx
          namespace: default
        spec:
          volumes:
          - name: datacenter-volume
            persistentVolumeClaim:
              claimName: pvc-datacenter
          containers:
          - name: container-datacenter
            image: nginx:latest
            volumeMounts:
            - name: datacenter-volume
              mountPath: /usr/share/nginx/html

  - kubernetes.core.k8s:
      state: present
      definition:
        apiVersion: v1
        kind: Service
        metadata:
          labels:
            name: web-datacenter-svc
          name: web-datacenter
          namespace: default
        spec:
          selector:
            app: nginx
          type: NodePort
          ports:
          - port: 80
            targetPort: 80
            nodePort: 30008
```
thor@jump_host ~$ ansible-playbook pv.yaml -e 'ansible_python_interpreter=/usr/bin/python3'
