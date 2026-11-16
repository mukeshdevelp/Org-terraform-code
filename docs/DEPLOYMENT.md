# Deployment

All infrastructure is managed from the **repository root** (no `live/` stacks).

| Toggle | Layer |
|--------|--------|
| `enable_organization` | OUs, accounts (email vending), SCPs, Identity Center permission sets |
| `enable_bootstrap` | S3/DynamoDB state in Shared Services (`account_ids.shared` required) |
| `enable_log_archive` | Central log buckets in Log Archive account |
| `enable_audit` | GuardDuty, Security Hub, Config aggregator |
| `enable_network` | TGW + IPAM in Network account |
| `enable_finops` | CUR + budgets in management account |
| `enable_organization_cloudtrail` | Org trail in management → log archive bucket |

Provider aliases for member accounts use `var.account_ids` (populated from `output.account_ids` after vending).