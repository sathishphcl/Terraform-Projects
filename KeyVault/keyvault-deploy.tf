terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_key_vault" "kv" {

    name = "terraform-workshop-kv"
    location = var.resource_group_location
    resource_group_name = var.resource_group_name
    tenant_id = var.tenant_id
    enabled_for_disk_encryption = true
    enabled_for_template_deployment = true
    sku_name = "premium"
}

resource "azurerm_key_vault_access_policy" "kvpolicy" {
  
    key_vault_id = azurerm_key_vault.kv.id
    tenant_id = var.tenant_id
    object_id = var.object_id
    secret_permissions = [
        "get", "list", "delete", "set"
    ]

}
