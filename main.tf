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
    front_end = {
      az         = "ap-northeast-2a"
      cidr_block = cidrsubnet("10.0.0.0/20", 3, 0)
    }
  }

  enable_dns_hostnames = true
}

module "security_group" {
  source  = "app.terraform.io/animal-squad/security-group/aws"
  version = "1.0.1"

  name_prefix = "${local.name}-sg"
  vpc_id      = module.network.vpc_id

  ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

module "instance" {
  source  = "app.terraform.io/animal-squad/ec2/aws"
  version = "1.0.1"

  name_prefix = "${local.name}-instance"

  ami           = "ami-0f1e61a80c7ab943e" # Amazon Linux 2023 x86_64
  az            = "ap-northeast-2a"
  instance_type = "t3.small"

  security_group_ids          = [module.security_group.id]
  subnet_id                   = module.network.public_subnets["front_end"].id
  vpc_id                      = module.network.vpc_id
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
  EOF

  key_name = module.key_pair.name
}
