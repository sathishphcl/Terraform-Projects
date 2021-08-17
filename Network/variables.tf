variable "resource_group_name"  {}
variable "resource_group_location"  {}

variable "vnet_name"{
    
    type = string
    default = "terraform-workshop-vnet"
}
variable "vnet_address_prefix"{

    type = list(string)
    default = ["10.0.0.0/16"]
}
variable "subnet_names"{

    type = list(string)
    default = ["test_subnet"]
}
variable "subnet_address_prefix"{

    type = list(string)
    default = ["10.0.0.0/24"]
}
variable "service_endpoints"{

    type = list(string)
}