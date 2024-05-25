module "vnet" {

  source              = "../../modules/network/vnet"
  resource_group_name = var.resource_group_name
  location            = var.location

  create_ddos_plan = false

  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space

  create_network_watcher = false
  subnets                = var.subnets
}