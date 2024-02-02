##############################
# Local Variables
##############################
locals {
  storage_pool  = var.storage_pool
  pve_node_name = var.pve_node_name == "" ? data.proxmox_virtual_environment_nodes.pve.names[0] : var.pve_node_name
  user_data     = var.custom_user_data_file != "" ? templatefile(var.custom_user_data_file, { hostname = "${var.name}", domain = "${var.domain_name}" }) : templatefile("${path.module}/scripts/user-data.yaml", { hostname = "${var.name}", domain = "${var.domain_name}" })
  vendor_config = var.custom_vendor_config_file != "" ? file(var.custom_vendor_config_file) : file("${path.module}/scripts/vendor-config.yaml")
  description   = var.description != "" ? var.description : format("Cloned from tempate ID %s", var.template_id)

  # Provide backward support for the original network model
  old_network    = {
    "vmbr0" = {
      "bridge"  = "vmbr0"
      "address" = var.network["address"]
      "gateway" = var.network["gateway"]
    }
  }
  network_merged = var.network_devices == null ? { for key, value in local.old_network :
    key => merge(var.network_defaults,
    value)
  } : { for key, value in var.network_devices :
    key => merge(var.network_defaults,
    value)
  }
}

##############################
# Data Lookups
##############################
# Get a list of Proxmox nodes from the server the provider connected to
data "proxmox_virtual_environment_nodes" "pve" {}

# Pull the list of datastores from the PVE node 
data "proxmox_virtual_environment_datastores" "pve" {
  node_name = local.pve_node_name
}

# Get the DNS configuration for the node the VM will go on
data "proxmox_virtual_environment_dns" "pve_node" {
  node_name = local.pve_node_name
}

##############################
# Resources
##############################
# Create a cloud-init for the vendor config from this static content
resource "proxmox_virtual_environment_file" "user_data" {
  content_type = "snippets"
  datastore_id = element(data.proxmox_virtual_environment_datastores.pve.datastore_ids, index(data.proxmox_virtual_environment_datastores.pve.datastore_ids, local.storage_pool))
  node_name    = local.pve_node_name

  source_raw {
    data = local.user_data
    file_name = format("terraform-provider-proxmox-pve-user-data-%s.yaml", var.name)
  }
}

# Create a cloud-init for the vendor config from this static content
resource "proxmox_virtual_environment_file" "vendor_config" {
  content_type = "snippets"
  datastore_id = element(data.proxmox_virtual_environment_datastores.pve.datastore_ids, index(data.proxmox_virtual_environment_datastores.pve.datastore_ids, local.storage_pool))
  node_name    = local.pve_node_name

  source_raw {
    data = local.vendor_config
    file_name = format("terraform-provider-proxmox-pm-vendor-config-%s.yaml", var.name)
  }
}

# Create the VM istself
resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.name
  description = local.description
  tags        = concat(["terraform"], var.additional_tags)
  node_name   = local.pve_node_name
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
      servers = var.network["dns_servers"]
      domain = var.network["dns_domain"]
    }
    dynamic ip_config {
      for_each = local.network_merged
      content {
        ipv4 {
          address = ip_config.value["address"]
          gateway = ip_config.value["gateway"]
        }
      }
    }
    vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
    user_data_file_id = proxmox_virtual_environment_file.user_data.id
  }
    # Amount of memory needed
  memory {
    dedicated = var.memory["dedicated"]
  }
  dynamic network_device {
    for_each = local.network_merged
    content {
      bridge   = network_device.value["bridge"]
      enabled  = network_device.value["enabled"]
      firewall = network_device.value["firewall"]
      model    = network_device.value["model"]
      vlan_id  = network_device.value["vlan_id"]
    }
  }
  started = true
}