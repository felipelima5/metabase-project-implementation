data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [lookup(var.vpc_id, terraform.workspace)]
  }

  tags = {
    Name = "*${var.subnet_type}*"
  }
}

locals {
  subnets = data.aws_subnets.this.ids[*]
}
