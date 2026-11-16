output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.hub.id
}

output "transit_gateway_arn" {
  value = aws_ec2_transit_gateway.hub.arn
}

output "ipam_pool_id" {
  value = aws_vpc_ipam_pool.top.id
}

output "ipam_scope_id" {
  value = aws_vpc_ipam.org.private_default_scope_id
}