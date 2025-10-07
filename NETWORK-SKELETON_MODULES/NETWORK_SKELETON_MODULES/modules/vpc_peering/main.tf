resource "aws_vpc_peering_connection" "peer" {
  count       = var.enable_vpc_peering ? 1 : 0
  vpc_id      = var.vpc_id
  peer_vpc_id = var.peer_vpc_id
  auto_accept = true

  tags = merge(var.common_tags, {
    Name = "${var.env}-${var.project_name}-peer"
  })
}

resource "aws_route" "peer_public" {
  count = var.enable_vpc_peering ? 1 : 0
  route_table_id            = var.public_rt_id
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer[0].id
}

resource "aws_route" "peer_private" {
  count = var.enable_vpc_peering ? 1 : 0
  route_table_id            = var.private_rt_id
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer[0].id
}

resource "aws_route" "peer_return" {
  for_each = toset(var.peer_route_table_ids)
  route_table_id            = each.key
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer[0].id
}

