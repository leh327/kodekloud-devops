# Assignment
This morning the Nautilus DevOps team rolled out a new release for one of the applications. Recently one of the customers logged a complaint which seems to be about a bug related to the recent release. Therefore, the team wants to rollback the recent release.

There is a deployment named nginx-deployment; roll it back to the previous revision.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
thor@jump_host ~$ `kubectl get deployment`
```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           119s
```
thor@jump_host ~$ `kubectl rollout history deployment nginx-deployment`
```
deployment.apps/nginx-deployment 
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment nginx-deployment nginx-container=nginx:stable --kubeconfig=/root/.kube/config --record=true
```
thor@jump_host ~$ `kubectl get pod`
```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5546d5b87b-h4rq7   1/1     Running   0          2m6s
nginx-deployment-5546d5b87b-qrlnv   1/1     Running   0          2m8s
nginx-deployment-5546d5b87b-ss472   1/1     Running   0          2m18s
```
thor@jump_host ~$ `kubectl rollout undo deployment nginx-deployment`
```
deployment.apps/nginx-deployment rolled back
```
thor@jump_host ~$ `kubectl rollout history deployment nginx-deployment`
```
deployment.apps/nginx-deployment 
REVISION  CHANGE-CAUSE
2         kubectl set image deployment nginx-deployment nginx-container=nginx:stable --kubeconfig=/root/.kube/config --record=true
3         <none>
```
thor@jump_host ~$ `kubectl get pod`
```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-74fb588559-8vtmt   1/1     Running   0          16s
nginx-deployment-74fb588559-pw7rq   1/1     Running   0          19s
nginx-deployment-74fb588559-vdtrp   1/1     Running   0          21s
```
thor@jump_host ~$ 
