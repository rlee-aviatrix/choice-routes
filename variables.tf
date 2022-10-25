variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpcs" {
  type = map(object({
    vpc_name = string
    vpc_cidr = string
  }))
}

variable "amazon_side_asn" {
  type    = string
  default = "64512"
}

# variable "controller_ip" {
#   type = string
# }
# variable "username" {
#   type = string
# }
# variable "password" {
#   type = string
# }

# variable "transit_gw" {
#   type = string
# }

variable "account" {
  type = string
}

variable "tgw_attachment_subnets_cidrs" {
  type = list(string)
}

variable "transit_gateway_cidr_blocks" {
  type = list(string)
}

variable "gw_size" {
  type    = string
  default = "t3.small"

}
