resource "kubernetes_namespace" "ingress-basic" {
  metadata {
    annotations = {
      name = "ingress-basic"
    }

    name = "ingress-basic"
  }
}

resource "helm_release" "nginx" {
  name       = "nginx"
  chart      = "stable/nginx-ingress"
  namespace = "ingress-basic"

  set {
    name  = "controller.replicaCount"
    value = 2
  }

  set {
    name  = "NodeSelector.\"beta.kubernetes.io/os\""
    value = "linux"
  } 
  
  depends_on =["null_resource.delay"]
}

data "kubernetes_service" "ingress" {
  metadata {
    namespace ="${kubernetes_namespace.ingress-basic.metadata.0.name}"
    name = "${helm_release.nginx.name}-nginx-ingress-controller"
  }
}

resource "azurerm_dns_a_record" "ingressDNS" {
  name                = "aksdeploy"
  zone_name           = "samcogan.com"
  resource_group_name = "samcogancore"
  ttl                 = 300
  records             = ["${data.kubernetes_service.ingress.load_balancer_ingress.0.ip}"]
}

resource "azurerm_network_security_group" "kuberntes_nsg" {
  name                = "kubernetesNSG"
  location            = "${azurerm_resource_group.aksDeploymentTesting.location}"
  resource_group_name = "${azurerm_resource_group.aksDeploymentTesting.name}"
}


resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = "${azurerm_kubernetes_cluster.test.agent_pool_profile.0.vnet_subnet_id}"
  network_security_group_id = "${azurerm_network_security_group.kuberntes_nsg.id}"
}