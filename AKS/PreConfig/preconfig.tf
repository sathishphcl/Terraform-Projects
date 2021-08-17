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
    container_name = "prestateblob"
    key = "terraform.tfstate"
    access_key = "4S/hQZIbbw3A05qOvc6zJ1uWYle0cgHutWYemz2QD7SAS7kUvLG9M6oRTTqxydII0b4TTpiVMlYqF8lp0TagDQ=="
    
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_virtual_network" "master_vnet" {
    resource_group_name = var.master_resource_group_name
    name = var.master_vnet_name
  
}

data "azurerm_private_dns_zone" "aksapipvtdns" {    
    name = "privatelink.${var.resource_group_location}.azmk8s.io"
    resource_group_name = var.master_resource_group_name
}

data "azurerm_resource_group" "rg"{
    name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
    name = var.vnet_name
    location = var.resource_group_location
    resource_group_name = var.resource_group_name
    address_space = var.vnet_address_prefixes
}

resource "azurerm_subnet" "aks_subnet" {
    name = var.subnet_names.0
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.subnet_address_prefixes.0]
}

resource "azurerm_subnet" "ingress_subnet" {
    name = var.subnet_names.1
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.subnet_address_prefixes.1]
}

resource "azurerm_subnet" "appgw_subnet" {
    name = var.subnet_names.2
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.subnet_address_prefixes.2]
}

resource "azurerm_virtual_network_peering" "masterakspeer" {
    name = "master-aks-peering"
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = data.azurerm_virtual_network.master_vnet.id
}

resource "azurerm_virtual_network_peering" "aksmasterpeer" {
    name = "aks-master-peering"
    resource_group_name = var.master_resource_group_name
    virtual_network_name = data.azurerm_virtual_network.master_vnet.name
    remote_virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_container_registry" "acr" {
    name = var.acr_name
    location = var.resource_group_location
    resource_group_name = var.resource_group_name
    sku = var.acr_sku
    admin_enabled = "false"    
}

resource "azurerm_key_vault" "kv" {
    name = var.kv_name
    location = var.resource_group_location
    resource_group_name = var.resource_group_name
    tenant_id = var.tenant_id
    enabled_for_disk_encryption = true
    enabled_for_template_deployment = true
    sku_name = var.kv_sku
}

resource "azurerm_key_vault_access_policy" "kvpolicy" {
    key_vault_id = azurerm_key_vault.kv.id
    tenant_id = var.tenant_id
    object_id = var.object_id
    secret_permissions = ["get", "list", "delete", "set"]
}

# resource "azurerm_private_dns_zone" "aksapipvtdns" {
#     count = var.is_Private_cluster ? 1 : 0
#     name = "privatelink.${var.resource_group_location}.azmk8s.io"
#     resource_group_name = var.master_resource_group_name
# }

resource "azurerm_private_dns_zone_virtual_network_link" "masterapilink" {
    count = var.is_Private_cluster ? 1 : 0
    name = data.azurerm_virtual_network.master_vnet.name
    resource_group_name = var.master_resource_group_name
    private_dns_zone_name = data.azurerm_private_dns_zone.aksapipvtdns.name
    virtual_network_id = azurerm_virtual_network.vnet.id
}

output "resource_group_name" {
    value = data.azurerm_resource_group.rg.name
}

output "resource_group_location" {
    value = data.azurerm_resource_group.rg.location
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

output "ingress_subnet_id" {    
  value = azurerm_subnet.ingress_subnet.id
}

output "appgw_subnet_id" {    
  value = azurerm_subnet.appgw_subnet.id
}

output "vnet_id" { 
  value = azurerm_virtual_network.vnet.id
}

output "acr_id" { 
  value = azurerm_container_registry.acr.id
}

output "kv_id" { 
  value = azurerm_key_vault.kv.id
}

output "private_dns_zone_id" {    
    value = data.azurerm_private_dns_zone.aksapipvtdns.id
}