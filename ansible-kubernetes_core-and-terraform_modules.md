# Assignment
The datacenter DevOps team is working on a Kubernetes template to deploy a web application on the cluster.
There are some requirements to create/use persistent volumes to store the application code, and the
template needs to be designed accordingly. Please find more details below:



Create a PersistentVolume named as pv-datacenter. Configure the spec as storage class should be manual,
set capacity to 4Gi, set access mode to ReadWriteOnce, volume type should be hostPath and set path to
/mnt/security (this directory is already created, you might not be able to access it directly,
so you need not to worry about it).

Create a PersistentVolumeClaim named as pvc-datacenter. Configure the spec as storage class should be manual,
request 3Gi of the storage, set access mode to ReadWriteOnce.

Create a pod named as pod-datacenter, mount the persistent volume you created with claim name
pvc-datacenter at document root of the web server, the container within the pod should be named as
container-datacenter using image nginx with latest tag only (remember to mention the tag i.e nginx:latest).

Create a node port type service named web-datacenter using node port 30008 to expose the web server running within the pod.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
root@jump_host ~# `cat .bash_history`
```
yum -y install ansible kubernetes-client python3 python3-pip git unzip
pip3 install --upgrade pip
pip3 install openshift pyHelm
```

thor@jump_host ~$ `ansible-galaxy collection install kubernetes.core`
```
Process install dependency map
Starting collection install process
Installing 'kubernetes.core:2.3.2' to '/home/thor/.ansible/collections/ansible_collections/kubernetes/core'
```

thor@jump_host ~$ `tee ansible.cfg<<EOF`
```
[defaults]
collections_path = .ansible/collections
EOF
```
thor@jump_host ~$ `tee pod_with_pv.yaml<<EOF`
```
---
- hosts: localhost
  gather_facts: no
  tasks:
  - kubernetes.core.k8s:
      state: present
      definition:
        apiVersion: v1
        kind: PersistentVolume
        metadata:
          name: pv-datacenter
        spec:
          capacity:
            storage: 4Gi
          accessModes:
          - ReadWriteOnce
          storageClassName: manual
          hostPath:
            path: /mnt/security
  - kubernetes.core.k8s:
      state: present
      definition:
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: pvc-datacenter
          namespace: default
        spec:
          resources:
            requests:
              storage: 3Gi
          accessModes:
          - ReadWriteOnce
          storageClassName: manual
  - kubernetes.core.k8s:
      state: present
      definition:
        apiVersion: v1
        kind: Pod
        metadata:
          name: pod-datacenter
          labels:
            app: nginx
          namespace: default
        spec:
          volumes:
          - name: datacenter-volume
            persistentVolumeClaim:
              claimName: pvc-datacenter
          containers:
          - name: container-datacenter
            image: nginx:latest
            volumeMounts:
            - name: datacenter-volume
              mountPath: /usr/share/nginx/html

  - kubernetes.core.k8s:
      state: present
      definition:
        apiVersion: v1
        kind: Service
        metadata:
          labels:
            name: web-datacenter-svc
          name: web-datacenter
          namespace: default
        spec:
          selector:
            app: nginx
          type: NodePort
          ports:
          - port: 80
            targetPort: 80
            nodePort: 30008
EOF
```
thor@jump_host ~$ `ansible-playbook pv.yaml -e 'ansible_python_interpreter=/usr/bin/python3'`


# k8s helm module
thor@jump_host ~$ `curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3`  
thor@jump_host ~$ `chmod 700 get_helm.sh`  
thor@jump_host ~$ `./get_helm.sh`  
thor@jump_host ~$ `tee values_override.yaml<<EOF`
```
# Default values for datacenter.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

volumes:
  name: datacenter-volume
  pvcName: pvc-datacenter
  pvName: pv-datacenter
  pvSize: 4Gi
  pvcRequestSize: 3Gi
  mountPath: /usr/share/nginx/html
  hostPath: /mnt/security

Pod:
  name: pod-datacenter

image:
  repository: nginx
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: "latest"

nameOverride: "pod-datacenter"
fullnameOverride: ""

service:
  type: NodePort
  port: 80
  nodePort: 30008
EOF
```

