#------------------------
# Local declarations
#------------------------
locals {
  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
  if_ddos_enabled     = var.create_ddos_plan ? [{}] : []
}
data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "Name" = format("%s", var.resource_group_name) }, var.tags, )
}

#-------------------------------------
# VNET Creation - Default is "true"
#-------------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = var.vnet_address_space
  dns_servers         = var.dns_servers
  tags = merge({ "Name" = format("%s", var.vnet_name) }, var.tags, )

  dynamic "ddos_protection_plan" {
    for_each = local.if_ddos_enabled

    content {
     id = azurerm_network_ddos_protection_plan.ddos[0].id
     enable = true
    }
  }

}

#--------------------------------------------
# Ddos protection plan - Default is "false"
#--------------------------------------------
resource "azurerm_network_ddos_protection_plan" "ddos" {
  count    = var.create_ddos_plan ? 1 : 0
  name     = "${var.vnet_name}-ddos"
  location = local.location
  resource_group_name = local.resource_group_name
}

#-------------------------------------
# Network Watcher - Default is "true"
#-------------------------------------
resource "azurerm_resource_group" "nwatcher" {
  count    = var.create_network_watcher != false ? 1 : 0
  name     = "NetworkWatcherRG"
  location = local.location
  tags     = merge({ "Name" = "NetworkWatcherRG" }, var.tags, )
}

