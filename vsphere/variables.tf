variable "vsphere_user" {
  description = "vCenter service account used by Terraform."
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "Password for the vCenter service account used by Terraform."
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vCenter server hostname."
  type        = string
  default     = "vcenter-00.universe.hm"
}

variable "vsphere_allow_unverified_ssl" {
  description = "Allow connection to vCenter when its certificate is not trusted by terraform-00."
  type        = bool
  default     = false
}

variable "datacenter_name" {
  description = "vSphere datacenter containing the VMs."
  type        = string
  default     = "HQ-DATACENTER"
}

variable "esxi_host_name" {
  description = "Standalone ESXi host used for deployed VMs."
  type        = string
  default     = "esxi-00.universe.hm"
}

variable "template_name" {
  description = "Golden VMware template used for normal VM deployment."
  type        = string
  default     = "template-00.universe.hm"
}

variable "template_folder" {
  description = "VM folder containing the golden template."
  type        = string
  default     = "TEMPLATES"
}

variable "default_datastore" {
  description = "Default datastore for VMs cloned from the golden template."
  type        = string
  default     = "SYNOLOGY-LUN-01"
}

variable "default_network" {
  description = "Default vSphere network for deployed VMs."
  type        = string
  default     = "VDS-VLAN30-INTERNAL1"
}

variable "default_vm_folder" {
  description = "Default VM folder for deployed VMs."
  type        = string
  default     = "SERVICES"
}

variable "default_num_cpus" {
  description = "Default vCPU count for deployed VMs."
  type        = number
  default     = 1
}

variable "default_memory_mb" {
  description = "Default memory in MB for deployed VMs."
  type        = number
  default     = 2048
}

variable "vms" {
  description = "VMs to deploy from template-00. Values override the common defaults when supplied."
  type = map(object({
    num_cpus  = optional(number)
    memory_mb = optional(number)
    datastore = optional(string)
    network   = optional(string)
    folder    = optional(string)
  }))
  default = {}
}