thor@jump_host ~$ `helm create datacenter`  
thor@jump_host ~$ `rm datacenter/templates/*.yaml`  
thor@jump_host ~/datacenter/templates$ `tee pod.yaml <<EOF`
```
apiVersion: v1
kind: Pod
metadata:
  name: {{ .Values.Pod.name }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "datacenter.labels" . | nindent 4 }}
spec:
    spec:
      volumes:
      - name: {{ .Values.volumes.name }}
        persistentVolumeClaim:
          claimName: {{ .Values.volumes.pvcName }}
      containers:
        - name: {{ .Values.nameOverride }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          ports:
            - name: http
              containerPort: {{ .Values.service.port }}
              protocol: TCP
          volumeMounts:
          - name: {{ .Values.volumes.name }}
            mountPath: {{ .Values.volumes.mountPath }}
EOF
```

thor@jump_host ~/datacenter/templates$ `tee pv.yaml <EOF`
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ .Values.volumes.pvName }}
spec:
  capacity:
    storage: {{ .Values.volumes.pvSize }}
  accessModes:
  - ReadWriteOnce
  storageClassName: manual
  hostPath:
    path: {{ .Values.volumes.hostPath }}
EOF
```

thor@jump_host ~/datacenter/templates$ `tee pvc.yaml <<EOF`
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Values.volumes.pvcName }}
  namespace: {{ .Release.Namespace }}
spec:
  resources:
    requests:
      storage: {{ .Values.volumes.pvcRequestSize }}
  accessModes:
  - ReadWriteOnce
  storageClassName: manual
EOF
```

thor@jump_host ~/datacenter/templates$ `tee service.yaml<<EOF`
```
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "datacenter.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "datacenter.selectorLabels" . | nindent 4 }}
EOF
```
thor@jump_host ~$ `tee datacenter.yaml<<EOF`
```
---
- hosts: localhost
  gather_facts: no
  tasks:
   - name: Deploy chart from local path
     kubernetes.core.helm:
       name: datacenter
       chart_ref: /home/thor/datacenter
       release_namespace: default
       values_files:
        - /home/thor/values-override.yaml
EOF
```
thor@jump_host ~$ `ansible-playbook datacenter.yaml -e 'ansible_python_interpreter=/usr/bin/python3'`

# Terraform module
root@jump_host ~# `cat .bash_history`
```
yum -y install ansible kubernetes-client python3 python3-pip git unzip
pip3 install --upgrade pip
pip3 install openshift pyHelm
```
thor@jump_host ~$ `ansible-galaxy collection install community.general kubernetes.core`  
thor@jump_host ~$ `git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv`  
thor@jump_host ~$ `export PATH=${PATH}:~/.tfenv/bin`  
thor@jump_host ~$ `tfenv install`  
thor@jump_host ~$ `tfenv list`
```
  1.3.7
No default set. Set with 'tfenv use <version>'
```

thor@jump_host ~$ `tfenv use 1.3.7`
```
Switching default version to v1.3.7
Default version (when not overridden by .terraform-version or TFENV_TERRAFORM_VERSION) is now: 1.3.7
```

thor@jump_host ~$ `tfenv list`
```
* 1.3.7 (set by /home/thor/.tfenv/version)
```

thor@jump_host ~$ `tee ansible.cfg<<EOF`
```
[defaults]
collections_path = .ansible/collections
EOF
```

thor@jump_host ~/datacenter$ `tee main.tf <<EOF`
```
provider "kubernetes" {
  config_path = "/home/thor/.kube/config"
}
EOF
```

