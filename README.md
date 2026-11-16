# OpsTree AWS Organization — Terraform

Root-level IaC for the OpsTree landing zone. All reusable code lives under **`modules/`** (including SCP JSON under `modules/scp/policies/`).

## Layout

```
.
├── main.tf              # Composition of all layers (toggle via variables)
├── variables.tf
├── outputs.tf
├── locals.tf
├── providers.tf
├── versions.tf
├── terraform.tfvars     # Your environment values (committed template; adjust emails)
├── terraform.tfvars.example
└── modules/
    ├── organization/
    ├── scp/policies/
    ├── log-archive/
    ├── audit-account/
    ├── network-hub/
    └── ...
```

## Apply phases

1. Set account **emails** in `terraform.tfvars`, `enable_organization = true`, member layers `false`. Run `terraform apply`.
2. Copy `account_ids` from output into `terraform.tfvars`, set `account_ids` and enable `enable_log_archive`, `enable_audit`, `enable_network`, etc.
3. Set `enable_organization_cloudtrail` with bucket/KMS from log archive outputs.

## Commands

```bash
terraform init
terraform validate
terraform plan
```

See `docs/DEPLOYMENT.md` for layer details.