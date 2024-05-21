variable "resource_group_name" {
  default = "pyo-rg"
}

variable "vnet_name" {
  default = "pyo-vnet"
}

variable "location" {
  
}

variable "vnet_address_space" {
  default = ["10.0.0.0/16"]  
}
variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    subnet_name                         = string
    subnet_address_prefix               = list(string)
    # service_endpoints                   = list(string)
    # service_endpoint_policy_ids         = list(string)
    # private_endpoint_network_policies_enabled     = bool
    # private_link_service_network_policies_enabled = bool
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
    nsg_inbound_rules  = optional(list(list(string)), [])
    nsg_outbound_rules = optional(list(list(string)), [])
  }))
  default = {}
}