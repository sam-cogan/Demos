#Create Resource Group
resource "azurerm_resource_group" "acsResourceGroup" {
  name     = "${var.rgName}"
  location = "${var.region}"
}

#Assign Contributor Permissions to RG for Service Princial running K8s
resource "azurerm_role_assignment" "assignACSUser" {
  scope                = "${azurerm_resource_group.acsResourceGroup.id}"
  role_definition_name = "Contributor"
  principal_id         = "${var.acsAccountID}"
}

# ACS Engine Config
data "template_file" "acs_engine_config" {
  template = "${file(var.acs_engine_config_file)}"

  vars {
    master_vm_count         = "${var.master_vm_count}"
    dns_prefix              = "${var.dns_prefix}"
    master_vm_size          = "${var.master_vm_size}"
    linux_vm_size           = "${var.linux_vm_size}"
    windows_vm_size         = "${var.windows_vm_size}"
    linux_worker_vm_count   = "${var.linux_worker_vm_count}"
    windows_worker_vm_count = "${var.windows_worker_vm_count}"
    admin_user_name         = "${var.admin_user_name}"
    admin_password          = "${var.admin_password}"
    ssh_key                 = "${var.ssh_key}"
    client_ID               = "${var.client_ID}"
    client_secret           = "${var.client_secret}"
    orchestrator_version    = "${var.orchestrator_version}"
    windows_sku             = "${var.windows_sku}"
  }

  depends_on = ["azurerm_role_assignment.assignACSUser"]
}

# Locally output the rendered ACS Engine Config (after substitution has been performed)
resource "null_resource" "render_acs_engine_config" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.acs_engine_config.rendered}' > ${var.acs_engine_config_file_rendered}"
  }

  depends_on = ["data.template_file.acs_engine_config"]
}

# Locally run the ACS Engine to produce the Azure Resource Template for the K8s cluster
resource "null_resource" "run_acs_engine" {
  provisioner "local-exec" {
    command = "acs-engine generate ${var.acs_engine_config_file_rendered}"
  }

  depends_on = ["null_resource.render_acs_engine_config"]
}

#Locally run the Azure 2.0 CLI to create the resource deployment
resource "null_resource" "deploy_acs" {
  provisioner "local-exec" {
    command = "az group deployment create --name ${var.dns_prefix} --resource-group ${var.rgName} --template-file ./$(find _output -name 'azuredeploy.json') --parameters @./$(find _output -name 'azuredeploy.parameters.json')"
  }

  depends_on = ["null_resource.run_acs_engine"]
}

#Create copy of Kubeconfig
resource "local_file" "kubeconfig" {
  depends_on = ["null_resource.deploy_acs"]

  content  = "${file("_output/${var.dns_prefix}/kubeconfig/kubeconfig.${replace(lower(var.region)," ","")}.json")}"
  filename = "./terraform.tfstate.helmprovider.kubeconfig"
}

#Taint Windows Nodes
resource "null_resource" "taint_windows" {
  provisioner "local-exec" {
    command = "kubectl taint node -l beta.kubernetes.io/os=windows os=windows:NoSchedule --kubeconfig=./terraform.tfstate.helmprovider.kubeconfig"
  }

  depends_on = ["null_resource.deploy_acs"]
}

#Deploy Windows Daemonset
resource "null_resource" "deploy_daemonset" {
  provisioner "local-exec" {
    command = "kubectl create -f WinDaemon.yaml  --kubeconfig=./terraform.tfstate.helmprovider.kubeconfig"
  }

  depends_on = ["null_resource.taint_windows"]
}

#Setup Helm provider
provider "helm" {
  kubernetes {
    config_path = "${local_file.kubeconfig.filename}"
  }
}

#Add Helm Repo for SVC Cat
resource "helm_repository" "svc-cat" {
  name = "svc-cat"
  url  = "https://svc-catalog-charts.storage.googleapis.com"
}

#Add Helm Repo for OSBA
resource "helm_repository" "azure" {
  name = "azure"
  url  = "https://kubernetescharts.blob.core.windows.net/azure"
}

#Deploy SvcCat
resource "helm_release" "catalog" {
  depends_on = ["helm_repository.svc-cat"]
  name       = "catalog"
  chart      = "svc-cat/catalog"
  namespace  = "catalog"

  set {
    name  = "apiserver.storage.etcd.persistence.enabled"
    value = true
  }
}

#Deploy OSBA
resource "helm_release" "osba" {
  depends_on = ["helm_repository.azure"]
  name       = "osba"
  chart      = "azure/open-service-broker-azure"
  namespace  = "osba"

  set {
    name  = "azure.subscriptionId"
    value = "${var.subscription_id}"
  }

  set {
    name  = "azure.tenantId"
    value = "${var.tenant_id}"
  }

  set {
    name  = "azure.clientId"
    value = "${var.deployment_client_ID}"
  }

  set {
    name  = "azure.clientSecret"
    value = "${var.deployment_client_password}"
  }
}

#Deploy Traefik
resource "helm_release" "traefika" {
  depends_on = ["helm_repository.azure"]
  name       = "traefik"
  chart      = "stable/traefik"
  namespace  = "kube-system"

  set {
    name  = "ssl.enabled"
    value = true
  }

  set {
    name  = "ssl.enforced"
    value = false
  }

  set {
    name  = "acme.enabled"
    value = true
  }

  set {
    name  = "acme.challengeType"
    value = "dns-01"
  }

  set {
    name  = "acme.dnsProvider.name"
    value = "azure"
  }

  set {
    name  = "acme.dnsProvider.azure.AZURE_CLIENT_ID"
    value = "${var.DNS_Client_ID}"
  }

  set {
    name  = "acme.dnsProvider.azure.AZURE_CLIENT_SECRET"
    value = "${var.DNS_Client_Password}"
  }

  set {
    name  = "acme.dnsProvider.azure.AZURE_SUBSCRIPTION_ID"
    value = "${var.subscription_id}"
  }

  set {
    name  = "acme.dnsProvider.azure.AZURE_TENANT_ID"
    value = "${var.tenant_id}"
  }

  set {
    name  = "acme.dnsProvider.azure.AZURE_RESOURCE_GROUP"
    value = "${var.DNS_Resource_Group}"
  }

  set {
    name  = "acme.dnsProvider.email"
    value = "${var.DNS_Email}"
  }

  set {
    name  = "acme.dnsProvider.staging"
    value = "${var.DNS_Staging}"
  }

  set {
    name  = "acme.dnsProvider.persistance.enabled"
    value = true
  }

  set {
    name  = "acme.dashboard.enabled"
    value = true
  }

  set {
    name  = "acme.dashboard.domain"
    value = "${var.Traefik_Dashboard_URL}"
  }

  set {
    name  = "acme.dashboard.auth.basic.admin"
    value = "${var.Traefik_Dashboard_Password}"
  }

  set {
    name  = "rbac.enabled"
    value = "${var.Traefik_RBAC_Enabled}"
  }

  set {
    name  = "acme.nodeSelector.beta.kubernetes.io/os"
    value = "linux"
  }
}
