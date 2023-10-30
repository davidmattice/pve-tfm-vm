##############################
# Proxmox Virtual Environment 
##############################
variable "pve_endpoint" {
    description = "Endpoint URL for PVE environment.  This must be set and passed in."
    type        = string
}
variable "pve_user" {
    description = "User name for Terraform Updates.  This must be set and passed in.  Also, set the PROXMOX_VE_PASSWORD environment variable."
    type        = string
}

variable "pve_host_name" {
    description = "PVE hostname to create this template on.  Defaults to first host in the Cluster."
    type        = string
    default     = ""
}

##############################
# Template selection for cloning
##############################
variable "template_tags" {
    description = "Set to a list of Tag on the template to be used for cloning."
    type = list(string)
}

##############################
# Virtual Machine Settings
##############################
variable "name" {
    description = "Descriptive Name for this Virtual Machine."
    type        = string
}
variable "node_name" {
    description = "Node or Host name for this Virtual Machine."
    type        = string
}

variable "cpu" {
    description = ""
    type        = object({
      cores = optional(string, "1")
      numa  = optional(boolean, true)
      sockets = optional(string, "1")
    })
}
variable "memory" {
    description = ""
    type        = object({
      dedicated = optional(string,"512") 
    })
}
variable "network" {
    description = ""
    type        = object({
      gateway = optional(string,null)
      address = optional(string,"dhcp")
    })
}
variable "description" {
    description = "Description of this Virtual Machine. Defaults to the Template ID used for the Clone."
    type        = string
    default     = ""
}
variable "storage_pool" {
    description = "Storage Pool to use for this Virtual Machine."
  type    = string
  default = "local"
}
variable "additional_tags" {
    description = "Additional custom tags to add to the template being created."
    type        = list(string)
    default     = []
}
variable "custom_user_data_file" {
    description = "Set to the path to a custom cloud init user data file, if needed."
    type        = string
    default     = ""
}
variable "custom_vendor_config_file" {
    description = "Set to the path to a custom cloud init vendor config file, if needed."
    type        = string
    default     = ""
}