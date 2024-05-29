resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "random_id" "pip" {
  count = var.create_public_ip ? var.pip_count : 0
  keepers = {
    name = var.resource_group_name
  }
  byte_length = 4
}

resource "azurerm_network_security_group" "vm_nsg" {
  location            = var.location
  name                = "nsg-vm-${random_id.id.hex}"
  resource_group_name = var.resource_group_name
}

resource "azurerm_public_ip" "pip" {
  count = var.create_public_ip ? var.pip_count : 0
  name                = "pip-${random_id.id.hex}-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

module "vm_linux" {
  source = "../../modules/VMs"
  for_each = { for idx, vm in var.vms : idx => vm }

  location                   = var.location
  image_os                   = "linux"
  resource_group_name        = var.resource_group_name
  allow_extension_operations = false

  # Data Disk Enabled
  # data_disks = [
  #   for i in range(2) : {
  #     name                 = "linuxdisk-web-${random_id.id.hex}${i}"
  #     storage_account_type = "Standard_LRS"
  #     create_option        = "Empty"
  #     disk_size_gb         = 1
  #     attach_setting = {
  #       lun     = i
  #       caching = "ReadWrite"
  #     }
  #     # disk_encryption_set_id = azurerm_disk_encryption_set.disk_encryption_set.id
  #   }
  # ]

  new_network_interface = {
    ip_forwarding_enabled = false
    ip_configurations = [
      {
        public_ip_address_id = try(azurerm_public_ip.pip[each.key].id, null)
        primary              = true
      }
    ]
  }
  admin_username = lookup(each.value, "admin_username", "azureuser")
  admin_ssh_keys = [
    {
      public_key = tls_private_key.ssh.public_key_openssh
    }
  ]
  name = "${each.value.vm_name}-${random_id.id.hex}"
  os_disk = {
    caching              = each.value.os_disk.caching
    storage_account_type = each.value.os_disk.storage_account_type
  }
  os_simple = each.value.os_simple
  size      = each.value.size
  subnet_id = module.vnet.subnet_ids[each.value.subnet]
  custom_data = base64encode(each.value.custom_data)
}
resource "azurerm_network_interface_security_group_association" "linux_nic_assoc" {
  for_each = { for idx, vm in var.vms : idx => vm }
  network_interface_id      = module.vm_linux[each.key].network_interface_ids[0]
  network_security_group_id = element(module.vnet.network_security_group_ids, 0) 
}

data "azurerm_public_ip" "pip" {
  count = var.create_public_ip ? var.pip_count : 0

  name                = azurerm_public_ip.pip[count.index].name
  resource_group_name = var.resource_group_name

  depends_on = [module.vm_linux]
}


