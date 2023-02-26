provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace_v1" "httpd-namespace-xfusion" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment_v1" "httpd-deployment-xfusion" {
  metadata {
    namespace = var.namespace
    name      = var.deploymentname
    labels = {
      app = var.podname
    }
  }

  spec {
    replicas = var.replicacount
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge = "25%"
        max_unavailable = "25%"
      }
    }
    selector {
      match_labels = {
        app = var.podname
      }
    }
    template {
      metadata {
        name = var.containername
        namespace = var.namespace
        labels = {
          app = var.podname
        }
      }
      spec {
        container {
          image = var.imagename
          name = var.containername
        }
      }
    }

  }
}

resource "kubernetes_service_v1" "httpd-service-xfusion" {
  metadata {
    namespace = var.namespace
    name      = var.servicename
  }

  spec {
    selector = {
      app = var.podname
    }
    port {
      port        = 80
      target_port = 80
      node_port   = var.nodeport
    }

    type = "NodePort"
  }
}
