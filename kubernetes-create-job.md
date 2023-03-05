# Assignment
The Nautilus DevOps team is working on to create few jobs in Kubernetes cluster. They might come up with some real scripts/commands to use, but for now they are preparing the templates and testing the jobs with dummy commands. Please create a job template as per details given below:



Create a job countdown-devops.

The spec template should be named as countdown-devops (under metadata), and the container should be named as container-countdown-devops

Use image fedora with latest tag only and remember to mention tag i.e fedora:latest, and restart policy should be Never.

Use command for i in 10 9 8 7 6 5 4 3 2 1 ; do echo $i ; done

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
# Solution
thor@jump_host ~$ `kubectl create job countdown-devops --image=fedora:latest --dry-run=client -o yaml -- "/bin/sh" "-c" 'for i in 10 9 8 7 6 5 4 3 2 1 ; do echo $i ; done' | sed 's/        name: countdown-devops/        name: container-countdown-devops/' | sed 's/      creationTimestamp: null/      name: countdown-devops/' |tee job.yaml | kubectl apply -f -`
```
job.batch/countdown-devops created
```
thor@jump_host ~$ `cat job.yaml`
```
apiVersion: batch/v1
kind: Job
metadata:
  creationTimestamp: null
  name: countdown-devops
spec:
  template:
    metadata:
      name: countdown-devops
    spec:
      containers:
      - command:
        - /bin/sh
        - -c
        - for i in 10 9 8 7 6 5 4 3 2 1 ; do echo $i ; done
        image: fedora:latest
        name: container-countdown-devops
        resources: {}
      restartPolicy: Never
status: {}
```
thor@jump_host ~$ `kubectl get pod`
```
NAME                      READY   STATUS      RESTARTS   AGE
countdown-xfusion-7l8hq   0/1     Completed   0          104s
```
thor@jump_host ~$ `kubectl describe pod countdown-xfusion-7l8hq`
```
Name:         countdown-xfusion-7l8hq
Namespace:    default
Priority:     0
Node:         kodekloud-control-plane/172.17.0.2
Start Time:   Sat, 08 Oct 2022 01:51:35 +0000
Labels:       controller-uid=c45511eb-9e0c-4c97-b564-5bc786c35ee0
              job-name=countdown-xfusion
Annotations:  <none>
Status:       Succeeded
IP:           10.244.0.5
IPs:
  IP:           10.244.0.5
Controlled By:  Job/countdown-xfusion
Containers:
  container-countdown-xfusion:
    Container ID:  containerd://2957571f2377bee370c8dc7dd4c477fcba74273f6cae21d7dbdc70b6cda3dd52
    Image:         debian:latest
    Image ID:      docker.io/library/debian@sha256:e538a2f0566efc44db21503277c7312a142f4d0dedc5d2886932b92626104bff
    Port:          <none>
    Host Port:     <none>
    Command:
      bash
      -c
      for i in 10 9 8 7 6 5 4 3 2 1 ; do echo $i ; done
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Sat, 08 Oct 2022 01:51:44 +0000
      Finished:     Sat, 08 Oct 2022 01:51:44 +0000
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-ztskf (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  default-token-ztskf:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-ztskf
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                 node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m16s  default-scheduler  Successfully assigned default/countdown-xfusion-7l8hq to kodekloud-control-plane
  Normal  Pulling    2m16s  kubelet            Pulling image "debian:latest"
  Normal  Pulled     2m8s   kubelet            Successfully pulled image "debian:latest" in 8.082162952s
  Normal  Created    2m7s   kubelet            Created container container-countdown-xfusion
  Normal  Started    2m7s   kubelet            Started container container-countdown-xfusion
```
thor@jump_host ~$ `kubectl logs countdown-xfusion-7l8hq`
```
10
9
8
7
6
5
4
3
2
1
```
thor@jump_host ~$ 
