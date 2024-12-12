locals {
  name = "contest"
}

provider "aws" {
  region     = "ap-northeast-2"
  access_key = var.contest_aws_access_key
  secret_key = var.contest_aws_secret_key

  default_tags {
    tags = {
      Production = local.name
      CreatedBy  = "terraform"
    }
  }
}

module "key_pair" {
  source  = "app.terraform.io/animal-squad/key-pair/aws"
  version = "1.0.1"

  name = local.name
}

module "network" {
  source  = "app.terraform.io/animal-squad/network/aws"
  version = "1.0.4"

  name_prefix    = local.name
  vpc_cidr_block = "10.0.0.0/20"

  public_subnet = {
    service_0 = {
      az         = "ap-northeast-2a"
      cidr_block = cidrsubnet("10.0.0.0/20", 3, 0)
    }
    service_1 = {
      az         = "ap-northeast-2b"
      cidr_block = cidrsubnet("10.0.0.0/20", 3, 1)
    }
    storage_0 = {
      az         = "ap-northeast-2a"
      cidr_block = cidrsubnet("10.0.0.0/20", 3, 2)
    }
    kafka = {
      az         = "ap-northeast-2a"
      cidr_block = cidrsubnet("10.0.0.0/20", 3, 6)
    }
  }

  enable_dns_hostnames = true
}
