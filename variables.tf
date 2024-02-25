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

variable "elb_arn" {
  type    = map(string)
  default = {
    dev = ""
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









