thor@jump_host ~$ `kubectl create ns elastic-stack`  
```
namespace/elastic-stack created
```
thor@jump_host ~$ `cat <<EOF | kubectl apply -f -`
```
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: app
  name: app
  namespace: elastic-stack
spec:
  containers:
  - image: kodekloud/event-simulator
    name: app
    volumeMounts:
    - mountPath: /log
      name: log-volume
  - image: kodekloud/filebeat-configured
    name: sidecar
    volumeMounts:
    - mountPath: /var/log/event-simulator/
      name: log-volume
  volumes:
  - hostPath:
      path: /var/log/webapp
      type: DirectoryOrCreate
    name: log-volume
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: elastic-search
  name: elastic-search
  namespace: elastic-stack
spec:
  containers:
  - env:
    - name: discovery.type
      value: single-node
    image: docker.elastic.co/elasticsearch/elasticsearch:6.4.2
    name: elastic-search
    ports:
    - containerPort: 9200
      protocol: TCP
    - containerPort: 9300
      protocol: TCP
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: kibana
  name: kibana
  namespace: elastic-stack
spec:
  containers:
  - env:
    - name: ELASTICSEARCH_URL
      value: http://elasticsearch:9200
    image: kibana:6.4.2
    name: kibana
    ports:
    - containerPort: 5601
      protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
  namespace: elastic-stack
spec:
  ports:
  - name: port1
    nodePort: 30200
    port: 9200
    protocol: TCP
    targetPort: 9200
  - name: port2
    nodePort: 30300
    port: 9300
    protocol: TCP
    targetPort: 9300
  selector:
    name: elastic-search
  sessionAffinity: None
  type: NodePort
---
apiVersion: v1
kind: Service
metadata:
  name: kibana
  namespace: elastic-stack
spec:
  ports:
  - nodePort: 30601
    port: 5601
    protocol: TCP
    targetPort: 5601
  selector:
    name: kibana
  sessionAffinity: None
  type: NodePort
EOF
```

thor@jump_host ~$ `cat <<EOF | kubectl apply -f -`
```
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: fluent-ui
  name: fluent-ui
  namespace: default
spec:
  containers:
  - image: kodekloud/fluent-ui-running
    imagePullPolicy: Always
    name: fluent-ui
    ports:
    - containerPort: 80
      protocol: TCP
    - containerPort: 24224
      protocol: TCP
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: default
data:
  td-agent.conf: |
    <match td.*.*>
      @type tdlog
      apikey YOUR_API_KEY

      auto_create_table
      buffer_type file
      buffer_path /var/log/td-agent/buffer/td

      <secondary>
        @type file
        path /var/log/td-agent/failed_records
      </secondary>
    </match>

    <match debug.**>
      @type stdout
    </match>

    <match log.*.*>
      @type stdout
    </match>

    <source>
      @type forward
    </source>

    <source>
      @type http
      port 8888
    </source>

    <source>
      @type debug_agent
      bind 127.0.0.1
      port 24230
    </source>
---

apiVersion: v1
kind: Service
metadata:
  name: fluent-ui-service
  namespace: default
spec:
  ports:
  - name: ui
    nodePort: 30080
    port: 80
    protocol: TCP
    targetPort: 80
  - name: receiver
    nodePort: 30224
    port: 24224
    protocol: TCP
    targetPort: 24224
  selector:
    name: fluent-ui
  type: NodePort
EOF
```
