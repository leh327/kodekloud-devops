# Assignment
There are some applications that need to be deployed on Kubernetes cluster and these apps have some pre-requisites where  
some configurations need to be changed before deploying the app container. Some of these changes cannot be made inside  
the images so the DevOps team has come up with a solution to use init containers to perform these tasks during deployment.  
Below is a sample scenario that the team is going to test first.

    Create a Deployment named as ic-deploy-datacenter.

    Configure spec as replicas should be 1, labels app should be ic-datacenter, template's metadata lables app should be the same ic-datacenter.

    The initContainers should be named as ic-msg-datacenter, use image fedora, preferably with latest tag and use command '/bin/bash', '-c' and 'echo Init Done - Welcome to xFusionCorp Industries > /ic/news'. The volume mount should be named as ic-volume-datacenter and mount path should be /ic.

    Main container should be named as ic-main-datacenter, use image fedora, preferably with latest tag and use command '/bin/bash', '-c' and 'while true; do cat /ic/news; sleep 5; done'. The volume mount should be named as ic-volume-datacenter and mount path should be /ic.

    Volume to be named as ic-volume-datacenter and it should be an emptyDir type.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution

```
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ic-datacenter
  name: ic-deploy-datacenter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ic-datacenter
  template:
    metadata:
      labels:
        app: ic-datacenter
    spec:
      volumes:
      - name: ic-volume-datacenter
        emptyDir: {}
      initContainers:
      - image: debian:latest
        name: debian
        command: ['/bin/bash', '-c', 'echo Init Done - Welcome to xFusionCorp Industries > /ic/beta']
        name: ic-msg-datacenter
        volumeMounts:
        - mountPath: /ic
          name: ic-volume-datacenter
      containers:
      - image: debian:latest
        name: debian
        command: ['/bin/bash', '-c', 'while true; do cat /ic/beta; sleep 5; done']
        volumeMounts:
        - mountPath: /ic
          name: ic-volume-datacenter
        name: ic-main-datacenter
EOF
```
thor@jump_host ~$ kubectl get deployment
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
ic-deploy-datacenter   1/1     1            1           7m48s
thor@jump_host ~$
