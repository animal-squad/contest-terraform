module "service_alb" {
  source  = "app.terraform.io/animal-squad/elb/aws"
  version = "1.0.8"

  name = "${local.name}-service"

  certificate_arn = "arn:aws:acm:ap-northeast-2:015224529527:certificate/dc708e49-3eb0-4991-aded-20152719dc0b"

  vpc_id     = module.network.vpc_id
  subnet_ids = [module.network.public_subnets["service_0"].id, module.network.public_subnets["service_1"].id]

  default_target_groups = {
    web = {
      port = 80
    }
  }

  default_targets = {
    web_0 = {
      target_group_key = "web"
      target_id        = module.instance_web.service_0.instance_id
      port             = 3000
    }
    web_1 = {
      target_group_key = "web"
      target_id        = module.instance_web.service_1.instance_id
      port             = 3000
    }
  }

  https_listener_rules = {
    server = {
      path     = ["/api/*", "/api"]
      host     = ["www.goorm-ktb-013.goorm.team"]
      priority = 1
    }
  }
  target_groups = {
    server = {
      health_check_path = "/health"
      port              = 80
    }
  }
  targets = {
    server_0 = {
      target_group_key = "server"
      target_id        = module.instance_server.service_0.instance_id
      port             = 5000
    }
    server_1 = {
      target_group_key = "server"
      target_id        = module.instance_server.service_1.instance_id
      port             = 5000
    }
  }
}
