vpcs = {
  "choice-vpc-1" = { vpc_name = "choice-vpc-1", vpc_cidr = "10.11.0.0/23" },
  "choice-vpc-2" = { vpc_name = "choice-vpc-2", vpc_cidr = "10.12.0.0/23" },
  "choice-vpc-3" = { vpc_name = "choice-vpc-3", vpc_cidr = "10.13.0.0/23" },
  "choice-vpc-4" = { vpc_name = "choice-vpc-4", vpc_cidr = "10.14.0.0/23" },
}
amazon_side_asn              = "64512"
account                      = "lab-test-aviatrix-aws"
region                       = "us-west-1"
tgw_attachment_subnets_cidrs = ["172.16.224.0/28", "172.16.240.0/28"]
transit_gateway_cidr_blocks  = ["10.10.0.0/24"]