# Terraform + PXE Golden Template Build

## Purpose

This runbook documents the rebuild path for a new Oracle Linux golden template. The existing `template-00.universe.hm` is the known-good fallback and must not be modified by this procedure.

The first automated build target is:

- VM: `template-01.universe.hm`
- DNS service name: `template-01.universe.hm`
- Canonical DNS name: `ianthinite.universe.hm`
- Reserved IP: `192.168.3.11`
- vCenter: `vcenter-00.universe.hm`
- Datacenter: `HQ-DATACENTER`
- ESXi host: `esxi-00.universe.hm`
- Folder: `TEMPLATES`
- VM datastore: `SYNOLOGY-LUN-01`
- Network: `VDS-VLAN30-INTERNAL1`
- PXE server: `pxe-00.universe.hm`
- Installation DVD datastore: `ISO`
- Installation DVD: `LINUX/oracle_linux/10/OracleLinux-R10-U0-x86_64-dvd.iso`

## Hardware definition

Terraform creates the VM from scratch with:

- 1 vCPU
- 2048 MB RAM
- EFI firmware
- VMware Paravirtual SCSI (`pvscsi`)
- VMXNET3 network adapter
- 6 GB disk 0
- 61 GB disk 1

The storage layout inside the guest is created later by Kickstart. Do not change the disk sizes without also reviewing the Kickstart storage definition.

## Prerequisites

Run Terraform on `terraform-00`. The `bintools-terraform` repository must be checked out there from the internal Gitea service before running this procedure.

Confirm Terraform is installed:

```bash
terraform version
```

Expected current installation:

```text
Terraform v1.16.2
on linux_amd64
```

If `terraform` is missing, rebuild the Terraform tooling using the `build_terraform` Ansible playbook in `bintools-home` before continuing.

Confirm the working tree contains the template project:

```bash
cd ~/bintools-terraform/vsphere-template
ls
```

At minimum, the directory must contain `data.tf`, `main.tf`, `outputs.tf`, `provider.tf`, `variables.tf`, and `versions.tf`.

If those files are missing, do not create them manually on `terraform-00`. Correct the Gitea repository synchronization or checkout and restore the tracked repository contents first.

## Credentials

Do not store vCenter credentials in Git.

Before Terraform commands, supply the approved vCenter credentials through environment variables:

```bash
export TF_VAR_vsphere_user='<vCenter service account>'
export TF_VAR_vsphere_password='<vCenter password>'
```

Do not place the real password in `terraform.tfvars`, shell scripts, Markdown documentation, or Git history.

## Phase 1 - initialize Terraform

From `terraform-00`:

```bash
cd ~/bintools-terraform/vsphere-template
terraform init
```

The initialization must install/use `vmware/vsphere` version `2.15.1`.

If a different provider version is selected, inspect `versions.tf`:

```bash
cat versions.tf
```

It must contain:

```hcl
terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "= 2.15.1"
    }
  }
}
```

If the file is correct but the provider cache is wrong, remove only the generated provider directory and reinitialize:

```bash
rm -rf .terraform
terraform init
```

Do not delete Terraform state as part of provider troubleshooting.

## Phase 2 - review the blank-VM plan

Run:

```bash
terraform plan
```

The plan must create exactly one new VM named `template-01.universe.hm` with the hardware listed above. It must not modify or destroy `template-00.universe.hm` or any existing VM.

If the plan proposes any unexpected modification or destruction, do not apply it. Inspect the current configuration and Terraform state:

```bash
terraform state list
terraform show
```

Correct the configuration/state discrepancy before continuing.

## Phase 3 - create the VM and capture the VMware MAC

Create the VM:

```bash
terraform apply
```

After apply completes, retrieve the VMware-generated MAC:

```bash
terraform output -raw template_mac_address
```

Confirm the intended reservation:

```bash
terraform output -raw template_reserved_ip
```

Expected IP:

```text
192.168.3.11
```

If the MAC output is empty, do not invent a MAC. In vCenter, open `template-01.universe.hm` -> Edit Settings -> Network adapter and confirm VMware assigned a MAC. Then refresh Terraform state:

```bash
terraform refresh
terraform output -raw template_mac_address
```

If Terraform still does not report the VMware-assigned MAC, stop before changing DHCP and inspect the provider state.

