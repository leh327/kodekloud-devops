# Assignment


# Solution
root@jump_host ~# yum install -y yum-utils
root@jump_host ~# yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
root@jump_host ~# yum -y install terraform

thor@jump_host ~$ `cat >>main.tf<<EOF`
```
provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment_v1" "ic-deploy-datacenter" {
}
EOF
```                                     
thor@jump_host ~$ `terraform import kubernetes_deployment_v1.ic-deploy-datacenter default/ic-deploy-datacenter`
```
kubernetes_deployment_v1.ic-deploy-datacenter: Importing from ID "default/ic-deploy-datacenter"...
kubernetes_deployment_v1.ic-deploy-datacenter: Import prepared!
  Prepared kubernetes_deployment_v1 for import
kubernetes_deployment_v1.ic-deploy-datacenter: Refreshing state... [id=default/ic-deploy-datacenter]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```
thor@jump_host ~$ `terraform show > ic-deploy-datacenter.tf`  
## comment out the ic-deploy-datacenter resource from main.tf
thor@jump_host ~$ `sed '/^resource.*$/{s/^/#/;n;s/^/#/}' -i main.tf`  
thor@jump_host ~$ `cat main.tf`
```
provider "kubernetes" {
  config_path = "~/.kube/config"
}

#resource "kubernetes_deployment_v1" "ic-deploy-datacenter" {
#}
```
## Remove parameters from ic-deploy-datacenter.tf before apply it
thor@jump_host ~$ `thor@jump_host ~$ terraform show -no-color > ic-deploy-datacenter.tf`  
thor@jump_host ~$ `cat>>replace.sed<<EOF`
```
sed -i '/ id =/d' ic-deploy-datacenter.tf
sed -i '/ generation /d' ic-deploy-datacenter.tf
sed -i '/ resource_version = /d' ic-deploy-datacenter.tf
sed -i '/ uid /d' ic-deploy-datacenter.tf
sed -i '/ timeouts /d' ic-deploy-datacenter.tf
sed -i '/ node_selector /d' ic-deploy-datacenter.tf
sed -i '/ active_deadline_seconds/d' ic-deploy-datacenter.tf
sed -i '/ automount_service_account_token/d' ic-deploy-datacenter.tf
sed -i '/ dns_policy/d' ic-deploy-datacenter.tf
sed -i '/ enable_service_links/d' ic-deploy-datacenter.tf
sed -i '/ host_ipc/d' ic-deploy-datacenter.tf
sed -i '/ host_network/d' ic-deploy-datacenter.tf
sed -i '/ host_pid/d' ic-deploy-datacenter.tf
sed -i '/ node_selector/d' ic-deploy-datacenter.tf
sed -i '/ restart_policy/d' ic-deploy-datacenter.tf
sed -i '/ share_process_namespace/d' ic-deploy-datacenter.tf
sed -i '/ termination_grace_period_seconds/d' ic-deploy-datacenter.tf
EOF
```
thor@jump_host ~$ `bash -x replace.sed`  
thor@jump_host ~$ `terraform apply`
```
...
...
kubernetes_deployment_v1.ic-deploy-datacenter: Modifying... [id=default/ic-deploy-datacenter]
kubernetes_deployment_v1.ic-deploy-datacenter: Modifications complete after 4s [id=default/ic-deploy-datacenter]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```
thor@jump_host ~$ `kubectl get deployment`
```
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
ic-deploy-datacenter   1/1     1            1           43m
```
thor@jump_host ~$ `kubectl get pod`
```
NAME                                    READY   STATUS        RESTARTS   AGE
ic-deploy-datacenter-66c5895c6b-xx9nw   1/1     Terminating   0          43m
ic-deploy-datacenter-7ccb7df89d-hb8jt   1/1     Running       0          19s
```
thor@jump_host ~$ 
