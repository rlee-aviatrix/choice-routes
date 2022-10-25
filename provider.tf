terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.3"
    }
    # aviatrix = {
    #   source  = "AviatrixSystems/aviatrix"
    #   version = "2.24.1"
    # }
  }
}

provider "aws" {
  region = var.region
}

# provider "aviatrix" {
#   controller_ip           = var.controller_ip
#   username                = var.username
#   password                = var.password
#   skip_version_validation = true
#   verify_ssl_certificate  = false
# }