thor@jump_host ~$ `tee datacenter/nginx.tf <<EOF`
```
# kubernetes_persistent_volume_claim_v1.pvc-datacenter:
resource "kubernetes_persistent_volume_claim_v1" "pvc-datacenter" {
    wait_until_bound = true

    metadata {
        name             = "pvc-datacenter"
        namespace        = "default"
    }

    spec {
        access_modes       = [
            "ReadWriteOnce",
        ]
        storage_class_name = "manual"
        volume_name        = "pv-datacenter"

        resources {
            limits   = {}
            requests = {
                "storage" = "3Gi"
            }
        }
    }

}

# kubernetes_persistent_volume_v1.pv-datacenter:
resource "kubernetes_persistent_volume_v1" "pv-datacenter" {

    metadata {
        name             = "pv-datacenter"
    }

    spec {
        access_modes                     = [
            "ReadWriteOnce",
        ]
        capacity                         = {
            "storage" = "4Gi"
        }
        persistent_volume_reclaim_policy = "Retain"
        storage_class_name               = "manual"
        volume_mode                      = "Filesystem"

        claim_ref {
            name      = "pvc-datacenter"
            namespace = "default"
        }

        persistent_volume_source {

            host_path {
                path = "/mnt/security"
            }
        }
    }

}

# kubernetes_pod_v1.pod-datacenter:
resource "kubernetes_pod_v1" "pod-datacenter" {

    metadata {
        labels           = {
            "app" = "nginx"
        }
        name             = "pod-datacenter"
        namespace        = "default"
    }

    spec {
        container {
            image                      = "nginx:latest"
            name                       = "container-datacenter"

            resources {
                limits   = {}
                requests = {}
            }

            volume_mount {
                mount_path = "/usr/share/nginx/html"
                name       = "datacenter-volume"
                read_only  = false
            }
        }

        volume {
            name = "datacenter-volume"

            persistent_volume_claim {
                claim_name = "pvc-datacenter"
                read_only  = false
            }
        }
    }

}

# kubernetes_service_v1.web-datacenter:
resource "kubernetes_service_v1" "web-datacenter" {

    metadata {
        labels           = {
            "name" = "web-datacenter-svc"
        }
        name             = "web-datacenter"
        namespace        = "default"
    }

    spec {
        selector                          = {
            "app" = "nginx"
        }
        type                              = "NodePort"

        port {
            node_port   = 30008
            port        = 80
            protocol    = "TCP"
            target_port = "80"
        }
    }
}
EOF
```

thor@jump_host ~$ `tee datacenter.yaml<<EOF`
```
---
- hosts: localhost
  gather_facts: no
  tasks:
  - community.general.terraform:
      force_init: true
      state: "{{ state }}"
      project_path: '{{ project_path }}'
EOF
```

thor@jump_host ~$ `ansible-playbook datacenter.yaml -e project_path=/home/thor/datacenter -e state=present -e ansible_python_interpreter=/usr/bin/python3`


# How to generate resources for terraform


# prep script
root@jump_host ~# `tee prep.sh<<EOF`
```
yum -y install ansible kubernetes-client python3 python3-pip git unzip
pip3 install --upgrade pip
pip3 install openshift pyHelm
tee ~thor/ansible.cfg<<EOF
[defaults]
collections_path = .ansible/collections
EOF
chown thor ~thor/ansible.cfg
tee ~thor/datacenter.yml<<EOF
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-datacenter
spec:
  capacity:
    storage: 4Gi
  accessModes:
  - ReadWriteOnce
  storageClassName: manual
  hostPath:
    path: /mnt/secrity
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-datacenter
  namespace: default
spec:
  resources:
    requests:
      storage: 3Gi
  accessModes:
  - ReadWriteOnce
  storageClassName: manual
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-datacenter
  labels:
    app: nginx
  namespace: default
spec:
  volumes:
  - name: datacenter-volume
    persistentVolumeClaim:
      claimName: pvc-datacenter
  containers:
  - name: container-datacenter
    image: nginx:latest
    volumeMounts:
    - name: datacenter-volume
      mountPath: /usr/share/nginx/html
---
apiVersion: v1
kind: Service
metadata:
  labels:
    name: web-datacenter-svc
  name: web-datacenter
  namespace: default
spec:
  selector:
    app: nginx
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30008
EOF

chown thor ~thor/datacenter.yml
tee ~thor/main.tf<<EOF
provider "kubernetes" {
  config_path = "/home/thor/.kube/config"
}

resource "kubernetes_pod_v1" "pod-datacenter" {
}

resource "kubernetes_service_v1" "web-datacenter" {
}

resource "kubernetes_persistentvolume_v1" "pv-datacenter" {
}

resource "kubernetes_persistentvolumeclaim_v1" "pvc-datacenter" {
}
EOF
chown thor ~thor/main.tf
root@jump_host ~# su - thor
```

