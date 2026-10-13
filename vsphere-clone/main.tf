# Safe, separate Terraform configuration for cloning an existing vSphere template.
# The source template is read-only; this configuration never manages its lifecycle.
terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = false
}

variable "vsphere_user" {
  type = string
  sensitive = true
}
variable "vsphere_password" {
  type = string
  sensitive = true
}
variable "vsphere_server" {
  type = string
  default = "vcenter-00.universe.hm"
}
variable "datacenter_name" {
  type = string
  default = "HQ-DATACENTER"
}
variable "source_template_name" {
  type = string
  default = "template-00.universe.hm"
}
variable "vm_name" {
  type = string
}
variable "vm_folder" {
  type = string
}
variable "esxi_host_name" {
  type = string
  default = "esxi-00.universe.hm"
}
variable "datastore_name" {
  type = string
}
variable "network_name" {
  type = string
}
variable "num_cpus" {
  type = number
  default = 1
}
variable "memory_mb" {
  type = number
  default = 2048
}

data "vsphere_datacenter" "dc" { name = var.datacenter_name }
data "vsphere_virtual_machine" "source" {
  name          = var.source_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_host" "esxi" {
  name          = var.esxi_host_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_datastore" "ds" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "net" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "clone" {
  name             = var.vm_name
  folder           = var.vm_folder
  resource_pool_id = data.vsphere_host.esxi.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id
  num_cpus         = var.num_cpus
  memory           = var.memory_mb
  guest_id         = data.vsphere_virtual_machine.source.guest_id
  firmware         = data.vsphere_virtual_machine.source.firmware
  scsi_type        = data.vsphere_virtual_machine.source.scsi_type

  network_interface {
    network_id   = data.vsphere_network.net.id
    adapter_type = data.vsphere_virtual_machine.source.network_interface_types[0]
  }

  dynamic "disk" {
    for_each = data.vsphere_virtual_machine.source.disks
    content {
      label            = disk.value.label
      size             = disk.value.size
      unit_number      = disk.value.unit_number
      thin_provisioned = disk.value.thin_provisioned
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.source.id
  }

  wait_for_guest_ip_timeout  = 0
  wait_for_guest_net_timeout = 0
}

output "clone_name" {
  value = vsphere_virtual_machine.clone.name
}
output "clone_mac_address" {
  value = vsphere_virtual_machine.clone.network_interface[0].mac_address
}
