# Assignment

Recently some of the performance issues were observed with some applications hosted on Kubernetes cluster. The Nautilus DevOps team has observed some resources constraints, where some of the applications are running out of resources like memory, cpu etc., and some of the applications are consuming more resources than needed. Therefore, the team has decided to add some limits for resources utilization. Below you can find more details.



Create a pod named httpd-pod and a container under it named as httpd-container, use httpd image with latest tag only and remember to mention tag i.e httpd:latest and set the following limits:

Requests: Memory: 15Mi, CPU: 100m

Limits: Memory: 20Mi, CPU: 100m

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution

thor@jump_host ~$ `kubectl run httpd-pod --image=httpd:latest
 --overrides='{"apiVersion": "v1", "spec": {"containers": [{
 "name": "httpd-container", "image": "httpd:latest", 
 "resources": {
   "limits": {"cpu": "100m", "memory": "20Mi"},
   "requests": {"cpu": "100m","memory": "15Mi"}}}] } }'`
```
pod/httpd-pod created
```
thor@jump_host ~$ `kubectl describe pod`
```
Name:         httpd-pod
Namespace:    default
Priority:     0
Node:         kodekloud-control-plane/172.17.0.2
Start Time:   Sat, 04 Feb 2023 03:23:00 +0000
Labels:       run=httpd-pod
Annotations:  <none>
Status:       Running
IP:           10.244.0.5
IPs:
  IP:  10.244.0.5
Containers:
  httpd-container:
    Container ID:   containerd://c88bdb4d72e3db32d8c01b58fe28408aa022c4f046d058799097d30bfd715eda
    Image:          httpd:latest
    Image ID:       docker.io/library/httpd@sha256:87a012bf99bf5e3e0f628ac1f69abbeab534282857fba3a359ca3a3f4a02429a
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sat, 04 Feb 2023 03:23:00 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     100m
      memory:  20Mi
    Requests:
      cpu:        100m
      memory:     15Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-hb4kc (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  default-token-hb4kc:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-hb4kc
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                 node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  3m23s  default-scheduler  Successfully assigned default/httpd-pod to kodekloud-control-plane
  Normal  Pulling    3m21s  kubelet            Pulling image "httpd:latest"
  Normal  Pulled     3m8s   kubelet            Successfully pulled image "httpd:latest" in 13.69665149s
  Normal  Created    3m7s   kubelet            Created container httpd-container
  Normal  Started    3m6s   kubelet            Started container httpd-container
```
thor@jump_host ~$ 
