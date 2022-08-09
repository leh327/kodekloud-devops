https://helm.sh/docs/intro/install/  
thor@jump_host ~$ `curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3`  
thor@jump_host ~$ `chmod 700 get_helm.sh`  
thor@jump_host ~$ `sudo yum install openssl -y`  
thor@jump_host ~$ `./get_helm.sh`  
thor@jump_host ~$ `chmod g= .kube/config`  
thor@jump_host ~$ `helm create jenkins`  

thor@jump_host ~$ `cat > jenkins/values.yaml<<EOF`  
```
# Default values for jenkins.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

replicaCount: 1

image:
  repository: jenkins/jenkins
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""

service:
  type: NodePort
  port: 8080
  nodePort: 30008
EOF
```

thor@jump_host ~$ `cat >jenkins/templates/service.yaml<<EOF` 
```
apiVersion: v1
kind: Service
metadata:
  name: {{ include "jenkins.fullname" . }}
  labels:
    {{- include "jenkins.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.port }}
      nodePort: {{ .Values.service.nodePort }}
      protocol: TCP
  selector:
    {{- include "jenkins.selectorLabels" . | nindent 4 }}
EOF
```

thor@jump_host ~$ `cat >jenkins/Chart.yaml<<EOF`
```
apiVersion: v2
name: jenkins
description: A Helm chart for Kubernetes

# A chart can be either an 'application' or a 'library' chart.
#
# Application charts are a collection of templates that can be packaged into versioned archives
# to be deployed.
#
# Library charts provide useful utilities or functions for the chart developer. They're included as
# a dependency of application charts to inject those utilities and functions into the rendering
# pipeline. Library charts do not define any templates and therefore cannot be deployed.
type: application

# This is the chart version. This version number should be incremented each time you make changes
# to the chart and its templates, including the app version.
# Versions are expected to follow Semantic Versioning (https://semver.org/)
version: 0.1.0

# This is the version number of the application being deployed. This version number should be
# incremented each time you make changes to the application. Versions are not expected to
# follow Semantic Versioning. They should reflect the version the application is using.
# It is recommended to use it with quotes.
appVersion: "latest"
EOF
```

thor@jump_host ~$ `cat >jenkins/templates/_helpers.tpl<<EOF`
```
{{/*
Expand the name of the chart.
*/}}
{{- define "jenkins.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "jenkins.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- \$name := default .Chart.Name .Values.nameOverride }}
{{- if contains \$name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name \$name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "jenkins.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "jenkins.labels" -}}
helm.sh/chart: {{ include "jenkins.chart" . }}
{{ include "jenkins.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app: {{ "jenkins" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "jenkins.selectorLabels" -}}
app.kubernetes.io/name: {{ include "jenkins.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ "jenkins" }}
{{- end }}
EOF
```

thor@jump_host ~$ `cat >jenkins/templates/deployment.yaml<<EOF`
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "jenkins.fullname" . }}
  labels:
    {{- include "jenkins.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "jenkins.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "jenkins.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
EOF
```

thor@jump_host ~$ `helm install --create-namespace --namespace jenkins jenkins-deployment jenkins`  

thor@jump_host ~$ `kubectl logs pod/jenkins-deployment-758c65f9bc-7mlgx -n jenkins |grep password -A2`
```
Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

37ee14e852d34bc4b53294ac4a521d08
```

thor@jump_host ~$ `curl $(kubectl get pod -n jenkins -o jsonpath='{.items[*].spec.nodeName}'):30008`
```
Authentication required                                     
```
