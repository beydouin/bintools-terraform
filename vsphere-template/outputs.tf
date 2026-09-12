output "template_name" {
  value = vsphere_virtual_machine.template.name
}

output "template_mac_address" {
  description = "VMware-generated MAC address to pass to the DHCP automation."
  value       = vsphere_virtual_machine.template.network_interface[0].mac_address
}

output "template_reserved_ip" {
  description = "Reserved IP that DHCP must associate with the generated MAC."
  value       = var.template_ip
}
