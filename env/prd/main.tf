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

module "vm_linux" {
  source = "../../modules/VMs"

  location                   = var.resource_group.location
  image_os                   = "linux"
  resource_group_name        = var.resource_group.name
  allow_extension_operations = false
  data_disks = [
    for i in range(2) : {
      name                 = "linuxdisk${random_id.id.hex}${i}"
      storage_account_type = "Standard_LRS"
      create_option        = "Empty"
      disk_size_gb         = 1
      attach_setting = {
        lun     = i
        caching = "ReadWrite"
      }
      disk_encryption_set_id = azurerm_disk_encryption_set.example.id
    }
  ]
  new_boot_diagnostics_storage_account = {
    customer_managed_key = {
      key_vault_key_id          = azurerm_key_vault_key.storage_account_key.id
      user_assigned_identity_id = azurerm_user_assigned_identity.storage_account_key_vault.id
    }
  }
  new_network_interface = {
    ip_forwarding_enabled = false
    ip_configurations = [
      {
        public_ip_address_id = try(azurerm_public_ip.pip[0].id, null)
        primary              = true
      }
    ]
  }
  admin_username = "azureuser"
  admin_ssh_keys = [
    {
      public_key = tls_private_key.ssh.public_key_openssh
    }
  ]
  name = "ubuntu-${random_id.id.hex}"
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  os_simple = "UbuntuServer"
  size      = var.size
  subnet_id = module.vnet.vnet_subnets[0]

  depends_on = [azurerm_key_vault_access_policy.des]
}