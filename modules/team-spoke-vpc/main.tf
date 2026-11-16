data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.name
  cidr = var.cidr_block

  azs             = local.azs
  private_subnets = [for i, az in local.azs : cidrsubnet(var.cidr_block, 4, i)]
  public_subnets  = [for i, az in local.azs : cidrsubnet(var.cidr_block, 8, i + 48)]

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags               = var.tags
  private_subnet_tags  = merge(var.tags, { Tier = "private" })
  public_subnet_tags   = merge(var.tags, { Tier = "public" })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  count = var.transit_gateway_id != null ? 1 : 0

  subnet_ids         = module.vpc.private_subnets
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.vpc.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-tgw-attachment" })
}