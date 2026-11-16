provider "aws" {
  region = var.primary_region

  default_tags {
    tags = module.common_tags.tags
  }
}

# Member-account providers (account IDs from var.account_ids after vending or first apply output).

provider "aws" {
  alias  = "shared"
  region = var.primary_region

  assume_role {
    role_arn = "arn:aws:iam::${lookup(var.account_ids, "shared", "000000000000")}:role/${var.organization_access_role_name}"
  }
}

provider "aws" {
  alias  = "log_archive"
  region = var.primary_region

  assume_role {
    role_arn = "arn:aws:iam::${lookup(var.account_ids, "log_archive", "000000000000")}:role/${var.organization_access_role_name}"
  }
}

provider "aws" {
  alias  = "audit"
  region = var.primary_region

  assume_role {
    role_arn = "arn:aws:iam::${lookup(var.account_ids, "audit", "000000000000")}:role/${var.organization_access_role_name}"
  }
}

provider "aws" {
  alias  = "network"
  region = var.primary_region

  assume_role {
    role_arn = "arn:aws:iam::${lookup(var.account_ids, "network", "000000000000")}:role/${var.organization_access_role_name}"
  }
}