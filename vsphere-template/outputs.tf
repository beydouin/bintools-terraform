output "template_name" {
  value = vsphere_virtual_machine.template.name
}

output "template_mac_address" {
  description = "NIC is attached by Ansible after VM creation; MAC is obtained from vCenter."
  value       = null
}

output "template_reserved_ip" {
  description = "Reserved IP that DHCP must associate with the generated MAC."
  value       = var.template_ip
}
