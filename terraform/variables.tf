variable "namespace" {
  default = "webns"
  type = string
}
variable "deploymentname" {
  default = "apache"
  type = string
}
variable "imagename" {
  default = "httpd:latest"
  type = string
}
variable "containername" {
  default = "apache-container"
  type = string
}
variable "podname" {
  default = "apache-pod"
  type = string
}
variable "replicacount" {
  default = 1
  type = number
}
variable "servicename" {
  default = "apache-svc"
  type = string
}
variable "nodeport" {
  default = 30008
  type = number
}
