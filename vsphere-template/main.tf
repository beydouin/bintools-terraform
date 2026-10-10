resource "vsphere_virtual_machine" "template" {
  name             = var.template_name
  folder           = var.template_folder
  resource_pool_id = data.vsphere_host.esxi.resource_pool_id
  datastore_id     = data.vsphere_datastore.vm.id
  host_system_id   = data.vsphere_host.esxi.id

  num_cpus = 1
  memory   = 2048

  guest_id  = "rhel9_64Guest"
  firmware  = "efi"
  scsi_type = "pvscsi"

  # Retain VMware VM execution logs for boot and installer diagnostics.
  enable_logging = true

  # Ansible configures the actual vSphere boot device order after Terraform apply.

  # PXE boots the installer; Anaconda retrieves installation packages over HTTP.

  wait_for_guest_ip_timeout  = 0
  wait_for_guest_net_timeout = 0

  annotation = <<-EOT
    Oracle Linux 10.0 Golden Template Build
    OS: Oracle Linux
    Release: 10.0 (U0)
    Architecture: x86_64
    Purpose: Base golden template for Terraform-provisioned Linux VMs
    Installation Source: HTTP repository on pxe-00.universe.hm
    Managed by: Terraform / Ansible
  EOT

  network_interface {
    network_id     = data.vsphere_network.template.id
    adapter_type   = "vmxnet3"
    use_static_mac = var.template_mac_address != null
    mac_address    = var.template_mac_address
  }

  disk {
    label            = "disk0"
    size             = 6
    unit_number      = 0
    thin_provisioned = true
  }

  disk {
    label            = "disk1"
    size             = 61
    unit_number      = 1
    thin_provisioned = true
  }

  dynamic "cdrom" {
    for_each = var.attach_install_iso ? [1] : []

    content {
      datastore_id = data.vsphere_datastore.iso.id
      path         = var.install_iso_path
    }
  }
}
