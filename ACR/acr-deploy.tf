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

resource "azurerm_container_registry" "acr" {

    name = "trwkshpacr"
    location = var.resource_group_location
    resource_group_name = var.resource_group_name
    sku = "Premium"
    admin_enabled = "false"    
}