thor@jump_host ~$ `tee datacenter.yaml<<EOF`
```
---
- hosts: localhost
  gather_facts: no
  tasks:
  - community.general.terraform:
      force_init: true
      state: "{{ state }}"
      project_path: '{{ project_path }}'
EOF
```

thor@jump_host ~$ `tee nginx.tf<<EOF`
```
# kubernetes_persistent_volume_claim_v1.pvc-datacenter:
resource "kubernetes_persistent_volume_claim_v1" "pvc-datacenter" {
    id               = "default/pvc-datacenter"
    wait_until_bound = true

    metadata {
        annotations      = {}
        labels           = {}
        name             = "pvc-datacenter"
        namespace        = "default"
    }

    spec {
        access_modes       = [
            "ReadWriteOnce",
        ]
        storage_class_name = "manual"
        volume_name        = "pv-datacenter"

        resources {
            limits   = {}
            requests = {
                "storage" = "3Gi"
            }
        }
    }

}

# kubernetes_persistent_volume_v1.pv-datacenter:
resource "kubernetes_persistent_volume_v1" "pv-datacenter" {

    metadata {
        annotations      = {}
        labels           = {}
        name             = "pv-datacenter"
    }

    spec {
        access_modes                     = [
            "ReadWriteOnce",
        ]
        capacity                         = {
            "storage" = "4Gi"
        }
        mount_options                    = []
        persistent_volume_reclaim_policy = "Retain"
        storage_class_name               = "manual"
        volume_mode                      = "Filesystem"

        claim_ref {
            name      = "pvc-datacenter"
            namespace = "default"
        }

        persistent_volume_source {

            host_path {
                path = "/mnt/dba"
            }
        }
    }

}

# kubernetes_pod_v1.pod-datacenter:
resource "kubernetes_pod_v1" "pod-datacenter" {

    metadata {
        annotations      = {}
        labels           = {
            "app" = "nginx"
        }
        name             = "pod-datacenter"
        namespace        = "default"
    }

    spec {
        node_name                        = "kodekloud-control-plane"
        service_account_name             = "default"

        container {
            args                       = []
            command                    = []
            image                      = "nginx:latest"
            image_pull_policy          = "Always"
            name                       = "container-datacenter"
            stdin                      = false
            stdin_once                 = false
            termination_message_path   = "/dev/termination-log"
            termination_message_policy = "File"
            tty                        = false

            resources {
                limits   = {}
                requests = {}
            }

            volume_mount {
                mount_path = "/usr/share/nginx/html"
                name       = "datacenter-volume"
                read_only  = false
            }
        }

        volume {
            name = "datacenter-volume"

            persistent_volume_claim {
                claim_name = "pvc-datacenter"
                read_only  = false
            }
        }
    }

}

# kubernetes_service_v1.web-datacenter:
resource "kubernetes_service_v1" "web-datacenter" {
    id     = "default/web-datacenter"
    status = [
        {
            load_balancer = [
                {
                    ingress = []
                },
            ]
        },
    ]

    metadata {
        annotations      = {}
        labels           = {
            "name" = "web-datacenter-svc"
        }
        name             = "web-datacenter"
        namespace        = "default"
    }

    spec {
        allocate_load_balancer_node_ports = true
        cluster_ip                        = "10.96.30.72"
        cluster_ips                       = [
            "10.96.30.72",
        ]
        external_ips                      = []
        external_traffic_policy           = "Cluster"
        health_check_node_port            = 0
        ip_families                       = [
            "IPv4",
        ]
        ip_family_policy                  = "SingleStack"
        load_balancer_source_ranges       = []
        publish_not_ready_addresses       = false
        selector                          = {
            "app" = "nginx"
        }
        session_affinity                  = "None"
        type                              = "NodePort"

        port {
            node_port   = 30008
            port        = 80
            protocol    = "TCP"
            target_port = "80"
        }
    }

}
EOF
```

