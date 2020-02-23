
provider "azurerm" {

}

resource "azurerm_resource_group" "terraform-arm" {
  name     = "terraform-arm"
  location = "West Europe"
}

resource "azurerm_template_deployment" "terraform-arm" {
  name                = "terraform-arm-01"
  resource_group_name = azurerm_resource_group.terraform-arm.name

  template_body = file("template.json")


  parameters = {
    "storageAccountName" = "terraformarm"
    "storageAccountType" = "Standard_LRS"

  }

  deployment_mode = "Incremental"
}




resource "azurerm_storage_container" "container" {
  name                  = "logs"
  resource_group_name   = azurerm_resource_group.terraform-arm.name
  storage_account_name  = lookup(azurerm_template_deployment.terraform-arm.outputs, "storageAccountName")
  container_access_type = "private"
}