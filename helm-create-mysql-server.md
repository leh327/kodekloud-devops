# Assignment

A new MySQL server needs to be deployed on Kubernetes cluster. The Nautilus DevOps team was working on to gather the requirements.  
Recently they were able to finalize the requirements and shared them with the team members to start working on it. Below you can find the details:

1.) Create a PersistentVolume mysql-pv, its capacity should be 250Mi, set other parameters as per your preference.
2.) Create a PersistentVolumeClaim to request this PersistentVolume storage. Name it as mysql-pv-claim and request a 250Mi of storage.  
    Set other parameters as per your preference.
3.) Create a deployment named mysql-deployment, use any mysql image as per your preference. Mount the PersistentVolume at mount path /var/lib/mysql.
4.) Create a NodePort type service named mysql and set nodePort to 30007.
5.) Create a secret named mysql-root-pass having a key pair value, where key is password and its value is YUIidhb667,  
    create another secret named mysql-user-pass having some key pair values, where frist key is username and its value is kodekloud_tim,  
    second key is password and value is dCV3szSGNA, create one more secret named mysql-db-url, key name is database and value is kodekloud_db4
6.) Define some Environment variables within the container:
a) name: MYSQL_ROOT_PASSWORD, should pick value from secretKeyRef name: mysql-root-pass and key: password
b) name: MYSQL_DATABASE, should pick value from secretKeyRef name: mysql-db-url and key: database
c) name: MYSQL_USER, should pick value from secretKeyRef name: mysql-user-pass key key: username
d) name: MYSQL_PASSWORD, should pick value from secretKeyRef name: mysql-user-pass and key: password
Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution

### References:
https://github.com/helm/chartmuseum
https://github.com/helm/chartmuseum/releases
https://medium.com/devops-dudes/getting-your-vault-secrets-into-kubernetes-82ec7ffcee6f
https://developer.hashicorp.com/vault/tutorials/kubernetes/agent-kubernetes
https://developer.hashicorp.com/vault/docs/platform/k8s/injector
https://github.com/hashicorp/vault-helm
https://developer.hashicorp.com/vault/docs/platform/k8s
https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-raft-deployment-guide


### Install Helm 3
thor@jump_host ~$ `curl -O https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz`  
thor@jump_host ~$ `sha256sum helm-v3.10.2-linux-amd64.tar.gz > sum.txt` 
thor@jump_host ~$ grep "2315941a13291c277dac9f65e75ead56386440d3907e0540bf157ae70f188347" sum.txt 
```
2315941a13291c277dac9f65e75ead56386440d3907e0540bf157ae70f188347  helm-v3.10.2-linux-amd64.tar.gz
```
thor@jump_host ~$ `gunzip -c helm-v3.10.2-linux-amd64.tar.gz |tar xvf -`
thor@jump_host ~$ `sudo cp linux-amd64/helm /usr/local/bin`

### Install and configure chartmuseum
thor@jump_host ~$ `curl -sL -o h.sh https://raw.githubusercontent.com/helm/chartmuseum/main/scripts/get-chartmuseum`. 
thor@jump_host ~$ `sudo yum install openssl`. 
thor@jump_host ~$ `bash h.sh`. 
thor@jump_host ~$ `chartmuseum --debug --port=8090 \
  --storage="local" \
  --storage-local-rootdir="./chartstorage"`  
  
### Create and add chart to chartmuseum
thor@jump_host ~$ `helm create mysql-server`
```
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/thor/.kube/config
Creating mysql-server
```
thor@jump_host ~/mysql-server$ `cat templates/service.yaml`
```
apiVersion: v1
kind: Service
metadata:
  name: {{ include "mysql-server.fullname" . }}
  labels:
    {{- include "mysql-server.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.target_port }}
      protocol: TCP
      name: {{ .Values.service.name }}
   {{- if eq .Values.service.type "NodePort" }}
      nodePort: {{ .Values.service.node_port }}
   {{- end }}
  selector:
    {{- include "mysql-server.selectorLabels" . | nindent 4 }}
```

thor@jump_host ~/mysql-server$ 

thor@jump_host ~/mysql-server$ `cat templates/pv.yaml`
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ .Values.persistent_volume.name }}
  labels:
    type: local
spec:
  storageClassName: {{ .Values.persistent_volume.storage_class_name | default manual }}
  capacity:
    storage: {{ .Values.persistent_volume.size | default 250Mi }}
  accessModes:
    - {{ .Values.persisten_volume.access_mode | default ReadWriteOnce }}
  hostPath:
    path: "{{ .Values.persistent_volume.path }}"
```

thor@jump_host ~/mysql-server$ `cat templates/pvc.yaml`
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Values.persistent_volume.claim_name }}
spec:
  storageClassName: {{ .Values.persistent_volume.storage_classname | default manual }}
  accessModes:
    - {{ .Values.persistent_volume.access_mode | default ReadWriteOnce }}
  resources:
    requests:
      storage: {{ .Values.persistent_volume.claim_size | default 250Mi}}
```
thor@jump_host ~/mysql-server$ 

thor@jump_host ~/mysql-server$ `cat templates/deployment.yaml`
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "mysql-server.fullname" . }}
  labels:
    {{- include "mysql-server.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "mysql-server.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "mysql-server.selectorLabels" . | nindent 8 }}
    spec:
      volumes:
      - name: {{ .Values.persistent_volume.volume_name }} 
        persistentVolumeClaim:
          claimName: {{ .Values.persistent_volume.claim_name }}
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "mysql-server.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
      
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
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
          volumeMounts:
          - name: {{ .Values.persistent_volume.claim_name }}
            mountPath: {{ .Values.persistent_volume.mount_path }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: {{ .Values.service.port_name }}
              containerPort: {{ .Values.service.port }}
              protocol: TCP
              targetPort: {{ .Values.service.target_port }}
          livenessProbe:
            httpGet:
              path:
              port: http
          readinessProbe:
            httpGet:
              path: /
              port: http
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```
thor@jump_host ~/mysql-server$ 

thor@jump_host ~/mysql-server$ `cat values.yaml`
```
# Default values for mysql-server.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
persistent_volume:
  name: mysql-pv
  size: 250Mi
  claim_name: mysql-pv-claim
  claim_size: 250Mi

replicaCount: 1

image:
  repository: mysql
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""

imagePullSecrets: []
nameOverride: ""
fullnameOverride: "mysql-deployment"

serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # Annotations to add to the service account
  annotations: {}
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: ""

podAnnotations: {}

podSecurityContext: {}
  # fsGroup: 2000

securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  # runAsNonRoot: true
  # runAsUser: 1000

service:
  type: NodePort
  port: 3306
  port_name: mysql
  target_port: 3306
  node_port: 30007
  

ingress:
  enabled: false
  className: ""
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local

resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80

nodeSelector: {}

tolerations: []

affinity: {}

```
thor@jump_host ~/mysql-server$ `helm package .`
curl --data-binary"@mysql-server-0.1.0.tgz" http://localhost:8090/api/charts
helm repo update
helm search repo chartmuseum
helm install mysql-deployment chartmuseum/mysql-server
helm list

