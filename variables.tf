variable "region" {
  type    = string
  default = "us-east-2"
}

variable "vpc_id" {
  type    = string
  default = "vpc-0cf93c92f757600de"
}

variable "subnet_type" {
  type    = string
  default = "private"
}


variable "subnet_type_public" {
  type    = string
  default = "public"
}

variable "elb_arn" {
  type    = map(string)
  default = {
    dev = "arn:aws:elasticloadbalancing:us-east-2:111109532426:loadbalancer/app/alb-metabase/d74573d4625e3f06"
    hom = ""
    prd = ""
  }
}

variable "certificate_arn" {
  type    = map(string)
  default = {
    dev = "arn:aws:acm:us-east-2:111109532426:certificate/d610afc5-9332-40c7-9c30-04f6d9a6f4e6"
    hom = ""
    prd = ""
  }
}









