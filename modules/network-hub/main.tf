terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws]
    }
  }
}

resource "aws_ec2_transit_gateway" "hub" {
  description                     = "OpsTree centralized transit hub"
  amazon_side_asn                 = var.amazon_side_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(var.tags, { Name = var.transit_gateway_name })
}

resource "aws_ec2_transit_gateway_route_table" "team_template" {
  transit_gateway_id = aws_ec2_transit_gateway.hub.id

  tags = merge(var.tags, {
    Name        = "team-segment-template"
    Description = "Duplicate per team; default-deny east-west"
  })
}

resource "aws_vpc_ipam" "org" {
  operating_regions {
    region_name = var.region
  }

  tags = merge(var.tags, { Name = "opstree-ipam" })
}

resource "aws_vpc_ipam_pool" "top" {
  ipam_scope_id                     = aws_vpc_ipam.org.private_default_scope_id
  locale                            = var.ipam_pool_locale
  address_family                    = "ipv4"
  allocation_default_netmask_length = 16
  auto_import                       = false

  tags = merge(var.tags, { Name = "opstree-top-pool" })
}

resource "aws_vpc_ipam_pool_cidr" "top" {
  ipam_pool_id = aws_vpc_ipam_pool.top.id
  cidr         = "10.0.0.0/8"
}

resource "aws_vpc_ipam_pool" "team" {
  for_each = var.ipam_pools

  address_family      = "ipv4"
  locale              = var.ipam_pool_locale
  ipam_scope_id       = aws_vpc_ipam.org.private_default_scope_id
  source_ipam_pool_id = aws_vpc_ipam_pool.top.id
  description         = each.value.description

  tags = merge(var.tags, {
    Name = "pool-${each.key}"
    Team = each.key
  })
}

resource "aws_vpc_ipam_pool_cidr" "team" {
  for_each = var.ipam_pools

  ipam_pool_id = aws_vpc_ipam_pool.team[each.key].id
  cidr         = each.value.cidr
}

resource "aws_ram_resource_share" "tgw" {
  name                      = "opstree-tgw-share"
  allow_external_principals = false

  tags = var.tags
}

resource "aws_ram_resource_association" "tgw" {
  resource_arn       = aws_ec2_transit_gateway.hub.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}