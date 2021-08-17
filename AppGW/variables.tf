variable "resource_group_name" {

    type = string
}

variable "resource_group_location" {

    type = string
}

variable "appgw_name" {

    type = string
}

variable "vnet_name" {

    type = string
}

variable "subnet_name" {

    type = string
}

variable "backend_pool_names" {

    type = list(string)
}

variable "backend_ip_addresses" {

    type = list(string)
}

variable "sslcert_name" {

    type = string
}

variable "sslcert_secret_name" {

    type = string
}

variable "sslcert_password_name" {

    type = string
}

variable "trusted_root_cert_name" {

    type = string
}

variable "trusted_root_cert_secret_name" {

    type = string
}

variable "keyvault_name" {

    type = string
}

variable "https_listener_names" {

    type = list(string)
}

variable "https_setting_names" {

    type = list(string)
}

variable "listener_host_names" {

    type = list(string)
}

variable "backend_host_names" {

    type = list(string)
}

variable "https_rule_names" {

    type = list(string)
}

variable "probe_name" {

    type = string
}



