# Assignment

The Nautilus DevOps team is planning to deploy some micro services on Kubernetes platform.  
The team has already set up a Kubernetes cluster and now they want set up some namespaces, deployments etc.  
Based on the current requirements, the team has shared some details as below:



Create a namespace named dev and create a POD under it; name the pod dev-nginx-pod and use 
nginx image with latest tag only and remember to mention tag i.e nginx:latest.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution

root@jump_host ~# `yum install -y yum-utils`  
root@jump_host ~# `yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo`  
root@jump_host ~# `yum -y install terraform`  

thor@jump_host ~/nginx$ `cat >nginx.tf<<EOF`
```
# kubernetes_namespace_v1.dev:
resource "kubernetes_namespace_v1" "dev" {

    metadata {
        annotations      = {}
        labels           = {}
        name             = "dev"
    }
}

# kubernetes_pod_v1.dev-nginx-pod:
resource "kubernetes_pod_v1" "dev-nginx-pod" {

    metadata {
        annotations      = {}
        labels           = {
            "run" = "dev-nginx-pod"
        }
        name             = "dev-nginx-pod"
        namespace        = "dev"
    }

    spec {
        automount_service_account_token  = false
        dns_policy                       = "ClusterFirst"
        enable_service_links             = true
        host_ipc                         = false
        host_network                     = false
        host_pid                         = false
        node_selector                    = {}
        restart_policy                   = "Always"
        service_account_name             = "default"
        share_process_namespace          = false
        termination_grace_period_seconds = 30

        container {
            args                       = []
            command                    = []
            image                      = "nginx:latest"
            image_pull_policy          = "Always"
            name                       = "dev-nginx-pod"
            stdin                      = false
            stdin_once                 = false
            termination_message_path   = "/dev/termination-log"
            termination_message_policy = "File"
            tty                        = false

            resources {}
        }
    }
}                   
                   
EOF
```
thor@jump_host ~/nginx$ `terraform init`  
thor@jump_host ~/nginx$ `terraform plan`  
thor@jump_host ~/nginx$ `terraform apply -auto-approve`  

thor@jump_host ~/nginx$ `terraform state list`

# How to import an existing pod into configuration file
thor@jump_host ~/nginx$ `cat >main.tf<<EOF`
```
provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace_v1" "dev" {
}

resource "kubernetes_pod_v1" "dev-nginx-pod" {
}
EOF
```

thor@jump_host ~/nginx$ `terraform init`  
thor@jump_host ~/nginx$ `terraform import kubernetes_pod_v1.dev-nginx-pod dev/dev-nginx-pod`  
thor@jump_host ~/nginx$ `terraform import kubernetes_namespace_v1.dev dev`  
thor@jump_host ~/nginx$ `terraform show -no-color > nginx.tf`  
thor@jump_host ~/nginx$ `cat clean-tf.sh`  
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
EOF
```
thor@jump_host ~/nginx$ `bash clean-tf.sh`  
thor@jump_host ~/nginx$ `kubectl delete ns dev`  
thor@jump_host ~/nginx$ `terraform plan`  
thor@jump_host ~/nginx$ `terraform apply -auto-approve`  
