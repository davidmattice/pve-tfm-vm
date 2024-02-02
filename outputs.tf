output "vm" {
  description = "Virtual Machine confiruration."
  value       = proxmox_virtual_environment_vm.vm
}

output "nodes" {
  description = "List of PVE nodes in the cluster pointed to by the PROXMOX Endpoint."
  value       = data.proxmox_virtual_environment_nodes.pve
}

output "datastores" {
  description = "List of datastores found on the PVE node."
  value       = data.proxmox_virtual_environment_datastores.pve
}

output "dns" {
  description = "DNS configuration of the PVE node."
  value       = data.proxmox_virtual_environment_dns.pve_node
}

output "network" {
  value = local.network_merged
}