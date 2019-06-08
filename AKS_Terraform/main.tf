resource "azurerm_resource_group" "aksDeploymentTesting" {
  name     = "AKSDeploymentTesting"
  location = "West Europe"

}

resource "random_string" "password" {
  length           = 32
  special          = true
  override_special = "/@\" "
}

locals {
  spPassword = "${random_string.password.result}"

}

resource "azuread_application" "aksDeploymentTesting" {
  name                       = "aksDeploymentTesting"
  homepage                   = "https://aksDeploymentTesting.samcogan.com"
  identifier_uris            = ["https://aksDeploymentTesting.samcogan.com"]
  reply_urls                 = ["https://aksDeploymentTesting.samcogan.com"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "aksDeploymentTesting" {
  application_id = "${azuread_application.aksDeploymentTesting.application_id}"
}

resource "azuread_service_principal_password" "test" {
  service_principal_id = "${azuread_service_principal.aksDeploymentTesting.id}"
  value                = "${local.spPassword}"
  end_date_relative    = "8760h"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "aksDeploymentTesting"
  location            = "${azurerm_resource_group.aksDeploymentTesting.location}"
  resource_group_name = "${azurerm_resource_group.aksDeploymentTesting.name}"
  dns_prefix          = "aksDeploymentTesting"

  agent_pool_profile {
    name            = "default"
    count           = 2
    vm_size         = "Standard_D2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${azuread_application.aksDeploymentTesting.application_id}"
    client_secret = "${local.spPassword}"
  }

  tags = {
    Environment = "Development"
  }
}

resource "local_file" "kube_config" {
  # kube config
  filename = "${var.K8S_KUBE_CONFIG}"
  content  = "${azurerm_kubernetes_cluster.test.kube_config_raw}"
}


resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
  depends_on = ["local_file.kube_config"]

}

resource "kubernetes_cluster_role_binding" "tiller" {
    metadata {
        name = "tiller"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
        kind = "ServiceAccount"
        name = "tiller"
        namespace = "kube-system"
    }
  depends_on = ["local_file.kube_config"]

}
resource "null_resource" "helm_init" {
  provisioner "local-exec" {
    command = "helm init"
    environment = {
      KUBECONFIG = "${var.K8S_KUBE_CONFIG}"

    }
  }
  depends_on = ["kubernetes_cluster_role_binding.tiller"]
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 15"
  }
  triggers = {
    before = "${null_resource.helm_init.id}"
  }
}