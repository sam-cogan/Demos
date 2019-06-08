

provider "kubernetes" {
  config_path = "${var.K8S_KUBE_CONFIG}"
}

provider "helm" {
  debug = true
  kubernetes {
    config_path = "${var.K8S_KUBE_CONFIG}"
  }
}