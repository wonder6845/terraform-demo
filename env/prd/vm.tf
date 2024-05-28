resource "azurerm_network_interface_security_group_association" "linux_nic_assoc" {
  network_interface_id      = module.vm_linux.network_interface_id
  network_security_group_id = element(module.vnet.network_security_group_ids, 0) 
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}


resource "azurerm_network_security_group" "vm_nsg" {
  location            = var.location
  name                = "nsg-vm-${random_id.id.hex}"
  resource_group_name = var.resource_group_name
}

module "web_vm_linux" {
  source = "../../modules/VMs"

  location                   = var.location
  image_os                   = "linux"
  resource_group_name        = var.resource_group_name
  allow_extension_operations = false
  data_disks = [
    for i in range(2) : {
      name                 = "linuxdisk-web-${random_id.id.hex}${i}"
      storage_account_type = "Standard_LRS"
      create_option        = "Empty"
      disk_size_gb         = 1
      attach_setting = {
        lun     = i
        caching = "ReadWrite"
      }
      # disk_encryption_set_id = azurerm_disk_encryption_set.disk_encryption_set.id
    }
  ]

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
  subnet_id = module.vnet.subnet_ids["web-subnet"]
}

module "was_vm_linux" {
  
}

data "azurerm_public_ip" "pip" {
  count = var.create_public_ip ? 2 : 0

  name                = azurerm_public_ip.pip[count.index].name
  resource_group_name = var.resource_group_name

  depends_on = [module.vm_linux]
}


