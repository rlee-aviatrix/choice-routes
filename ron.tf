output "list_of_vpcs" {
  value = local.list_of_vpcs
}

output "cidr_to_pcx_map" {
  value = local.cidr_to_pcx_map
}

output "list_of_rts" {
  value = local.list_of_rts
}

output "rt_to_cidr_map" {
  value = local.rt_to_cidr_map
}

output "ron" {
  value = local.ron
}

output "ron2" {
  value = local.ron2
}

output "vpc_id_to_cidr_map" {
  value = local.vpc_id_to_cidr_map
}

output "vpc-route-table" {
  value = data.aws_route_tables.vpc-route-table
}
