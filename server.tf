
module "security_group_server" {
  source  = "app.terraform.io/animal-squad/security-group/aws"
  version = "1.0.1"

  name_prefix = "${local.name}-server-sg"
  vpc_id      = module.network.vpc_id

  ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    server = {
      from_port   = 5000
      to_port     = 5000
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.0.0/20"
    }
  }
}

module "instance_server" {
  for_each = {
    server_0 = {
      az = "ap-northeast-2a"
    }
    server_1 = {
      az = "ap-northeast-2b"
    }
  }

  source  = "app.terraform.io/animal-squad/ec2/aws"
  version = "1.0.2"

  name_prefix = "${local.name}-instance-${each.key}"

  ami           = "ami-0d81776ee23e75c00" # Amazon Linux 2023 x86_64 with docker
  az            = each.value.az
  instance_type = "t3.small"

  security_group_ids          = [module.security_group_server.id]
  subnet_id                   = module.network.public_subnets[each.key].id
  vpc_id                      = module.network.vpc_id
  associate_public_ip_address = true

  root_volume_size = 50

  key_name = module.key_pair.name
}
