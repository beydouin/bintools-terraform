resource "vsphere_virtual_machine" "vm" {
  for_each = var.vms

  name             = each.key
  folder           = coalesce(each.value.folder, var.default_vm_folder)
  resource_pool_id = data.vsphere_resource_pool.host.id
  datastore_id     = data.vsphere_datastore.vm[coalesce(each.value.datastore, var.default_datastore)].id
  host_system_id   = data.vsphere_host.esxi.id

  num_cpus = coalesce(each.value.num_cpus, var.default_num_cpus)
  memory   = coalesce(each.value.memory_mb, var.default_memory_mb)

  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.vm[coalesce(each.value.network, var.default_network)].id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }
}
