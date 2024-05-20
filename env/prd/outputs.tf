# Resource Group
output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = module.vnet.resource_group_name
}

output "resource_group_id" {
  description = "The id of the resource group in which resources are created"
  value       = module.vnet.resource_group_id
}

output "resource_group_location" {
  description = "The location of the resource group in which resources are created"
  value       = module.vnet.resource_group_location
}

output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = module.vnet.virtual_network_id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = module.vnet.subnet_ids
}