resource "random_id" "id" {
  byte_length = 2
}

resource "azurerm_public_ip" "pip" {
  count = var.create_public_ip ? 2 : 0

  allocation_method   = "Dynamic"
  location            = var.location
  name                = "pip-${random_id.id.hex}-${count.index}"
  resource_group_name = var.resource_group_name
}


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