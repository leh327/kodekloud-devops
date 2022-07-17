## Problem
```
We have an application running on Kubernetes cluster using nginx web server.
The Nautilus application development team has pushed some of the latest changes and those changes need be deployed.
The Nautilus DevOps team has created an image nginx:1.18 with the latest changes.

Perform a rolling update for this application and incorporate nginx:1.18 image. The deployment name is nginx-deployment
Make sure all pods are up and running after the update.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
```
## Solution
* Make backup of current deployment
```
thor@jump_host ~$ kubectl get deployment nginx-deployment -o yaml > nginx-deployment.yaml
```
* Check deployment update strategy
```
hor@jump_host ~$ kubectl describe deployment nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Sun, 17 Jul 2022 21:09:22 +0000
Labels:                 app=nginx-app
                        type=front-end
Annotations:            deployment.kubernetes.io/revision: 5
Selector:               app=nginx-app
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx-app
  Containers:
   nginx-container:
    Image:        nginx:1.16
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-74fb588559 (3/3 replicas created)
Events:
```

* Patch deployment to replace image to nginx:1.18
```
thor@jump_host ~$ kubectl patch deployment nginx-deployment --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value": "nginx:1.18"}]'
deployment.apps/nginx-deployment patched
```

* Confirm pods are being replaced with new pods whose image is nginx:1.18
```
thor@jump_host ~$ kubectl get pod
NAME                                READY   STATUS              RESTARTS   AGE
nginx-deployment-74fb588559-75vzj   1/1     Running             0          4m17s
nginx-deployment-74fb588559-7cm24   0/1     Terminating         0          4m13s
nginx-deployment-74fb588559-95h75   1/1     Terminating         0          4m15s
nginx-deployment-7b6877b9b5-2k8hs   1/1     Running             0          6s
nginx-deployment-7b6877b9b5-czznk   0/1     ContainerCreating   0          1s
nginx-deployment-7b6877b9b5-jp9xc   1/1     Running             0          4s
thor@jump_host ~$ kubectl get pod
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-7b6877b9b5-2k8hs   1/1     Running   0          56s
nginx-deployment-7b6877b9b5-czznk   1/1     Running   0          51s
nginx-deployment-7b6877b9b5-jp9xc   1/1     Running   0          54s
thor@jump_host ~$ 
thor@jump_host ~$ kubectl get pod -o jsonpath='{.items[*].spec.containers[*].image}'
nginx:1.18 nginx:1.18 nginx:1.18
thor@jump_host ~$
```
