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
  type    = string
  default = "HQ-DATACENTER"
}

variable "esxi_host_name" {
  type    = string
  default = "esxi-00.universe.hm"
}

variable "vm_datastore_name" {
  type    = string
  default = "SYNOLOGY-LUN-01"
}

variable "iso_datastore_name" {
  type    = string
  default = "ISO"
}

variable "network_name" {
  type    = string
  default = "VDS-VLAN30-INTERNAL1"
}

variable "template_folder" {
  type    = string
  default = "TEMPLATES"
}

variable "template_name" {
  type    = string
  default = "template-01.universe.hm"
}

variable "template_ip" {
  description = "Reserved DHCP identity assigned after VMware generates the VM MAC address."
  type        = string
  default     = "192.168.3.11"
}

variable "install_iso_path" {
  description = "Path inside the ISO datastore for the exact Oracle Linux 10.0 U0 DVD."
  type        = string
  default     = "LINUX/oracle_linux/10/OracleLinux-R10-U0-x86_64-dvd.iso"
}

variable "attach_install_iso" {
  description = "Attach the OL10 U0 DVD after the generated MAC has been registered in DHCP."
  type        = bool
  default     = false
}
