resource "azurerm_linux_virtual_machine" "vm_linux" {
  count = local.is_linux ? 1 : 0

  admin_username                                         = var.admin_username
  location                                               = azurerm_resource_group.rg.location
  name                                                   = var.vm_name
  network_interface_ids                                  = local.network_interface_ids
  resource_group_name                                    = azurerm_resource_group.rg.name
  size                                                   = var.vm_size
  admin_password                                         = var.admin_password
  availability_set_id                                    = var.availability_set_id
  bypass_platform_safety_checks_on_user_schedule_enabled = var.bypass_platform_safety_checks_on_user_schedule_enabled
  capacity_reservation_group_id                          = var.capacity_reservation_group_id
  computer_name                                          = coalesce(var.computer_name, var.name)
  custom_data                                            = var.custom_data
  dedicated_host_group_id                                = var.dedicated_host_group_id
  dedicated_host_id                                      = var.dedicated_host_id
  disable_password_authentication                        = var.disable_password_authentication
  edge_zone                                              = var.edge_zone
  encryption_at_host_enabled                             = var.encryption_at_host_enabled
  eviction_policy                                        = var.eviction_policy
  extensions_time_budget                                 = var.extensions_time_budget
  license_type                                           = var.license_type
  max_bid_price                                           = var.max_bid_price
  patch_assessment_mode                                  = var.patch_assessment_mode
  patch_mode                                             = local.patch_mode
  platform_fault_domain                                  = var.platform_fault_domain
  priority                                               = var.priority
  provision_vm_agent                                     = var.provision_vm_agent
  proximity_placement_group_id                           = var.proximity_placement_group_id
  reboot_setting                                         = var.reboot_setting
  secure_boot_enabled                                    = var.secure_boot_enabled
  source_image_id                                        = var.source_image_id
  tags = merge({ "Name" = format("%s", var.vnet_name) }, var.tags, )

  user_data                    = var.user_data
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id
  vtpm_enabled                 = var.vtpm_enabled
  zone                         = var.zone

  os_disk {
    caching                          = var.os_disk.caching
    storage_account_type             = var.os_disk.storage_account_type
    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    disk_size_gb                     = var.os_disk.disk_size_gb
    name                             = var.os_disk.name
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    security_encryption_type         = var.os_disk.security_encryption_type
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled

    dynamic "diff_disk_settings" {
      for_each = var.os_disk.diff_disk_settings == null ? [] : [
        "diff_disk_settings"
      ]

      content {
        option    = var.os_disk.diff_disk_settings.option
        placement = var.os_disk.diff_disk_settings.placement
      }
    }
  }
  dynamic "additional_capabilities" {
    for_each = var.vm_additional_capabilities == null ? [] : [
      "additional_capabilities"
    ]

    content {
      ultra_ssd_enabled = var.vm_additional_capabilities.ultra_ssd_enabled
    }
  }
  dynamic "admin_ssh_key" {
    for_each = { for key in var.admin_ssh_keys : jsonencode(key) => key }

    content {
      public_key = admin_ssh_key.value.public_key
      username   = coalesce(admin_ssh_key.value.username, var.admin_username)
    }
  }
  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics ? ["boot_diagnostics"] : []

    content {
      storage_account_uri = try(azurerm_storage_account.boot_diagnostics[0].primary_blob_endpoint, var.boot_diagnostics_storage_account_uri)
    }
  }


  lifecycle {
    precondition {
      condition = length([
        for b in [
          var.source_image_id != null, var.source_image_reference != null,
          var.os_simple != null
        ] : b if b
      ]) == 1
      error_message = "Must provide one and only one of `vm_source_image_id`, `vm_source_image_reference` and `vm_os_simple`."
    }
    precondition {
      condition     = var.network_interface_ids != null || var.new_network_interface != null
      error_message = "Either `new_network_interface` or `network_interface_ids` must be provided."
    }
    #Public keys can only be added to authorized_keys file for 'admin_username' due to a known issue in Linux provisioning agent.
    precondition {
      condition     = alltrue([for value in var.admin_ssh_keys : value.username == var.admin_username || value.username == null])
      error_message = "`username` in var.admin_ssh_keys should be the same as `admin_username` or `null`."
    }
    precondition {
      condition     = !var.bypass_platform_safety_checks_on_user_schedule_enabled || local.patch_mode == "AutomaticByPlatform"
      error_message = "`bypass_platform_safety_checks_on_user_schedule_enabled` can only be set when patch_mode is `AutomaticByPlatform`"
    }
    precondition {
      condition     = var.reboot_setting == null || local.patch_mode == "AutomaticByPlatform"
      error_message = "`reboot_setting` can only be set when patch_mode is `AutomaticByPlatform`"
    }
  }
}