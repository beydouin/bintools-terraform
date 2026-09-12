# Version History

## 0.1.0 - 2026-09-12

- Created the dedicated `bintools-terraform` repository for Terraform infrastructure-as-code.
- Migrated the existing VMware vSphere normal-VM deployment configuration from `bintools-home`.
- Migrated the Oracle Linux golden-template builder for `template-01.universe.hm` from `bintools-home`.
- Added repository-level Terraform state, secret-variable, editor, and generated-file exclusions.
- Added Terraform infrastructure documentation under `documentation/`.
- Retained `vmware/vsphere` provider version `2.15.1` for the current VMware vSphere 7 environment.
