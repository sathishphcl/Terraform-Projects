variable "resource_group_name" {
    type = string    
}
variable "master_resource_group_name" {
    type = string
}
variable "resource_group_location"  {
    type = string

}

# variable "tags" {
#     type = map(string)
#     default = {
#         primary_owner = "monojit.datta@outlook.com"
#         purpose = "terraform workshop"

#     }
# }

variable "is_Private_cluster"{
    type = bool

}
variable "master_vnet_name"{
    type = string
}
variable "vnet_name"{
    type = string
}
variable "vnet_address_prefixes"{
    type = list(string)
}

variable "subnet_names"{
    type = list(string)
}

variable "subnet_address_prefixes"{
    type = list(string)
}
variable "acr_name"{
    type = string
}
variable "acr_sku"{
    type = string
}
variable "kv_name"{
    type = string
}
variable "kv_sku"{
    type = string
}
variable "tenant_id" {
  type = string
}
variable "object_id" {
  type = string
}