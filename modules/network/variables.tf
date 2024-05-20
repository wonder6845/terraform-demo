variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = true
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = "rg-demo-westeurope-01"
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "westeurope"
}

variable "vnet_name" {
  description = "Name of your Azure Virtual Network"
  default     = "pyo-vnet"
}

variable "vnet_address_space" {
  description = "The address space to be used for the Azure virtual network."
  default     = ["10.0.0.0/16"]
}

variable "dns_servers" {
  description = "List of dns servers to use for virtual network"
  default = []
  
}
variable "create_ddos_plan" {
  description = "Create an ddos plan - Default is false"
  default     = false
}


# variable "ddos_plan_name" {
#   description = "The name of AzureNetwork DDoS Protection Plan"
#   default     = "azureddosplan01"
# }

# variable "dns_servers" {
#   description = "List of dns servers to use for virtual network"
#   default     = []
# }

# variable "create_network_watcher" {
#   description = "Controls if Network Watcher resources should be created for the Azure subscription"
#   default     = true
# }

# variable "subnets" {
#   description = "Map of subnet configurations"
#   type = map(object({
#     subnet_name                         = string
#     subnet_address_prefix               = list(string)
#     service_endpoints                   = list(string)
#     service_endpoint_policy_ids         = list(string)
#     private_endpoint_network_policies_enabled     = bool
#     private_link_service_network_policies_enabled = bool
#     delegation = optional(object({
#       name = string
#       service_delegation = object({
#         name    = string
#         actions = list(string)
#       })
#     }))
#     nsg_inbound_rules  = optional(list(list(string)))
#     nsg_outbound_rules = optional(list(list(string)))
#   }))
#   default = {}
# }

# variable "gateway_subnet_address_prefix" {
#   description = "The address prefix to use for the gateway subnet"
#   default     = null
# }

# variable "firewall_subnet_address_prefix" {
#   description = "The address prefix to use for the Firewall subnet"
#   default     = null
# }

# variable "firewall_service_endpoints" {
#   description = "Service endpoints to add to the firewall subnet"
#   type        = list(string)
#   default = [
#     "Microsoft.AzureActiveDirectory",
#     "Microsoft.AzureCosmosDB",
#     "Microsoft.EventHub",
#     "Microsoft.KeyVault",
#     "Microsoft.ServiceBus",
#     "Microsoft.Sql",
#     "Microsoft.Storage",
#   ]
# }

# variable "gateway_service_endpoints" {
#   description = "Service endpoints to add to the Gateway subnet"
#   type        = list(string)
#   default     = []
# }

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}