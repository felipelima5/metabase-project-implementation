data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Name = "*${var.subnet_type}*"
  }
}


data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Name = "*${var.subnet_type_public}*"
  }
}

locals {
  subnets = data.aws_subnets.this.ids[*]
  public_subnets = data.aws_subnets.public.ids[*]
}
