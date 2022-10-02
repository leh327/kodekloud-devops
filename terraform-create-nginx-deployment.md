# Assignment
The Nautilus DevOps team has started practicing some pods, and services deployment on Kubernetes platform, as they are planning to migrate most of their applications on Kubernetes. Recently one of the team members has been assigned a task to create a deploymnt as per details mentioned below:

Create a deployment named nginx to deploy the application nginx using the image nginx:latest (remember to mention the tag as well)

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

# Solution
root@jump_host ~# `yum install -y yum-utils`  
root@jump_host ~# `yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo`  
root@jump_host ~# `yum -y install terraform`  
hor@jump_host ~$ `cat >main.tf<<EOF`
```
provider "kubernetes" {
  config_path = "~/.kube/config"
}
EOF
```
thor@jump_host ~$ `cat >nginx-deployment.tf<<EOF`
```
# kubernetes_deployment_v1.nginx:
resource "kubernetes_deployment_v1" "nginx" {

    metadata {
        annotations      = {}
        labels           = {
            "app" = "nginx"
        }
        name             = "nginx"
        namespace        = "default"
    }

    spec {
        min_ready_seconds         = 0
        paused                    = false
        progress_deadline_seconds = 600
        replicas                  = "1"
        revision_history_limit    = 10

        selector {
            match_labels = {
                "app" = "nginx"
            }
        }

        strategy {
            type = "RollingUpdate"

            rolling_update {
                max_surge       = "25%"
                max_unavailable = "25%"
            }
        }

        template {
            metadata {
                annotations = {}
                labels      = {
                    "app" = "nginx"
                }
            }

            spec {

                container {
                    args                       = []
                    command                    = []
                    image                      = "nginx:latest"
                    image_pull_policy          = "Always"
                    name                       = "nginx"
                    stdin                      = false
                    stdin_once                 = false
                    termination_message_path   = "/dev/termination-log"
                    termination_message_policy = "File"
                    tty                        = false

                    resources {}
                }
            }
        }
    }

}
EOF            
```
thor@jump_host ~$ `terraform init`  
thor@jump_host ~$ `terraform plan`  
thor@jump_host ~$ `terraform apply -auto-approve` 

## Script to generate the above terraform resource
```
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
kubectl create deployment nginx --image=nginx:latest
kubectl wait --for=condition=ready pod --selector=app=nginx

cat >main.tf<<EOF

provider "kubernetes" {
  config_path = "~/.kube/config"
}
EOF

cat >nginx-deployment.tf<<EOF

# kubernetes_deployment_v1.nginx:
resource "kubernetes_deployment_v1" "nginx" {
}
EOF
terraform init
terraform import kubernetes_deployment_v1.nginx default/nginx
terraform show -no-color > nginx-deployment.tf 
mv nginx-deployment.tf nginx.tf
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
mv nginx.tf nginx-deployment.tf
```
