
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
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.0.0/20"
    }
  }
}

module "instance_web" {

  source  = "app.terraform.io/animal-squad/ec2/aws"
  version = "1.0.2"

  name_prefix = "${local.name}-web-instance"

  ami           = "ami-0d81776ee23e75c00" # Amazon Linux 2023 x86_64 with docker
  az            = "ap-northeast-2a"
  instance_type = "t3.small"

  security_group_ids          = [module.security_group_web.id]
  subnet_id                   = module.network.public_subnets["web"].id
  vpc_id                      = module.network.vpc_id
  associate_public_ip_address = true

  root_volume_size = 50

  key_name = module.key_pair.name
}

# module "alb" {
#   source  = "app.terraform.io/animal-squad/elb/aws"
#   version = "1.0.0"

#   name = "${local.name}"

#   certificate_arn = "arn:aws:acm:ap-northeast-2:015224529527:certificate/dc708e49-3eb0-4991-aded-20152719dc0b"

#   vpc_id = module.network.vpc_id
#   subnet_ids #set(string)

#   default_target_groups #map( object({ health_check_path = optional(string) port = number }) )
#   default_targets #map( object({ target_group_key = string port = number })

#   target_groups #map( object({ health_check_path = optional(string) port = number }) )
#   targets #map( object({ target_group_key = string port = number }) )

#   https_listener_rules #map(object({ path = list(string) host = list(string) priority = number health_check_path = optional(string) port = number }))
# }
