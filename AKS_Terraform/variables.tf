variable "K8S_KUBE_CONFIG" {
  description = "Path to Kube Config File"
  default ="kubeconfig"
}


variable "K8S_HELM_HOME" {
  description = "Path to Helm Home Directory"
  default ="./helm"
}