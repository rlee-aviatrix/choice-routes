provider "aws" {
  alias   = "ps"
  profile = "ps"
  region  = var.region
}


module "ps_vpc" {
  providers = {
    aws = aws.ps

  }
  source = "terraform-aws-modules/vpc/aws"

  name = "ron-choice-vpc1"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-1a", "us-west-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


module "ps_ec2_instance" {
  providers = {
    aws = aws.ps

  }
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"



  name = "choice-instance-1"

  ami           = "ami-0a1a70369f0fce06a" # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-12-01
  instance_type = "t2.micro"
  #   key_name      = "us-west-1"
  monitoring = true
  # vpc_security_group_ids = ["sg-12345678"]
  vpc_security_group_ids = [module.ps_vpc.default_security_group_id]
  subnet_id              = module.ps_vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


resource "aws_vpc_peering_connection" "ps_peering" {
    provider = aws.ps
    vpc_id = module.ps_vpc.vpc_id
    peer_vpc_id = module.vpc["choice-vpc-1"].vpc_id
    peer_owner_id = "386869258094"
  tags = {
    Name = "VPC Peering between primary and PS account"
  }
}






resource "aws_vpc_peering_connection_accepter" "ps_peering_accept"{
vpc_peering_connection_id = aws_vpc_peering_connection.ps_peering.id
auto_accept = true
  tags = {
    Name = "VPC Peering between primary and PS account"
  }
}