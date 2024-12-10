
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

module "server_alb" {
  source  = "app.terraform.io/animal-squad/elb/aws"
  version = "1.0.7"

  name = "${local.name}-server"

  certificate_arn = "arn:aws:acm:ap-northeast-2:015224529527:certificate/dc708e49-3eb0-4991-aded-20152719dc0b"

  vpc_id     = module.network.vpc_id
  subnet_ids = [module.network.public_subnets["server_0"].id, module.network.public_subnets["server_1"].id]

  default_target_groups = {
    server = {
      health_check_path = "/health"
      port              = 80
    }
  }

  default_targets = {
    server_0 = {
      target_group_key = "server"
      target_id        = module.instance_server.server_0.instance_id
      port             = 5000
    }
    server_1 = {
      target_group_key = "server"
      target_id        = module.instance_server.server_1.instance_id
      port             = 5000
    }
  }
}
