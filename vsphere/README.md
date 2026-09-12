# vSphere Terraform

This project deploys normal VMs by cloning the existing golden VMware template `template-00.universe.hm`.

## Current topology and defaults

- vCenter: `vcenter-00.universe.hm`
- Datacenter: `HQ-DATACENTER`
- Standalone ESXi host: `esxi-00.universe.hm`
- Source template folder: `TEMPLATES`
- Source template: `template-00.universe.hm`
- Source template datastore: `LocalDS_esxi-00.universe.hm`
- Deployment datastore: `SYNOLOGY-LUN-01`
- Deployment network: `VDS-VLAN30-INTERNAL1`
- Deployment folder: `SERVICES`
- CPU: 1 vCPU
- Memory: 2048 MB

There is no vSphere compute cluster in the current environment. Terraform deploys VMs into the standalone `esxi-00.universe.hm` host resource pool.

The golden template remains on `LocalDS_esxi-00.universe.hm`; normal VMs cloned from it are placed on `SYNOLOGY-LUN-01` by default. A VM definition may override the deployment datastore without changing the template location.

## Provider

The vSphere provider is pinned to `2.15.1` for the current VMware vSphere 7 environment.

## Credentials

Do not commit vCenter passwords or private keys. Use a dedicated vCenter service account and provide credentials through an approved secret mechanism.

## Workflow

Run this project on `terraform-00` from the checked-out `bintools-terraform/vsphere` directory.

```bash
terraform init
terraform plan
terraform apply
```

Always review the plan before applying it. A plan that proposes changes to infrastructure outside the intended VM set must be investigated before continuing.
