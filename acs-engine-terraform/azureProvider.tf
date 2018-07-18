provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  tenant_id       = "${var.tenant_id}"
  client_id       = "${var.deployment_client_ID}"
  client_secret   = "${var.deployment_client_password}"
}
