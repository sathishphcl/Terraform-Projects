module "network" {
  
  source = "../Network/"
  resource_group_name = var.resource_group_name
  resource_group_location = var.resource_group_location
  tags = var.tags
  vnet_name = var.vnet_name
  vnet_address_prefix = var.vnet_address_prefix
  subnet_names = var.subnet_names
  subnet_address_prefix = var.subnet_address_prefix
  service_endpoints = var.service_endpoints

}

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

resource "azurerm_storage_account" "storage" {

    name =  var.storage_name   
    resource_group_name = "${module.network.resource_group}"
    location = "${module.network.location}"
    account_kind = var.account_kind
    account_tier = var.account_tier
    access_tier = var.access_tier
    account_replication_type = var.account_replication_type

    network_rules {

        default_action = "Deny"
        virtual_network_subnet_ids = ["${module.network.storage_subnet_id}"]
        bypass = ["Metrics"]

    }
  
}
