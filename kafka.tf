module "security_group_for_kafka" {
  source  = "app.terraform.io/animal-squad/security-group/aws"
  version = "1.0.1"

  name_prefix = "${local.name}-kafka-sg"
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
      cidr_ipv4   = "0.0.0.0/0"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    zookeeper = {
      from_port   = 2181
      to_port     = 2181
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.0.0/20"
    }
    kafka = {
      from_port   = 9092
      to_port     = 9092
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.0.0/20"
    }
  }
}

module "kafka_instance" {
  source  = "app.terraform.io/animal-squad/ec2/aws"
  version = "1.0.2"

  name_prefix = "${local.name}-kafka-instance"

  ami           = "ami-0d81776ee23e75c00" # Amazon Linux 2023 x86_64 with docker
  az            = "ap-northeast-2a"
  instance_type = "t3.small"

  security_group_ids          = [module.security_group_for_kafka.id]
  subnet_id                   = module.network.public_subnets["kafka"].id
  vpc_id                      = module.network.vpc_id
  associate_public_ip_address = true

  root_volume_size = 50

  key_name = module.key_pair.name
}