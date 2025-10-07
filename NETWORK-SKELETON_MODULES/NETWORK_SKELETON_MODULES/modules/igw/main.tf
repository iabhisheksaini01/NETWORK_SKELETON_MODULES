resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.env}-${var.project_name}-igw"
  })
}

