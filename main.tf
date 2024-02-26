
# CRIAÇÃO DO CLUSTER ECS
module "ecs_cluster_dev" {
  source = "git::https://github.com/felipelima5/metabase-project-ecs-cluster-module.git?ref=1.0.1"

  ecs_cluster_name               = "cluster-${terraform.workspace}"
  logging                        = "OVERRIDE"
  cloud_watch_encryption_enabled = true
  containerInsights              = "enabled"
  tags = {
    env       = "${terraform.workspace}"
    ManagedBy = "IaC"
  }
}

# CRIAÇÃO DO LOAD BALANCER TO TIPO ALB
module "alb" {
  source = "git::https://github.com/felipelima5/metabase-project-alb-module.git?ref=1.0.0"

  alb_name                   = "alb-metabase"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = false
  vpc_id                     = var.vpc_id
  subnets_ids                = local.public_subnets

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


module "app_metabase_dev" {
    source = "git::https://github.com/felipelima5/metabase-project-ecs-app-module.git?ref=1.0.0"

    region           = var.region
    application_name = "metabase-app"
    application_port = 3000 #Port Dockerfile / Application

    cloudwatch_log_retention_in_days = 3

    # TASK DEFINITION
    requires_compatibilities                 = "FARGATE"
    network_mode                             = "awsvpc"
    cpu                                      = 1024
    memory                                   = 2048
    runtime_platform_operating_system_family = "LINUX"
    runtime_platform_cpu_architecture        = "X86_64" # ARM64
    container_definitions_image              = "metabase/metabase:latest"
    container_definitions_cpu                = 1024
    container_definitions_memory             = 2048
    container_definitions_memory_reservation = 1024  #Soft Limit
    container_definitions_essential          = true #Obrigatorio
    container_definitions_command            = ""   #"nodejs,start"

    # Env Variables s3
    enable_create_s3_bucket         = false
    enable_versioning_configuration = "Enabled" # Habilitar Versionamento - Preencher apenas se for criar o bucket
    bucket_env_name                 = "metabase-env-vars-${terraform.workspace}"
    file_env_name                   = "variables"
    path_env_name                   = "${terraform.workspace}"

    # Service
    ecs_cluster_name                           = "cluster-${terraform.workspace}"
    service_desired_count                      = 1 #Quantas Tasks irá subir
    service_launch_type                        = "FARGATE"
    service_deployment_minimum_healthy_percent = 100
    service_deployment_maximum_percent         = 200
    service_assign_public_ip                   = false
    vpc_id                                     = var.vpc_id
    subnets_ids                                = local.subnets

    # LoadBalancer
    alb_listener_load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-2:111109532426:loadbalancer/app/alb-metabase/d74573d4625e3f06" #ARN do ALB
    alb_listener_port              = "443"
    alb_listener_protocol          = "HTTPS"
    alb_listener_certificate_arn   = "arn:aws:acm:us-east-2:111109532426:certificate/d610afc5-9332-40c7-9c30-04f6d9a6f4e6"
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

    security_group_alb = ["sg-00450cbbb5cb72a86"]  #Security Group do LoadBalancer Application que enviará as requests

    tags = {
      ManagedBy = "IaC"
    }
}


module "db_rds" {
  source = "git::https://github.com/felipelima5/metabase-project-rds-module.git?ref=1.0.2"

  instance_identifier     = "metabase-db"
  db_name                 = "metabase"
  allocated_storage       = 20
  max_allocated_storage   = 50
  publicly_accessible     = true
  engine                  = "mariadb"
  engine_version          = "10.5"
  instance_class          = "db.t4g.micro"
  multi_az                = false
  username                = "admin"
  backup_retention_period = 10 #----------(0 - 35 dias)
  copy_tags_to_snapshot   = true
  deletion_protection     = false
  skip_final_snapshot     = true
  storage_type            = "gp3" # ------(gp2), (gp3), (io1 - mínimo 100gb)
  iops                    = null  # ------(caso o storage seja io1 ou gp3)
  storage_encrypted       = true
  monitoring_interval                   = 60
  parameter_group_family                = "mariadb10.5"
  vpc_id                                = var.vpc_id
  subnets_ids                           = local.subnets

  security_group_app_ingress_rules = [
    {
      description     = "Allow Traffic HTTP 3306"
      port            = 3306
      protocol        = "tcp"
      security_groups = ["sg-010e7087a8d79a47d"] # ECS Service Metabase dev
    }
  ]

  aditional_tags = {
    Env        = "Dev"
  }
}


