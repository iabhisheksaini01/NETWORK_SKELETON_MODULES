variable "vpc_id" { type = string }
variable "env" { type = string }
variable "project_name" { type = string }
variable "common_tags" { type = map(string) }

# Public subnets
variable "public_subnet_names" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "public_subnet_azs" { type = list(string) }

# Private subnets
variable "private_subnet_names" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "private_subnet_azs" { type = list(string) }

