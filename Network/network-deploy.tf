terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
  backend "azurerm" {

    resource_group_name = "terraform-workshop-rg"
    storage_account_name = "trfrmwkshstg"
    container_name = "trfmstateblob"
    key = "terraform.tfstate"
    access_key = "4S/hQZIbbw3A05qOvc6zJ1uWYle0cgHutWYemz2QD7SAS7kUvLG9M6oRTTqxydII0b4TTpiVMlYqF8lp0TagDQ=="
    
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "vnet" {

    name = var.vnet_name
    location = var.resource_group_location
    resource_group_name = var.resource_group_name
    address_space = var.vnet_address_prefix
  
}

resource "azurerm_subnet" "acr_subnet" {

    name = var.subnet_names.0
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.subnet_address_prefix.0]
    service_endpoints = [var.service_endpoints.0]

}

resource "azurerm_subnet" "kv_subnet" {

    name = var.subnet_names.1
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.subnet_address_prefix.1]
    service_endpoints = [var.service_endpoints.1]
  
}

# resource "azurerm_subnet" "storage_subnet" {

#     name = var.subnet_names.2
#     resource_group_name = var.resource_group_name
#     virtual_network_name = azurerm_virtual_network.vnet.name
#     address_prefixes = [var.subnet_address_prefix.2]
#     service_endpoints = [var.service_endpoints.2]
  
# }

# output "storage-subnet-id" { 
#   value = azurerm_subnet.storage_subnet.id
# }

output "acr-subnet-ip" {
  value = azurerm_subnet.acr_subnet.address_prefixes[0]
}

output "acr-subnet-id" {    
  value = azurerm_subnet.acr_subnet.id
}

output "kv-subnet-id" {    
  value = azurerm_subnet.kv_subnet.id
}

output "vnet-id" { 
  value = azurerm_virtual_network.vnet.id
}