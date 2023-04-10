locals {
  list_of_vpcs = [
    for x in var.vpcs : x.vpc_cidr
  ]

  connections = flatten([
    for vpc in local.list_of_vpcs : [
      for peer_vpc in slice(local.list_of_vpcs, index(local.list_of_vpcs, vpc) + 1, length(local.list_of_vpcs)) : {
        vpc1 = vpc
        vpc2 = peer_vpc
      }
    ]
  ])

  connections_map = {
    for connection in local.connections : "${connection.vpc1}:${connection.vpc2}" => connection
  }

  cidr_to_pcx_map = {
    for z in setproduct(local.list_of_vpcs, local.list_of_vpcs) :
    "${z[0]}:${z[1]}" => try(aws_vpc_peering_connection.peering["${z[0]}:${z[1]}"].id, aws_vpc_peering_connection.peering["${z[1]}:${z[0]}"].id) if "${z[0]}" != "${z[1]}"
  }

  rt_to_cidr_map = {
    for rt in local.list_of_rts :
    # rt => data.aws_route_table.rt[rt].vpc_id
    rt => local.vpc_id_to_cidr_map[data.aws_route_table.rt[rt].vpc_id]
  }

  vpc_id_to_cidr_map = {
    for x in var.vpcs :
    module.vpc[x.vpc_name].vpc_id => x.vpc_cidr

  }


  list_of_rts = flatten([
    for x in var.vpcs :
    data.aws_route_tables.vpc-route-table[x.vpc_name].ids
  ])

  ron = [
    for x in setproduct(local.list_of_rts, local.list_of_vpcs) :
    {
      route_table_id         = x[0]
      destination_cidr_block = x[1]
      source_cidr_block      = local.rt_to_cidr_map[x[0]]

    }
  ]

  ron2 = {
    for x in setproduct(local.list_of_rts, local.list_of_vpcs) :
    "${x[0]}:${x[1]}" => {
      route_table_id         = x[0]
      destination_cidr_block = x[1]
      source_cidr_block      = local.rt_to_cidr_map[x[0]]
      cidr_string            = "${local.rt_to_cidr_map[x[0]]}:${x[1]}"
    }
    if local.rt_to_cidr_map[x[0]] != x[1]
  }

}

data "aws_vpc" "list_of_vpcs" {
  for_each   = toset(local.list_of_vpcs)
  cidr_block = each.value
  depends_on = [module.vpc]
}

resource "aws_vpc_peering_connection" "peering" {
  for_each    = local.connections_map
  peer_vpc_id = data.aws_vpc.list_of_vpcs[each.value.vpc1].id
  vpc_id      = data.aws_vpc.list_of_vpcs[each.value.vpc2].id
  auto_accept = true
}

data "aws_route_table" "rt" {
  for_each       = toset(local.list_of_rts)
  route_table_id = each.key
}


resource "aws_route" "r" {
  for_each                  = local.ron2
  route_table_id            = each.value.route_table_id
  destination_cidr_block    = each.value.destination_cidr_block
  vpc_peering_connection_id = local.cidr_to_pcx_map[each.value.cidr_string]

}
