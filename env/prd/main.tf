module "vnet" {

  source = "../../modules/network"
  resource_group_name = "testme"
  location = "koreacentral"

  vnet_name = "testme-vnet"
  vnet_address_space = ["10.0.0.0/16"]  

  create_network_watcher = true
}