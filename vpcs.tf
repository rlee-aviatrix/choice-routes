module "vpc" {
  for_each        = var.vpcs
  source          = "terraform-aws-modules/vpc/aws"
  name            = each.value.vpc_name
  azs             = formatlist("${data.aws_region.aws_region-current.name}%s", ["a", "b"])
  cidr            = each.value.vpc_cidr
  private_subnets = slice(cidrsubnets(each.value.vpc_cidr, 4, 4, 4, 4, 4, 4), 0, 4)
  public_subnets  = slice(cidrsubnets(each.value.vpc_cidr, 4, 4, 4, 4, 4, 4), 4, 6)
}