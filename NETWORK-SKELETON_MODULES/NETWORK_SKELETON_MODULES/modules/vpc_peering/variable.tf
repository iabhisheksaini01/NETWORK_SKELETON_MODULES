variable "enable_vpc_peering" { type = bool }
variable "vpc_id" { type = string }
variable "peer_vpc_id" { type = string }
variable "peer_vpc_cidr" { type = string }
variable "peer_route_table_ids" { type = list(string) }
variable "public_rt_id" { type = string }
variable "private_rt_id" { type = string }
variable "vpc_cidr" { type = string }
variable "project_name" { type = string }
variable "env" { type = string }
variable "common_tags" { type = map(string) }

