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



module "app_metabase" {
    source = "git::https://github.com/felipelima5/metabase-project-ecs-app-module.git?ref=1.0.0"

    region           = var.region
    application_name = "metabase"
    application_port = 3000 #Port Dockerfile / Application

    cloudwatch_log_retention_in_days = 3

    # TASK DEFINITION
    requires_compatibilities                 = "FARGATE"
    network_mode                             = "awsvpc"
    cpu                                      = 256
    memory                                   = 512
    runtime_platform_operating_system_family = "LINUX"
    runtime_platform_cpu_architecture        = "X86_64" # ARM64
    container_definitions_image              = "metabase/metabase:latest"
    container_definitions_cpu                = 256
    container_definitions_memory             = 512
    container_definitions_memory_reservation = 256  #Soft Limit
    container_definitions_essential          = true #Obrigatorio
    container_definitions_command            = ""   #"nodejs,start"

    # Env Variables s3
    enable_create_s3_bucket         = false
    enable_versioning_configuration = "Enabled" # Habilitar Versionamento - Preencher apenas se for criar o bucket
    bucket_env_name                 = "metabase-env-vars-${terraform.workspace}"
    file_env_name                   = "variables"
    path_env_name                   = "${terraform.workspace}"

    # Service
    ecs_cluster_name                           = "solution-${terraform.workspace}"
    service_desired_count                      = 1 #Quantas Tasks irá subir
    service_launch_type                        = "FARGATE"
    service_deployment_minimum_healthy_percent = 100
    service_deployment_maximum_percent         = 200
    service_assign_public_ip                   = false
    vpc_id                                     = var.vpc_id
    subnets_ids                                = local.subnets

    # LoadBalancer
    alb_listener_load_balancer_arn = lookup(var.elb_arn, terraform.workspace) #ARN do ALB
    alb_listener_port              = "443"
    alb_listener_protocol          = "HTTPS"
    alb_listener_certificate_arn   = lookup(var.certificate_arn, terraform.workspace)
    alb_listener_host_rule         = "metabase-${terraform.workspace}.keephouseorder.net"

    # LoadBalancer TargetGroup
    target_protocol                         = "HTTP"
    target_protocol_version                 = "HTTP1"
    target_deregistration_delay             = 10
    target_health_check_enable              = true
    target_health_check_path                = "/"
    target_health_check_healthy_threshold   = 5
    target_health_check_unhealthy_threshold = 2
    target_health_check_timeout             = 5
    target_health_check_interval            = 30
    target_health_check_success_code        = "200-499"

    security_group_alb = ["sg-003058130bb69ea18"]  #Security Group do LoadBalancer Application que enviará as requests

    tags = {
      ManagedBy = "IaC"
    }
}

