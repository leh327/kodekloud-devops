# Assignment
A new MySQL server needs to be deployed on Kubernetes cluster. The Nautilus DevOps team was working on to gather the requirements. Recently they were able to finalize the requirements and shared them with the team members to start working on it. Below you can find the details:

1.) Create a PersistentVolume mysql-pv, its capacity should be 250Mi, set other parameters as per your preference.
2.) Create a PersistentVolumeClaim to request this PersistentVolume storage. Name it as mysql-pv-claim and request a 250Mi of storage. Set other parameters as per your preference.
3.) Create a deployment named mysql-deployment, use any mysql image as per your preference. Mount the PersistentVolume at mount path /var/lib/mysql.
4.) Create a NodePort type service named mysql and set nodePort to 30007.
5.) Create a secret named mysql-root-pass having a key pair value, where key is password and its value is YUIidhb667, create another secret named mysql-user-pass having some key pair values, where frist key is username and its value is kodekloud_rin, second key is password and value is YchZHRcLkL, create one more secret named mysql-db-url, key name is database and value is kodekloud_db9
6.) Define some Environment variables within the container:
a) name: MYSQL_ROOT_PASSWORD, should pick value from secretKeyRef name: mysql-root-pass and key: password
b) name: MYSQL_DATABASE, should pick value from secretKeyRef name: mysql-db-url and key: database
c) name: MYSQL_USER, should pick value from secretKeyRef name: mysql-user-pass key key: username
d) name: MYSQL_PASSWORD, should pick value from secretKeyRef name: mysql-user-pass and key: password
Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.



# Solution
cat > mysql-deployment.yaml <<EOF
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 250Mi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: standard
  hostPath:
    path: /tmp
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi
---
apiVersion: v1
data:
  password: WWNoWkhSY0xrTA==
  username: a29kZWtsb3VkX3Jpbg==
kind: Secret
metadata:
  creationTimestamp: null
  name: mysql-user-pass
---
apiVersion: v1
data:
  database: a29kZWtsb3VkX2RiOQ==
kind: Secret
metadata:
  creationTimestamp: null
  name: mysql-db-url
---
apiVersion: v1
data:
  password: WVVJaWRoYjY2Nw==
kind: Secret
metadata:
  creationTimestamp: null
  name: mysql-root-pass
---
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: mysql-deployment
  name: mysql-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql-deployment
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: mysql-deployment
    spec:
      volumes:
      - name: mysql-volume
        persistentVolumeClaim:
          claimName: mysql-pv-claim
      containers:
      - image: mysql
        name: mysql
        volumeMounts:
        - name: mysql-volume
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
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: mysql-deployment
  name: mysql-deployment
spec:
  type: NodePort
  ports:
  - port: 3306
    protocol: TCP
    targetPort: 3306
    nodePort: 30007
  selector:
    app: mysql-deployment                                  
EOF
kubectl apply -f mysql-deployment
$ install mysql client
$ test connection using mysql client and user/password
mysql -u kodekloud_rin -h $(kubectl get pod -o jsonpath='{.items[*].spec.nodeName}') -p 30007
                                  
                                  
