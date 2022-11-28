# Assignment
  deploy awx-operator and start up an instance of awx project on kubernetes cluster on docker desktop or minukube
  
  
# Solution:
## Reference:
https://github.com/ansible/awx-operator#basic-install
https://kubectl.docs.kubernetes.io/installation/kustomize/

$ `cat awx-demo.yaml`
```
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-demo
spec:
  service_type: nodeport
  # default nodeport_port is 30080
  nodeport_port: 30080
```


$ `cat kustomization.yaml`
```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  # Find the latest tag here: https://github.com/ansible/awx-operator/releases
  - github.com/ansible/awx-operator/config/default?ref=1.1.0
  - awx-demo.yaml

# Set the image tags to match the git version from above
images:
  - name: quay.io/ansible/awx-operator
    newTag: 1.1.0

# Specify a custom namespace in which to install AWX
namespace: awx
```

$ `kustomize build . | kubectl apply -f -`  
$ `kubectl port-forward -n awx service/awx-demo-service 30080:80 &`  
$ `kubectl -n awx get secret awx-demo-admin-password -o jsonpath="{.data.password}" | base64 --decode`  
$ wait few minutes then point web-browser to http://localhost:30080 and change admin password to see if it take.
