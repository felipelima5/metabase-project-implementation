module "ecs_cluster" {
    source = "git@github.com:felipelima5/metabase-project-ecs-cluster-module.git?ref=1.0.1"

    ecs_cluster_name               = "solution-${terraform.workspace}"
    logging                        = "OVERRIDE"
    cloud_watch_encryption_enabled = true
    containerInsights              = "enabled"
    tags = {
      env       = "${terraform.workspace}"
      ManagedBy = "IaC"
    }
}
