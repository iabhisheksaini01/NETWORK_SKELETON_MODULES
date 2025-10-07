

# *********************************Public Route Table**********************************
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  tags   = merge(var.common_tags, { Name = "${var.env}-${var.project_name}-public-rt" })
}

# **********************************Private Route Table**********************************
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  tags   = merge(var.common_tags, { Name = "${var.env}-${var.project_name}-private-rt" })
}

#***************************************************************** Associate Public Subnets with Public RT***********************************************************************

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnets with Private RT
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private.id
}

# **********************************Public RT---- IGW**********************************
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

# **********************************Private RT----NAT IGW**********************************
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_id
}

