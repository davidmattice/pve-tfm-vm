##############################
# Proxmox Virtual Environment 
##############################
variable "pve_host_name" {
    description = "PVE hostname to create this template on.  Defaults to first host in the Cluster."
    type        = string
    default     = ""
}

##############################
# Template selection for cloning
##############################
variable "template_id" {
    description = "This is the ID of the template to be used for cloning."
    type = string
}

##############################
# Virtual Machine Settings
##############################
variable "name" {
    description = "Hostname for this Virtual Machine."
    type        = string
}
variable "node_name" {
    description = "PVE node to put this Virtual Machine on."
    type        = string
}

variable "cpu" {
    description = ""
    type        = object({
      cores     = optional(string, "1")
      numa      = optional(bool, true)
      sockets   = optional(string, "1")
    })
    default     = {}
}
variable "memory" {
    description = ""
    type        = object({
      dedicated = optional(string,"512") 
    })
    default     = {}
}
variable "network" {
    description = ""
    type        = object({
      gateway   = optional(string,null)
      address   = optional(string,"dhcp")
    })
    default     = {}
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