## Phase 4 - DHCP registration

The generated MAC must be associated with:

```text
template-01 -> 192.168.3.11
```

DHCP configuration is owned by Ansible in `bintools-home`. The permanent DHCP source must receive the generated MAC; changing only the live Kea configuration is not sufficient because a future `updatedhcp` run would overwrite an untracked change.

After the reservation is persisted in the Ansible source, deploy DHCP using the established `updatedhcp` workflow.

Before rebooting the VM, confirm Kea configuration validation succeeds and the reservation exists. If validation fails or the reservation is absent, correct the Ansible DHCP source and rerun `updatedhcp`; do not proceed to PXE installation.

## Phase 5 - attach the exact installation DVD

After DHCP registration is complete, set the Terraform input `attach_install_iso` to `true` using an approved local variable mechanism. Do not commit credentials or local secret variable files.

Review the change:

```bash
terraform plan -var='attach_install_iso=true'
```

The plan must only add the Oracle Linux 10.0 U0 DVD to `template-01.universe.hm`. It must not replace the VM, destroy disks, or modify another VM.

If the plan is correct, apply the same input:

```bash
terraform apply -var='attach_install_iso=true'
```

If Terraform proposes VM replacement or unrelated changes, stop and inspect the configuration/state before applying.

## Phase 6 - PXE installation

Reboot `template-01.universe.hm` only after its generated MAC is present in Kea and the U0 DVD is attached.

The expected installation chain is:

```text
VM EFI firmware
  -> Kea DHCP
  -> pxe-00.universe.hm
  -> UEFI shim/GRUB
  -> Oracle Linux 10.0 U0 installer kernel/initrd
  -> Kickstart
  -> inst.repo=cdrom
  -> attached OracleLinux-R10-U0-x86_64-dvd.iso
```

If PXE does not start, use the PXE rebuild/troubleshooting runbook in `bintools-home/documentation/pxe/PXE_SERVER.md` to correct DHCP/PXE service state before changing this Terraform VM definition.

If Anaconda starts but cannot find its installation source, verify in vCenter that the VM has the exact U0 ISO connected. Then inspect the PXE GRUB configuration managed by Ansible and correct it if `inst.repo=cdrom` is absent.

## Final template preparation

After unattended installation and Ansible baseline configuration complete, the final sealing procedure must remove SSH host keys and clear `/etc/machine-id` immediately before shutdown.

Do not boot the sealed VM again before conversion to a VMware Template.

The final promotion/conversion step remains separate from initial Terraform VM creation. Never overwrite or convert `template-00.universe.hm` during this procedure.

## Validation checklist and corrective actions

- `template-00.universe.hm` remains untouched. If Terraform proposes changing it, stop and correct configuration/state before applying.
- `template-01.universe.hm` exists in `HQ-DATACENTER/TEMPLATES`. If not, inspect the Terraform apply result and vCenter task/event errors before rerunning apply.
- Hardware is 1 vCPU, 2048 MB RAM, 6 GB + 61 GB disks, PVSCSI, VMXNET3, EFI. If not, correct `vsphere-template/main.tf`, review `terraform plan`, and apply only the intended correction.
- Terraform reports a non-empty VMware-generated MAC. If empty, use `terraform refresh`; never invent a MAC.
- Kea maps that MAC to `192.168.3.11` with hostname `template-01`. If not, correct the Ansible DHCP source and rerun `updatedhcp`.
- DNS resolves `template-01.universe.hm` through `ianthinite.universe.hm` to `192.168.3.11`. If not, correct the authoritative Ansible DNS source and deploy it with the established DNS workflow.
- The attached installation media is Oracle Linux 10.0 U0. If not, correct `install_iso_path`, review the plan, and apply only the CD-ROM correction.
- PXE loads from `pxe-00.universe.hm`. If not, follow the PXE server runbook and repair DHCP/TFTP/PXE services before changing the VM.
- Kickstart completes using the attached DVD as `inst.repo=cdrom`. If not, correct the Ansible-managed PXE/Kickstart configuration and rebuild/deploy it.
- Final Ansible configuration and sealing complete successfully. If not, do not convert the VM to a template; repair and rerun the appropriate Ansible build/sealing workflow.
- Convert the finished VM to a VMware Template only after every preceding validation passes.
