# Assignment
The Nautilus DevOps team is working on to setup some pre-requisites for an application that will send the greetings to different users. There is a sample deployment, that needs to be tested. Below is a scenario which needs to be configured on Kubernetes cluster. Please find below more details about it.



Create a pod named print-envars-greeting.

Configure spec as, the container name should be print-env-container and use bash image.

Create three environment variables:

a. GREETING and its value should be Welcome to

b. COMPANY and its value should be xFusionCorp

c. GROUP and its value should be Industries

Use command to echo ["$(GREETING) $(COMPANY) $(GROUP)"] message.

You can check the output using <kubctl logs -f [ pod-name ]> command.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution

root@jump_host ~# `yum -y install ansible python3 python3-pip`  
root@jump_host ~# `pip3 install openshift`  
thor@jump_host ~$ `cat pod.yml <<EOF`
```
- hosts: localhost
  gather_facts: no
  tasks:
  - name: create pod
    k8s:
      state: present
      definition:
        apiVersion: v1
        kind: Pod
        metadata:
          namespace: default
          name: print-envars-greeting
          labels:
            name: print-envars-greeting
        spec:
          containers:
          - name: print-env-container
            image: bash
            command: 
            - sh
            - "-c"
            - echo ["$(GREETING) $(COMPANY) $(GROUP)"]
            env:
            - name: GREETING
              value: "Welcome to"
            - name: COMPANY
              value: xFusionCorp
            - name: GROUP
              value: Industries
 ``` 

thor@jump_host ~$ `ansible-playbook pod.yml -e 'ansible_python_interpreter=/usr/bin/python3'`
```
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit
localhost does not match 'all'

PLAY [localhost] *****************************************************************************

TASK [create pod] ****************************************************************************
changed: [localhost]

PLAY RECAP ***********************************************************************************
localhost                  : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
thor@jump_host ~$ `kubectl get pod`
```
NAME                    READY   STATUS             RESTARTS   AGE
print-envars-greeting   0/1     CrashLoopBackOff   4          2m43s
```
thor@jump_host ~$ `kubectl logs print-envars-greeting`
```
[Welcome to xFusionCorp Industries]
```
thor@jump_host ~$ 
