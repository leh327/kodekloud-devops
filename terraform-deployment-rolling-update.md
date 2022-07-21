## Problem
```
We have an application running on Kubernetes cluster using nginx web server.
The Nautilus application development team has pushed some of the latest changes and those changes need be deployed.
The Nautilus DevOps team has created an image nginx:1.18 with the latest changes.

Perform a rolling update for this application and incorporate nginx:1.18 image. The deployment name is nginx-deployment
Make sure all pods are up and running after the update.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
```
## Solution
* Install terraform on jump host via yum
```
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
```

* Terraform binary can be used without installation
```
sudo yum -y install wget unzip
wget https://releases.hashicorp.com/terraform/1.1.5/terraform_1.1.5_linux_amd64.zip
unzip terraform_1.1.5_linux_amd64.zip
sudo mv terraform /usr/local/bin
sudo chmod a+x /usr/local/bin/terraform
terraform version
terraform init
terraform plan
```

* Create terraform configuration file to import state of deployment - use kubernetes provider
```
cat >main.tf<<EOF
provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment_v1" "nginx-deployment" {
}
EOF

thor@jump_host ~$ ./terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/kubernetes...
- Installing hashicorp/kubernetes v2.12.1...
- Installed hashicorp/kubernetes v2.12.1 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.


thor@jump_host ~$ ./terraform import kubernetes_deployment_v1.nginx-deployment default/nginx-deployment
kubernetes_deployment_v1.nginx-deployment: Importing from ID "default/nginx-deployment"...
kubernetes_deployment_v1.nginx-deployment: Import prepared!
  Prepared kubernetes_deployment_v1 for import
kubernetes_deployment_v1.nginx-deployment: Refreshing state... [id=default/nginx-deployment]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

thor@jump_host ~$ ./terraform state list
kubernetes_deployment_v1.nginx-deployment


thor@jump_host ~$ ./terraform fmt -no-color
thor@jump_host ~$ cat >main.tf<<EOF
provider "kubernetes" {
  config_path = "~/.kube/config"
}
EOF

thor@jump_host ~$ ./terraform show -no-color >> nginx.tf
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


thor@jump_host ~$ ./terraform apply

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

kubernetes_deployment_v1.nginx-deployment: Modifying... [id=default/nginx-deployment]
kubernetes_deployment_v1.nginx-deployment: Still modifying... [id=default/nginx-deployment, 10s elapsed]
kubernetes_deployment_v1.nginx-deployment: Still modifying... [id=default/nginx-deployment, 20s elapsed]
kubernetes_deployment_v1.nginx-deployment: Modifications complete after 26s [id=default/nginx-deployment]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.


thor@jump_host ~$ kubectl get all
NAME                                    READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-5c7d47c867-bkrjs   1/1     Running   0          65s
pod/nginx-deployment-5c7d47c867-kjlrp   1/1     Running   0          79s
pod/nginx-deployment-5c7d47c867-q54bz   1/1     Running   0          62s

NAME                    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes      ClusterIP   10.96.0.1      <none>        443/TCP        156m
service/nginx-service   NodePort    10.96.60.189   <none>        80:30008/TCP   38m

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deployment   3/3     3            3           38m

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deployment-5c7d47c867   3         3         3       79s
replicaset.apps/nginx-deployment-74fb588559   0         0         0       38m


thor@jump_host ~$ kubectl describe deployment nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Thu, 21 Jul 2022 18:37:19 +0000
Labels:                 app=nginx-app
                        type=front-end
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               app=nginx-app
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx-app
  Containers:
   nginx-container:
    Image:        nginx:1.18
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-5c7d47c867 (3/3 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  38m   deployment-controller  Scaled up replica set nginx-deployment-74fb588559 to 3
  Normal  ScalingReplicaSet  87s   deployment-controller  Scaled up replica set nginx-deployment-5c7d47c867 to 1
  Normal  ScalingReplicaSet  73s   deployment-controller  Scaled down replica set nginx-deployment-74fb588559 to 2
  Normal  ScalingReplicaSet  73s   deployment-controller  Scaled up replica set nginx-deployment-5c7d47c867 to 2
  Normal  ScalingReplicaSet  70s   deployment-controller  Scaled down replica set nginx-deployment-74fb588559 to 1
  Normal  ScalingReplicaSet  70s   deployment-controller  Scaled up replica set nginx-deployment-5c7d47c867 to 3
  Normal  ScalingReplicaSet  67s   deployment-controller  Scaled down replica set nginx-deployment-74fb588559 to 0
thor@jump_host ~$ 
```

