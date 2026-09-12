data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

data "vsphere_host" "esxi" {
  name          = var.esxi_host_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "vm" {
  name          = var.vm_datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "iso" {
  name          = var.iso_datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "template" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
