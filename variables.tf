variable "region" {
  type = string
  default = "us-east-2"
}

variable "vpc_id" {
  type = map(string)
  default = {
    dev = "vpc-0cf93c92f757600de"
    hom = ""
    prd = ""
  }
}

variable "subnet_type" {
  type    = string
  default = "private"
}



