# Public subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_names)
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.public_subnet_azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name        = "${var.env}-${var.project_name}-${var.public_subnet_names[count.index]}"
    Environment = var.env
  })
}

# Private subnets
resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet_names)
  vpc_id                  = var.vpc_id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.private_subnet_azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name        = "${var.env}-${var.project_name}-${var.private_subnet_names[count.index]}"
    Environment = var.env
  })
}

