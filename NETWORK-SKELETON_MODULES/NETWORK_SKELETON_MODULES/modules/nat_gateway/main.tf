
resource "aws_eip" "nat_eip" {
  domain = var.eip_domain

  tags = merge(var.common_tags, {
    Name = "${var.env}-${var.project_name}-eip"
  })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.public_subnet_ids[0]

  tags = merge(var.common_tags, {
    Name = "${var.env}-${var.project_name}-natgw"
  })

  depends_on = [var.igw_id]
}

