module "vnet" {

  source = "../../modules/network"
  resource_group_name = var.resource_group_name
  location = var.location

  vnet_name = var.vnet_name
  vnet_address_space = var.vnet_address_space

  create_network_watcher = false
  subnets = var.subnets
}