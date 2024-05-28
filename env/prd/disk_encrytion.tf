resource "random_string" "key_vault_prefix" {
  count  = var.create_disk_encryption_resources ? 1 : 0
  length  = 6
  special = false
  upper   = false
  numeric = false
}

data "curl" "my_ip" {
  count  = var.create_disk_encryption_resources ? 1 : 0
  http_method = "GET"
  uri = "https://api64.ipify.org?format=text"
}

locals {
  public_ip = try((data.curl.my_ip[0].response).ip, var.my_public_ip)
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "KeyVault" {
  count  = var.create_disk_encryption_resources ? 1 : 0
  location                    = var.location
  name                        = random_string.key_vault_prefix[0].result
  resource_group_name         = var.resource_group_name
  sku_name                    = "premium"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = [local.public_ip]
  }
}

resource "azurerm_key_vault_key" "storage_account_key" {
  count  = var.create_disk_encryption_resources ? 1 : 0
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  key_type        = "RSA-HSM"
  key_vault_id    = azurerm_key_vault.KeyVault[0].id
  name            = "sakey"
  expiration_date = timeadd("${formatdate("YYYY-MM-DD", timestamp())}T00:00:00Z", "168h")
  key_size        = 2048

  depends_on = [
    azurerm_key_vault_access_policy.current_user
  ]

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

resource "azurerm_user_assigned_identity" "storage_account_key_vault" {
  count  = var.create_disk_encryption_resources ? 1 : 0
  location            = var.location
  name                = "storage_account_${random_id.id.hex}"
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_access_policy" "storage_account" {
  count  = var.create_disk_encryption_resources ? 1 : 0
  key_vault_id = azurerm_key_vault.KeyVault[0].id
  object_id    = azurerm_user_assigned_identity.storage_account_key_vault[0].principal_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  
  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}

resource "azurerm_key_vault_access_policy" "current_user" {
  count  = var.create_disk_encryption_resources ? 1 : 0
  key_vault_id = azurerm_key_vault.KeyVault[0].id
  object_id    = coalesce(var.managed_identity_principal_id, data.azurerm_client_config.current.object_id)
  tenant_id    = data.azurerm_client_config.current.tenant_id
  key_permissions = [
    "Get",
    "Create",
    "Delete",
    "GetRotationPolicy",
    "WrapKey",
    "UnwrapKey"
  ]
}

resource "azurerm_role_assignment" "disk-encryption-read-keyvault" {
  count  = var.create_disk_encryption_resources ? 1 : 0
  scope                = azurerm_key_vault.KeyVault[0].id
  role_definition_name = "Reader"
  principal_id         = azurerm_disk_encryption_set.disk_encryption_set[0].identity.0.principal_id
}

resource "azurerm_key_vault_key" "des_key" {
  count  = var.create_disk_encryption_resources ? 1 : 0
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  key_type        = "RSA-HSM"
  key_vault_id    = azurerm_key_vault.KeyVault[0].id
  name            = "deskey"
  expiration_date = timeadd("${formatdate("YYYY-MM-DD", timestamp())}T00:00:00Z", "168h")
  key_size        = 2048

  depends_on = [
    azurerm_key_vault_access_policy.current_user
  ]

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

resource "azurerm_disk_encryption_set" "disk_encryption_set" {
  count  = var.create_disk_encryption_resources ? 1 : 0
  key_vault_key_id    = azurerm_key_vault_key.des_key[0].id
  location            = var.location
  name                = "des"
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "des" {
  count  = var.create_disk_encryption_resources ? 1 : 0
  key_vault_id = azurerm_key_vault.KeyVault[0].id
  object_id    = azurerm_disk_encryption_set.disk_encryption_set[0].identity[0].principal_id
  tenant_id    = azurerm_disk_encryption_set.disk_encryption_set[0].identity[0].tenant_id
  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey",
  ]
}
