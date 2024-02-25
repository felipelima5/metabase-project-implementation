data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Name = "*${var.subnet_type}*"
  }
}

locals {
  subnets = data.aws_subnets.this.ids[*]
}
