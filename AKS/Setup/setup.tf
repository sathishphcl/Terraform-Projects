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
    container_name = "setstateblob"
    key = "terraform.tfstate"
    access_key = "4S/hQZIbbw3A05qOvc6zJ1uWYle0cgHutWYemz2QD7SAS7kUvLG9M6oRTTqxydII0b4TTpiVMlYqF8lp0TagDQ=="
  }
}

provider "azurerm" {

  features {}
}

data "azurerm_resource_group" "rg" {

    name = var.resource_group_name
}

data "azurerm_private_dns_zone" "aksapipvtdns" {    

    name = "privatelink.${var.resource_group_location}.azmk8s.io"
    resource_group_name = var.master_resource_group_name
}

data "azurerm_subnet" "aks_subnet" {

  name = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "terrakslw" {
  
  name = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_resource_group_name
}

resource "azurerm_log_analytics_solution" "terraksci" {

  resource_group_name = var.log_analytics_resource_group_name
  location = var.resource_group_location
  solution_name = "ContainerInsights"
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
  workspace_name = var.log_analytics_workspace_name
  workspace_resource_id = data.azurerm_log_analytics_workspace.terrakslw.id
}

resource "azurerm_kubernetes_cluster" "terraksk8s" {

  name = var.cluster_name
  resource_group_name = var.resource_group_name
  location = var.resource_group_location
  dns_prefix_private_cluster = var.cluster_name

  default_node_pool {

    name = var.system_nodepool_name
    enable_auto_scaling = true
    node_count = var.system_nodepool_count
    max_count = var.max_count
    min_count = var.min_count
    vm_size = var.vm_size
    vnet_subnet_id = data.azurerm_subnet.aks_subnet.id    
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  role_based_access_control {

    enabled = true
    azure_active_directory {
      managed = true
      admin_group_object_ids = var.admin_group_ids
      tenant_id = var.admin_tenant_id
    }
  }

  network_profile {

    # dns_service_ip = var.dns_service_ip
    # service_cidr = var.service_cidr
    network_plugin = var.network_plugin
    network_policy = var.network_policy
  }

  linux_profile {

    admin_username = "ubuntu"
    ssh_key {

        key_data = file(var.ssh_public_key)
    }
  }

  addon_profile {

    oms_agent {

      enabled = true
      log_analytics_workspace_id = data.azurerm_log_analytics_workspace.terrakslw.id
      
    }
  }

  private_cluster_enabled = var.is_Private_cluster ? true : false
  private_dns_zone_id = data.azurerm_private_dns_zone.aksapipvtdns.id
  
}