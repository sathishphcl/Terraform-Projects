variable "resource_group_name" {
    type = string    
}

variable "master_resource_group_name" {
    type = string
}

variable "log_analytics_resource_group_name" {
    type = string
}

variable "resource_group_location"  {
    type = string
}

variable "is_Private_cluster"{
    type = bool
}

variable "cluster_name"  {
    type = string
}

variable "log_analytics_workspace_name"  {
    type = string
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "client_id"  {
    type = string
}

variable "client_secret"  {
    type = string
}

variable "vnet_name"  {
    type = string
}

variable "subnet_name"  {
    type = string
}

variable "network_plugin"  {
    type = string
}

variable "network_policy"  {
    type = string
}

variable "service_cidr"  {
    type = string
}

variable "dns_service_ip"  {
    type = string
}

variable "vm_size"  {
    type = string
}

variable "max_pods"  {
    type = number
}

variable "min_count"  {
    type = number
}

variable "max_count"  {
    type = number
}

variable "type"  {
    type = string
}

variable "system_nodepool_name"  {
    type = string
}

variable "system_nodepool_count"  {
    type = number
}

variable "admin_group_ids"  {
    type = list(string)
}

variable "admin_tenant_id"  {
    type = string
}


