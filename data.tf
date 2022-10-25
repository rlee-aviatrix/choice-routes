# data "aws_availability_zones" "aws_availability_zones-azs" {
# }
data "aws_region" "aws_region-current" {
}
# data "aviatrix_transit_gateway" "avx-transit-gw" {
#   gw_name = var.transit_gw
# }
# data "aws_vpc" "avx-transit-gw-vpc-cidr" {
#   id = data.aviatrix_transit_gateway.avx-transit-gw.vpc_id
# }

# data "aws_route_table" "avx-tgw-route-table" {
#   vpc_id = data.aviatrix_transit_gateway.avx-transit-gw.vpc_id
#   filter {
#     name   = "tag:Name"
#     values = ["*transit-Public-rtb"]
#   }
# }

data "aws_route_tables" "vpc-route-table" {
  for_each = var.vpcs
  vpc_id   = module.vpc[each.value.vpc_name].vpc_id
  filter {
    name   = "tag:Name"
    values = ["*private*", "*public*"]
  }
}
