
# Assignment
The Nautilus DevOps team is working to deploy some tools in Kubernetes cluster. Some of the tools are licence based so that licence information needs to be stored securely within Kubernetes cluster. Therefore, the team wants to utilize Kubernetes secrets to store those secrets. Below you can find more details about the requirements:



We already have a secret key file ecommerce.txt under /opt location on jump host. Create a generic secret named ecommerce, it should contain the password/license-number present in ecommerce.txt file.

Also create a pod named secret-datacenter.

Configure pod's spec as container name should be secret-container-datacenter, image should be ubuntu preferably with latest tag (remember to mention the tag with image). Use sleep command for container so that it remains in running state. Consume the created secret and mount it under /opt/demo within the container.

To verify you can exec into the container secret-container-datacenter, to check the secret key under the mounted path /opt/demo. Before hitting the Check button please make sure pod/pods are in running state, also validation can take some time to complete so keep patience.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.


# Solution
thor@jump_host ~$ `kubectl create secret generic ecommerce --from-file=/opt/ecommerce.txt`
```
secret/ecommerce created
```
thor@jump_host ~$ `tee pod.yaml <<EOF`
```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: secret-datacenter
  name: secret-datacenter
spec:
  volumes:
  - name: ecommerce
    secret:
      secretName: ecommerce
  containers:
  - command:
    - "sh"
    - "-c"
    - "sleep 2000"
    image: ubuntu:latest
    name: secret-container-datacenter
    volumeMounts:
    - mountPath: /opt/demo
      name: ecommerce
EOF
```
