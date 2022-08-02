# Assignment
A new MySQL server needs to be deployed on Kubernetes cluster. The Nautilus DevOps team was working on to gather the requirements.  
Recently they were able to finalize the requirements and shared them with the team members to start working on it. Below you can find the details:


1.) Create a PersistentVolume mysql-pv, its capacity should be 250Mi, set other parameters as per your preference.

2.) Create a PersistentVolumeClaim to request this PersistentVolume storage. Name it as mysql-pv-claim and request a 250Mi of storage.  
Set other parameters as per your preference.

3.) Create a deployment named mysql-deployment, use any mysql image as per your preference. Mount the PersistentVolume at mount path /var/lib/mysql.

4.) Create a NodePort type service named mysql and set nodePort to 30007.

5.) Create a secret named mysql-root-pass having a key pair value, where key is password and its value is YUIidhb667,  
create another secret named mysql-user-pass having some key pair values, where frist key is username and its value is kodekloud_gem,  
second key is password and value is dCV3szSGNA, create one more secret named mysql-db-url, key name is database and value is kodekloud_db9

6.) Define some Environment variables within the container:

a) name: MYSQL_ROOT_PASSWORD, should pick value from secretKeyRef name: mysql-root-pass and key: password

b) name: MYSQL_DATABASE, should pick value from secretKeyRef name: mysql-db-url and key: database

c) name: MYSQL_USER, should pick value from secretKeyRef name: mysql-user-pass key key: username

d) name: MYSQL_PASSWORD, should pick value from secretKeyRef name: mysql-user-pass and key: password

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution

### Create manifest
thor@jump_host ~$ `cat > mysql-deployment.yaml<<EOF`
```
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 250Mi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/var/lib/mysql"

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi

---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-root-pass
type: Opaque
data:
  password: WVVJaWRoYjY2Nw==

---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-user-pass
type: Opaque
data:
  username: a29kZWtsb3VkX2dlbQ==
  password: ZENWM3N6U0dOQQ==

---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-db-url
type: Opaque
data:
  database: a29kZWtsb3VkX2RiNQ==
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deployment
spec:
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      name: mysql-deployment
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:latest
          volumeMounts:
            - name: mysql-pv
              mountPath: /var/lib/mysql
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-root-pass
                  key: password
            - name: MYSQL_DATABASE
              valueFrom:
                secretKeyRef:
                  name: mysql-db-url
                  key: database
            - name: MYSQL_USER
              valueFrom:
                secretKeyRef:
                  name: mysql-user-pass
                  key: username
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-user-pass
                  key: password
      volumes:
        - name: mysql-pv
          persistentVolumeClaim:
            claimName: mysql-pv-claim

---
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  type: NodePort
  selector:
    app: mysql
  ports:
    - port: 3306
      targetPort: 3306
      nodePort: 30007
EOF
```
### deploy mysql deployment
thor@jump_host ~$ `kubectl apply -f mysql-deployment.yaml`  
thor@jump_host ~$ `kubectl wait --for=condition=ready pod --selector=app=mysql`
```
pod/mysql-deployment-7587dffdf6-mpdmz condition met
```

### test connectivity
thor@jump_host ~$ `ssh -v -p 30007 $(kubectl get pod -o jsonpath='{.items[*].spec.nodeName}')`
```
OpenSSH_7.6p1 Ubuntu-4ubuntu0.7, OpenSSL 1.0.2n  7 Dec 2017
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: /etc/ssh/ssh_config line 19: Applying options for *
debug1: Connecting to node01 [10.32.140.5] port 30007.
debug1: Connection established.
```

### Install mysql client and test database access (For ubuntu: apt update; apt install mysql-client -y)
thor@jump_host ~$ `sudo yum install mysql -y`  
thor@jump_host ~$ `mysql -u kodekloud_gem -pdCV3szSGNA -h $(kubectl get pod -o jsonpath='{.items[*].spec.nodeName}') -P 30007`  
```
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 11
Server version: 8.0.30 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> \q
```
#### If one want to test mysql database right on the container:  
thor@jump_host ~$ `kubectl exec -it mysql-deployment-7587dffdf6-tsplg -- mysql -u kodekloud_gem -pdCV3szSGNA`
```
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 12
Server version: 8.0.30 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> \q
Bye
```

#### If one has access to node hosting mysql pod and it is using docker engine, use the following:  
root@node01 ~ ➜  `docker exec -it -u mysql f59a44520763 mysql -u kodekloud_gem -pdCV3szSGNA`
```
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 12
Server version: 8.0.30 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> \q
Bye
```
