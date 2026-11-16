primary_region   = "ap-south-1"
approved_regions = ["ap-south-1"]

owner_email  = "platform@opstree.com"
cost_center  = "CC-1042"

# Phase 1: organization + account vending (email only)
enable_organization      = true
create_member_accounts   = true
enable_bootstrap         = false
enable_log_archive       = false
enable_audit             = false
enable_network           = false
enable_finops            = false
enable_organization_cloudtrail = false

# Override emails — IDs appear in output after apply; paste into account_ids for phase 2
member_accounts = {}
account_ids     = {}

# Phase 2 example (after apply):
# account_ids = { log_archive = "123456789012", audit = "234567890123", network = "345678901234", shared = "456789012345" }
# enable_log_archive = true
# enable_audit = true
# bucket_name_prefix = "opstree-logs-unique"