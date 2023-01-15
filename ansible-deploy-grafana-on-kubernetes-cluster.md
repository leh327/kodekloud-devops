### reference: 
* https://www.ansible.com/blog/automating-helm-using-ansible
* https://docs.ansible.com/ansible/latest/collections/kubernetes/core/helm_module.html

root@jump_host ~# `yum install -y yum-utils`  
root@jump_host ~# `yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo`  
root@jump_host ~# `yum -y install terraform ansible python3 python3-pip openssl git gcc-c++ libatomic`  
root@jump_host ~# `pip3 install --upgrade pip`
root@jump_host ~# `pip3 install openshift pyhelm`
root@jump_host ~# `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash`
thor@jump_host ~$ `ansible-galaxy collection install kubernetes.core`
```
Process install dependency map
Starting collection install process
Installing 'kubernetes.core:2.3.2' to '/home/thor/.ansible/collections/ansible_collections/kubernetes/core'
```
thor@jump_host ~$ `tee helm.yaml <<EOF`
```
- hosts: localhost
  become: no
  gather_facts: no
  tasks:
  - name: Install helm chart from a git repo
    helm:
      host: localhost
      chart:
        source:
          type: git
          #location: https://github.com/grafana/helm-charts.git
          location: https://github.com/grafana/helm-charts/tree/main/charts/grafana
      state: present
      name: grafana-deployment-devops
      namespace: default
```
thor@jump_host ~$ ansible-playbook helm.yaml -e 'ansible_python_interpreter=/usr/bin/python3'
