# CRIAÇÃO DO CLUSTER ECS
module "ecs_cluster" {
  source = "git::https://github.com/felipelima5/metabase-project-ecs-cluster-module.git?ref=1.0.1"

  ecs_cluster_name               = "solution-${terraform.workspace}"
  logging                        = "OVERRIDE"
  cloud_watch_encryption_enabled = true
  containerInsights              = "enabled"
  tags = {
    env       = "${terraform.workspace}"
    ManagedBy = "IaC"
  }
}

/*
# CRIAÇÃO DO LOAD BALANCER TO TIPO ALB
module "elb" {
  source = "git::https://github.com/felipelima5/metabase-project-alb-module.git?ref=1.0.0"

  alb_name                   = "elb-metabase"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = false
  vpc_id                     = var.vpc_id
  subnets_ids                = local.subnets

  enable_create_s3_bucket_log     = false
  bucket_env_name                 = "log-alb-teste-app-module"
  access_logs_prefix              = "log-dev"
  enable_versioning_configuration = "Enabled"

  create_rule_redirect_https = true

  security_group_app_ingress_rules = [
    {
      description     = "Allow Traffic HTTP 443"
      port            = 443
      protocol        = "tcp"
      security_groups = []
      cidr_blocks     = ["0.0.0.0/0"]
    },
    {
      description     = "Allow Traffic HTTP 80"
      port            = 80
      protocol        = "tcp"
      security_groups = []
      cidr_blocks     = ["0.0.0.0/0"]
    }
  ]

  security_group_app_egress_rules = [
    {
      description     = "All Traffic"
      port            = 0
      protocol        = "-1"
      security_groups = []
      cidr_blocks     = ["0.0.0.0/0"]
    }
  ]

  aditional_tags = {
    Env = "Dev"
  }
}
*/