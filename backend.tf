terraform {
  backend "s3" {
    bucket  = "metabase-solutions-state-tf"
    key     = "development/infrastrucure.tfstate"
    encrypt = "true"
    region  = "us-east-2"
  }
}  