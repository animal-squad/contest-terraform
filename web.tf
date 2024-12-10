
module "security_group_web" {
  source  = "app.terraform.io/animal-squad/security-group/aws"
  version = "1.0.1"

  name_prefix = "${local.name}-web-sg"
  vpc_id      = module.network.vpc_id

  ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    nextjs = {
      from_port   = 3000
      to_port     = 3000
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.0.0/20"
    }
  }
}

module "instance_web" {
  for_each = {
    web_0 = {
      az = "ap-northeast-2a"
    }
    web_1 = {
      az = "ap-northeast-2b"
    }
  }

  source  = "app.terraform.io/animal-squad/ec2/aws"
  version = "1.0.2"

  name_prefix = "${local.name}-instance-${each.key}"

  ami           = "ami-0d81776ee23e75c00" # Amazon Linux 2023 x86_64 with docker
  az            = each.value.az
  instance_type = "t3.small"

  security_group_ids          = [module.security_group_web.id]
  subnet_id                   = module.network.public_subnets[each.key].id
  vpc_id                      = module.network.vpc_id
  associate_public_ip_address = true

  root_volume_size = 50

  key_name = module.key_pair.name
}

module "web_alb" {
  source  = "app.terraform.io/animal-squad/elb/aws"
  version = "1.0.7"

  name = local.name

  certificate_arn = "arn:aws:acm:ap-northeast-2:015224529527:certificate/dc708e49-3eb0-4991-aded-20152719dc0b"

  vpc_id     = module.network.vpc_id
  subnet_ids = [module.network.public_subnets["web_0"].id, module.network.public_subnets["web_1"].id]

  default_target_groups = {
    web = {
      port = 80
    }
  }

  default_targets = {
    web_0 = {
      target_group_key = "web"
      target_id        = module.instance_web.web_0.instance_id
      port             = 3000
    }
    web_1 = {
      target_group_key = "web"
      target_id        = module.instance_web.web_1.instance_id
      port             = 3000
    }
  }
}
