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
    container_name = "appgwstateblob"
    key = "terraform.tfstate"
    access_key = "4S/hQZIbbw3A05qOvc6zJ1uWYle0cgHutWYemz2QD7SAS7kUvLG9M6oRTTqxydII0b4TTpiVMlYqF8lp0TagDQ=="
    
  }
}

provider "azurerm" {

  features {}
}

locals {
  
  gateway_configuration_name = "${var.appgw_name}-gwconfig"
  public_ip_name = "${var.appgw_name}-pip"
  frontend_port_name = "${var.appgw_name}-fep"
  frontend_ip_configuration_name = "${var.appgw_name}-feipc"

}

data "azurerm_subnet" "appgw_subnet" {

  name = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault" "kv" {

    name = var.keyvault_name
    resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "kv-secret" {

    name = var.sslcert_secret_name
    key_vault_id = data.azurerm_key_vault.kv.id    
}

data "azurerm_key_vault_secret" "kv-password" {

    name = var.sslcert_password_name
    key_vault_id = data.azurerm_key_vault.kv.id    
}

data "azurerm_key_vault_secret" "root-cert-secret" {

    name = var.trusted_root_cert_secret_name
    key_vault_id = data.azurerm_key_vault.kv.id    
}

resource "azurerm_public_ip" "appgw-pip" {
    
    name = local.public_ip_name
    allocation_method = "Static"
    resource_group_name = var.resource_group_name
    location = var.resource_group_location
    sku = "Standard"
}

resource "azurerm_application_gateway" "terr-workshop-appgw" {

    name = var.appgw_name
    resource_group_name = var.resource_group_name
    location = var.resource_group_location
    depends_on = [
      azurerm_public_ip.appgw-pip      
    ]

    sku {
    
        name = "WAF_v2"
        tier = "WAF_v2"
        capacity = 2      
    }

    gateway_ip_configuration {
    
        name = local.gateway_configuration_name
        subnet_id = data.azurerm_subnet.appgw_subnet.id
    }

    frontend_ip_configuration {
        
        name = local.frontend_ip_configuration_name
        public_ip_address_id = azurerm_public_ip.appgw-pip.id
    }

    frontend_port {
      
      name = local.frontend_port_name
      port = 443

    }

    backend_address_pool {

        name = var.backend_pool_names[0]
        ip_addresses = var.backend_ip_addresses
    }

    ssl_certificate {
      
        name = var.sslcert_name
        data = data.azurerm_key_vault_secret.kv-secret.value
        password = data.azurerm_key_vault_secret.kv-password.value
    }

    trusted_root_certificate {
      
        name = var.trusted_root_cert_name
        data = data.azurerm_key_vault_secret.root-cert-secret.value
    }

    http_listener {
      
        name = var.https_listener_names[0]
        host_name = var.listener_host_names[0]
        frontend_ip_configuration_name = local.frontend_ip_configuration_name
        frontend_port_name = local.frontend_port_name
        protocol = "Https"
        ssl_certificate_name = var.sslcert_name
    }

    http_listener {
      
        name = var.https_listener_names[1]
        host_name = var.listener_host_names[1]
        frontend_ip_configuration_name = local.frontend_ip_configuration_name
        frontend_port_name = local.frontend_port_name
        protocol = "Https"
        ssl_certificate_name = var.sslcert_name
    }

    probe {

       name = var.probe_name
       pick_host_name_from_backend_http_settings = true
       protocol = "Https"
       path = "/"
       timeout = 60
       unhealthy_threshold = 3
       interval = 20
    }

    backend_http_settings {

        name = var.https_setting_names[0]
        request_timeout = 30
        protocol = "Https"
        port = 443
        cookie_based_affinity = "Disabled"
        trusted_root_certificate_names = [var.trusted_root_cert_name]
        host_name = var.backend_host_names[0]
        probe_name = var.probe_name
        pick_host_name_from_backend_address = false
    }

    backend_http_settings {
      
        name = var.https_setting_names[1]
        request_timeout = 30
        protocol = "Https"
        port = 443
        cookie_based_affinity = "Disabled"
        trusted_root_certificate_names = [var.trusted_root_cert_name]
        host_name = var.backend_host_names[1]
        probe_name = var.probe_name
        pick_host_name_from_backend_address = false
    }

    request_routing_rule {

        name = var.https_rule_names[0]
        backend_address_pool_name = var.backend_pool_names[0]
        backend_http_settings_name = var.https_setting_names[0]
        http_listener_name = var.https_listener_names[0]
        rule_type = "Basic"
    }

    request_routing_rule {

        name = var.https_rule_names[1]
        backend_address_pool_name = var.backend_pool_names[0]
        backend_http_settings_name = var.https_setting_names[1]
        http_listener_name = var.https_listener_names[1]
        rule_type = "Basic"
    }

}

