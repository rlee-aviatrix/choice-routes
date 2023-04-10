module "vpc" {
  for_each        = var.vpcs
  source          = "terraform-aws-modules/vpc/aws"
  name            = each.value.vpc_name
  azs             = formatlist("${data.aws_region.aws_region-current.name}%s", ["a", "b"])
  cidr            = each.value.vpc_cidr
  private_subnets = slice(cidrsubnets(each.value.vpc_cidr, 4, 4, 4, 4, 4, 4), 0, 4)
  public_subnets  = slice(cidrsubnets(each.value.vpc_cidr, 4, 4, 4, 4, 4, 4), 4, 6)
}



module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  # for_each = toset(["one", "two", "three"])
  for_each = toset(["choice-vpc-1", "choice-vpc-2", "choice-vpc-3", "choice-vpc-4"])

  name = "choice-instance-${each.key}"

  ami           = "ami-0a1a70369f0fce06a" # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-12-01
  instance_type = "t2.micro"
  key_name      = "us-west-1"
  monitoring    = true
  # vpc_security_group_ids = ["sg-12345678"]
  vpc_security_group_ids = [module.vpc[each.value].default_security_group_id]
  subnet_id              = module.vpc[each.value].public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


module "ec2_instance2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  # for_each = toset(["one", "two", "three"])
  for_each = toset(["choice-vpc-1", "choice-vpc-2", "choice-vpc-3", "choice-vpc-4"])

  name = "choice-instance2-${each.key}"

  ami           = "ami-0a1a70369f0fce06a" # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-12-01
  instance_type = "t2.micro"
  key_name      = "us-west-1"
  monitoring    = true
  # vpc_security_group_ids = ["sg-12345678"]
  vpc_security_group_ids = [module.vpc[each.value].default_security_group_id]
  subnet_id              = module.vpc[each.value].public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


resource "aws_security_group" "sg-tfsg" {
  name   = "TFSG-should-be-skipped"
  vpc_id = module.vpc["choice-vpc-1"].vpc_id
}

resource "aws_security_group" "sg-tfsg2" {
  name   = "TFSG-should-be-skipped2"
  vpc_id = module.vpc["choice-vpc-1"].vpc_id

  ingress {
    description     = "Inbound from referenced SG"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.vpc["choice-vpc-2"].default_security_group_id]
  }
}

resource "aws_security_group_rule" "self1" {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  type = "ingress"
  security_group_id = aws_security_group.sg1.id
  self = true
  description = "Inbound referencing itself"

}


resource "aws_security_group" "sg1" {
  name   = "choice-vpc1-sg1"
  vpc_id = module.vpc["choice-vpc-1"].vpc_id

  ingress {
    description     = "Inbound from referenced SG"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.vpc["choice-vpc-2"].default_security_group_id]

  }


  ingress {
    description = "Inbound with no references"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Inbound from referenced SG range of ports"
    from_port       = 100
    to_port         = 102
    protocol        = "tcp"
    security_groups = [module.vpc["choice-vpc-2"].default_security_group_id]
  }

  ingress {
    description     = "Inbound from referenced SG unused in choice-vpc-4"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.unused.id]

  }

  ingress {
    description     = "Inbound from a different AWS account"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.ps_vpc.default_security_group_id]

  }

  ingress {
    description     = "Inbound from a different AWS account all traffic"
    from_port       = -1
    to_port         = -1
    protocol        = "ALL"
    security_groups = [module.ps_vpc.default_security_group_id]

  }


  ingress {
    description     = "Inbound from a different AWS account ICMP"
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [module.ps_vpc.default_security_group_id]

  }

  ingress {
    description = "Inbound with no references but overlaps with other rules"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/24"]
  }

  ingress {
    description = "Inbound with no references but overlaps with other rules 2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"]
  }

  ingress {
    description     = "Inbound from referenced SG and overlaps with other rules"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.vpc["choice-vpc-2"].default_security_group_id]

  }

  ingress {
    description     = "Inbound PL and overlaps with other rules"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids =  [aws_ec2_managed_prefix_list.example.id]

  }

  ingress {
    description     = "Inbound PL no overlap with other rules"
    from_port       = 81
    to_port         = 81
    protocol        = "tcp"
    prefix_list_ids =  [aws_ec2_managed_prefix_list.example.id]

  }


  ingress {
    description     = "Inbound PL AWS rule"
    from_port       = 82
    to_port         = 82
    protocol        = "tcp"
    prefix_list_ids =  ["pl-4ea04527"]

  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [module.vpc["choice-vpc-3"].default_security_group_id]
  }


  egress {
    description = "Outbound with no references"
    from_port   = 23
    to_port     = 23
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description     = "Outbound to referenced SG unused in choice-vpc-4"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.unused.id]

  }

  egress {
    description     = "Outbound to referenced SG range of ports"
    from_port       = 200
    to_port         = 202
    protocol        = "tcp"
    security_groups = [module.vpc["choice-vpc-2"].default_security_group_id]
  }

  egress {
    description     = "Outbound to a different AWS account"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.ps_vpc.default_security_group_id]

  }


  egress {
    description = "Outbound with no references but overlaps with other rules"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"]

  }


  tags = {
    Name = "choice-vpc1-sg1"
  }

}



resource "aws_security_group" "unused" {
  name   = "choice-unused-sg"
  vpc_id = module.vpc["choice-vpc-4"].vpc_id

  tags = {
    Name = "choice-vpc-4-unused-sg1"
  }
}

resource "aws_ec2_managed_prefix_list" "example" {
  name           = "Sample Choice CIDRs"
  address_family = "IPv4"
  max_entries    = 5

  entry {
    cidr        = "192.168.0.0/24"
    description = "Primary"
  }

  entry {
    cidr        = "10.0.0.0/16"
    description = "Secondary"
  }

  tags = {
    Env = "Choice"
  }
}