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
  location            = var.location
  resource_group_name = var.resource_group_name
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
  count    = var.create_network_watcher && !var.existing_network_watcher_rg ? 1 : 0
  name     = "NetworkWatcherRG"
  location = local.location
  tags     = merge({ "Name" = "NetworkWatcherRG" }, var.tags)
}

resource "azurerm_network_watcher" "nwatcher" {
  count               = var.create_network_watcher && !var.existing_network_watcher_rg ? 1 : 0
  name                = "NetworkWatcher_${local.location}"
  location            = local.location
  resource_group_name = var.create_network_watcher && !var.existing_network_watcher_rg ? azurerm_resource_group.nwatcher[0].name : "NetworkWatcherRG"
  tags                = merge({ "Name" = format("%s", "NetworkWatcher_${local.location}") }, var.tags)
}
#--------------------------------------------
# Ddos protection plan - Default is "false"
#--------------------------------------------

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets
  name                 = each.value.subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.subnet_address_prefix

  # service_endpoints                             = lookup(each.value, "service_endpoints", [])
  # service_endpoint_policy_ids                   = lookup(each.value, "service_endpoint_policy_ids", null)
  # private_endpoint_network_policies_enabled     = lookup(each.value, "private_endpoint_network_policies_enabled", null)
  # private_link_service_network_policies_enabled = lookup(each.value, "private_link_service_network_policies_enabled", null)
  
  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", {}) != null ? [1] : []
    content {
      name = lookup(each.value.delegation, "name", null)
      service_delegation {
        name = lookup(each.value.delegation.service_delegation, "name", null)
        actions = lookup(each.value.delegation.service_delegation, "actions", null)
      }
    }
  }
}

#-------------------------------------
# NSG - Default is "false"
#-------------------------------------

# Source code for creating configured rules for NSG
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.subnets
  name                = lower("nsg-${each.key}-in")
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = merge({
                           "ResourceName" = lower("nsg-${each.key}-in"),
                           "InboundRules" = jsonencode(lookup(each.value, "nsg_inbound_rules", [])),
                           "OutboundRules" = jsonencode(lookup(each.value, "nsg_outbound_rules", []))
                         }, var.tags)

  dynamic "security_rule" {
    for_each = concat(
                lookup(each.value, "nsg_inbound_rules", []),
                lookup(each.value, "nsg_outbound_rules", [])
              )
    content {
      name                       = replace(security_rule.value[0], " ", "_") == "" ? "Default_Rule" : replace(security_rule.value[0], " ", "_")
      priority                   = security_rule.value[1]
      direction                  = security_rule.value[2] == "" ? "Inbound" : security_rule.value[2]
      access                     = security_rule.value[3] == "" ? "Allow" : security_rule.value[3]
      protocol                   = security_rule.value[4] == "" ? "Tcp" : security_rule.value[4]
      source_port_range          = "*"
      destination_port_range     = security_rule.value[5] == "" ? "*" : security_rule.value[5]
      source_address_prefix      = security_rule.value[6] == "" ? element(each.value.subnet_address_prefix, 0) : security_rule.value[6]
      destination_address_prefix = security_rule.value[7] == "" ? element(each.value.subnet_address_prefix, 0) : security_rule.value[7]
      description                = "${security_rule.value[2]}_Port_${security_rule.value[5]}"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