thor@jump_host ~$ `ansible-playbook datacenter.yaml -e state=present -e project_path=/home/thor/datacenter -e ansible_python_interpreter=/usr/bin/python3`

# clean-tf.sh
thor@jump_host ~/datacenter$ `tee clean-tf.sh<<EOF`
```
sed -i 's/nginx:1.16/nginx:1.18/' nginx.tf
sed -i '/ id =/d' nginx.tf
sed -i '/ generation /d' nginx.tf
sed -i '/ resource_version = /d' nginx.tf
sed -i '/ uid /d' nginx.tf
sed -i '/ timeouts /d' nginx.tf
sed -i '/ node_selector /d' nginx.tf
sed -i '/ active_deadline_seconds/d' nginx.tf
sed -i '/ automount_service_account_token/d' nginx.tf
sed -i '/ dns_policy/d' nginx.tf
sed -i '/ enable_service_links/d' nginx.tf
sed -i '/ host_ipc/d' nginx.tf
sed -i '/ host_network/d' nginx.tf
sed -i '/ host_pid/d' nginx.tf
sed -i '/ node_selector/d' nginx.tf
sed -i '/ restart_policy/d' nginx.tf
sed -i '/ share_process_namespace/d' nginx.tf
sed -i '/ termination_grace_period_seconds/d' nginx.tf
sed -i '/ health_check_node_port
EOF
```

thor@jump_host ~/datacenter$ `terraform init`
```
Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/kubernetes from the dependency lock file
- Using previously-installed hashicorp/kubernetes v2.16.1

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

thor@jump_host ~/datacenter$ `terraform import kubernetes_pod_v1.pod-datacenter default/pod-datacenter`
```
kubernetes_pod_v1.pod-datacenter: Importing from ID "default/pod-datacenter"...
kubernetes_pod_v1.pod-datacenter: Import prepared!
  Prepared kubernetes_pod_v1 for import
kubernetes_pod_v1.pod-datacenter: Refreshing state... [id=default/pod-datacenter]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

thor@jump_host ~/datacenter$ `terraform import kubernetes_persistent_volume_v1.pv-datacenter pv-datacenter`
```
kubernetes_persistent_volume_v1.pv-datacenter: Importing from ID "pv-datacenter"...
kubernetes_persistent_volume_v1.pv-datacenter: Import prepared!
  Prepared kubernetes_persistent_volume_v1 for import
kubernetes_persistent_volume_v1.pv-datacenter: Refreshing state... [id=pv-datacenter]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

thor@jump_host ~/datacenter$ `terraform import kubernetes_persistent_volume_claim_v1.pvc-datacenter default/pvc-datacenter`
```
kubernetes_persistent_volume_claim_v1.pvc-datacenter: Importing from ID "default/pvc-datacenter"...
kubernetes_persistent_volume_claim_v1.pvc-datacenter: Import prepared!
  Prepared kubernetes_persistent_volume_claim_v1 for import
kubernetes_persistent_volume_claim_v1.pvc-datacenter: Refreshing state... [id=default/pvc-datacenter]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

thor@jump_host ~/datacenter$ `terraform import kubernetes_service_v1.web-datacenter default/web-datacenter`
```
kubernetes_service_v1.web-datacenter: Importing from ID "default/web-datacenter"...
kubernetes_service_v1.web-datacenter: Import prepared!
  Prepared kubernetes_service_v1 for import
kubernetes_service_v1.web-datacenter: Refreshing state... [id=default/web-datacenter]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

thor@jump_host ~/datacenter$ `terraform state list`
```
kubernetes_persistent_volume_claim_v1.pvc-datacenter
kubernetes_persistent_volume_v1.pv-datacenter
kubernetes_pod_v1.pod-datacenter
kubernetes_service_v1.web-datacenter
```

thor@jump_host ~/datacenter$ `terraform show -no-color | tee nginx.tf`  
thor@jump_host ~/datacenter$ `bash -x clean-tf.sh`
thor@jump_host ~/datacenter$ `cat nginx.tf`

