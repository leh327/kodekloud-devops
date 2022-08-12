# Assignment

The Nautilus DevOps team is planning to set up a Jenkins CI server to create/manage some deployment pipelines for some of the projects.  
They want to set up the Jenkins server on Kubernetes cluster. Below you can find more details about the task:

1) Create a namespace jenkins

2) Create a Service for jenkins deployment. Service name should be jenkins-service under jenkins namespace, type should be NodePort,  nodePort should be 30008

3) Create a Jenkins Deployment under jenkins namespace, It should be name as jenkins-deployment , labels app should be jenkins , container name should be jenkins-container , use jenkins/jenkins image , containerPort should be 8080 and replicas count should be 1.

Make sure to wait for the pods to be in running state and make sure you are able to access the Jenkins login screen in the browser before hitting the Check button.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution

thor@jump_host ~$ `cat > jenkins.yaml <<EOF
```
---
apiVersion: v1
kind: Namespace
metadata:
  name: jenkins

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-deployment
  namespace: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      name: jenkins-deployment
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins-container
        image: jenkins/jenkins
        ports:
        - containerPort: 8080

---
apiVersion: v1
kind: Service
metadata:
  name: jenkins-service
  namespace: jenkins
spec:
  selector:
    app: jenkins
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30008
  type: NodePort
```

thor@jump_host ~$ `kubectl apply -f jenkins.yaml `
```
namespace/jenkins created
deployment.apps/jenkins-deployment created
service/jenkins-service created
```

thor@jump_host ~$ `kubectl wait -n jenkins --for=condition=ready pod --selector=app=jenkins`
```
pod/jenkins-deployment-7c5c7998c8-mcpqt condition met
```

thor@jump_host ~$ `curl $(kubectl get -n jenkins pod -o jsonpath='{.items[*].spec.nodeName}'):30008`
```
<html><head><meta http-equiv='refresh' content='1;url=/login?from=%2F'/><script>window.location.replace('/login?from=%2F');</script></head><body style='background-color:white; color:white;'>


Authentication required
<!--
-->

</body></html>
```
thor@jump_host ~$ 

# Reference:
[configure jenkins as code](https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code)
