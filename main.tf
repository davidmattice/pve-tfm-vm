##############################
# Local Variables
##############################
locals {
  storage_pool  = var.storage_pool
  user_data     = var.custom_user_data_file != "" ? templatefile(var.custom_user_data_file, { hostname = "${var.name}", domain = "home.local"}) : ""
  vendor_config = var.custom_vendor_config_file != "" ? file(var.custom_vendor_config_file) : ""
  description   = var.description != "" ? var.description : format("Cloned from tempate ID %s", var.template_id)
}

##############################
# Data Lookups
##############################
# Get a list of Proxmox nodes from the server the provider connected to
data "proxmox_virtual_environment_nodes" "pm" {}

# Pull the list of datastores from the first node in the list of Proxmox nodes (they should all be the same)
data "proxmox_virtual_environment_datastores" "pm" {
  node_name = data.proxmox_virtual_environment_nodes.pm.names[0]
}

##############################
# Resources
##############################
# Create a cloud-init for the vendor config from this static content
resource "proxmox_virtual_environment_file" "user_data" {
  content_type = "snippets"
  datastore_id = element(data.proxmox_virtual_environment_datastores.pm.datastore_ids, index(data.proxmox_virtual_environment_datastores.pm.datastore_ids, local.storage_pool))
  node_name    = data.proxmox_virtual_environment_datastores.pm.node_name

  source_raw {
    data = local.user_data
    file_name = format("terraform-provider-proxmox-pm-user-data-%s.yaml", var.name)
  }
}

# Create a cloud-init for the vendor config from this static content
resource "proxmox_virtual_environment_file" "vendor_config" {
  content_type = "snippets"
  datastore_id = element(data.proxmox_virtual_environment_datastores.pm.datastore_ids, index(data.proxmox_virtual_environment_datastores.pm.datastore_ids, local.storage_pool))
  node_name    = data.proxmox_virtual_environment_datastores.pm.node_name

  source_raw {
    data = local.vendor_config
    file_name = format("terraform-provider-proxmox-pm-vendor-config-%s.yaml", var.name)
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.name
  description = local.description
  tags        = concat(["terraform"], var.additional_tags)
  node_name   = var.node_name
  clone {
    vm_id = var.template_id
  }
  cpu {
    cores   = var.cpu["cores"]
    numa    = var.cpu["numa"]
    sockets = var.cpu["sockets"]
  }
  initialization {
    dns {
      server = "1.1.1.1"
    }
    ip_config {
      ipv4 {
        address = var.network["address"]
        gateway = var.network["gateway"]
      }
    }
    vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
    user_data_file_id = proxmox_virtual_environment_file.user_data.id
  }
    # Amount of memory needed
  memory {
    dedicated = var.memory["dedicated"]
  }
  started = true
}