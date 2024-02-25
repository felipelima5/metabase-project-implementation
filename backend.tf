terraform {
  backend "s3" {
    bucket  = "metabase-solutions-state-tf"
    key     = "development/infra.tfstate"
    encrypt = "true"
    region  = "us-east-2"
  }
}  