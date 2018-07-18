variable "subscription_id" {
  description = "subscription to deploy to "
  default     = "469048f1-92af-4c71-a63b-330ec31d2b82"
}

variable "tenant_id" {
  description = "Azure AD Tenant to deploy under"
  default     = "8f18eb27-4f87-4a88-b325-f8e6e7e43486"
}

variable "deployment_client_ID" {
  description = "AAD SP ID to use for deployment"
}

variable "deployment_client_password" {
  description = "AAD SP password to use for deployment"
}

variable "rgName" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "acsAccountID" {
  type = "string"
}

variable "armTemplateLocation" {
  type = "string"
}

variable "orchestrator_version" {
  description = "Version of Kubernetes to use"
  default     = "1.10"
}

variable "master_vm_count" {
  description = "Number of master VMs to use"
  default     = 1
}

variable "dns_prefix" {
  description = "DNS prefix to use for environment"
}

variable "master_vm_size" {
  description = "Azure VM size for masters"
  default     = "Standard_D4_v2"
}

variable "linux_worker_vm_count" {
  description = "number of linux VMs"
  default     = 1
}

variable "linux_vm_size" {
  description = "Azure VM size for Linux VMs"
  default     = "Standard_D4_v2"
}

variable "windows_worker_vm_count" {
  description = "number of windows VMs"
  default     = 1
}

variable "windows_vm_size" {
  description = "Azure VM size for Windows VMs"
  default     = "Standard_D4_v2"
}

variable "admin_user_name" {
  description = "Admin user name"
  default     = "acsadmin"
}

variable "admin_password" {
  description = "Password for admin account"
}

variable "windows_sku" {
  description = "SKU to use for Windows VMs"
  default     = "Datacenter-Core-1709-with-Containers-smalldisk"
}

variable "ssh_key" {
  description = "SSH Key for Linux VMs"
}

variable "client_ID" {
  description = "Azure AD Client ID for ACS"
}

variable "client_secret" {
  description = "Azure AD Secret for ACS"
}

variable "acs_engine_config_file" {
  description = "File name and location of the ACS Engine config file"
  default     = "k8s.json"
}

variable "acs_engine_config_file_rendered" {
  description = "File name and location of the ACS Engine config file"
  default     = "k8s_rendered.json"
}

variable "DNS_Client_ID" {
  description = "Client ID for SP to set DNS records"
}

variable "DNS_Client_Password" {
  description = "Password for SP to set DNS records"
}

variable "DNS_Resource_Group" {
  description = "Resource Group that holds DNS zone"
}

variable "DNS_Staging" {
  description = "Whether to use Lets Encrypt Staging DNS "
  default     = true
}

variable "Traefik_Dashboard_URL" {
  description = "URL for Traefik Management Dashboard"
}

variable "Traefik_Dashboard_Password" {
  description = "Password for Traefik dashboard"
}

variable "Traefik_RBAC_Enabled" {
  description = "Whether K8S RBAC is enabled"
  default     = true
}
