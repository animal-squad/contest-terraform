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
    web_0 = {
      az         = "ap-northeast-2a"
      cidr_block = cidrsubnet("10.0.0.0/20", 3, 0)
    }
    web_1 = {
      az         = "ap-northeast-2b"
      cidr_block = cidrsubnet("10.0.0.0/20", 3, 1)
    }
    redis = {
      az         = "ap-northeast-2a"
      cidr_block = cidrsubnet("10.0.0.0/20", 3, 2)
    }
    mongo = {
      az         = "ap-northeast-2a"
      cidr_block = cidrsubnet("10.0.0.0/20", 3, 3)
    }
    server_0 = {
      az         = "ap-northeast-2a"
      cidr_block = cidrsubnet("10.0.0.0/20", 3, 4)
    }
    server_1 = {
      az         = "ap-northeast-2b"
      cidr_block = cidrsubnet("10.0.0.0/20", 3, 5)
    }
  }

  enable_dns_hostnames = true
}
