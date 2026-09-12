data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

data "vsphere_host" "esxi" {
  name          = var.esxi_host_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "host" {
  name          = "${var.esxi_host_name}/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.template_folder}/${var.template_name}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "vm" {
  for_each = toset(distinct(concat(
    [var.default_datastore],
    [for vm in values(var.vms) : vm.datastore if vm.datastore != null]
  )))

  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "vm" {
  for_each = toset(distinct(concat(
    [var.default_network],
    [for vm in values(var.vms) : vm.network if vm.network != null]
  )))

  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}
