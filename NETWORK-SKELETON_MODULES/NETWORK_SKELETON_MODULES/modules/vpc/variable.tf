variable "vpc_cidr" { type = string }
variable "enable_dns_support" { type = bool }
variable "enable_dns_hostnames" { type = bool }
variable "instance_tenancy" { type = string }
variable "project_name" { type = string }
variable "env" { type = string }
variable "owner" { type = string }
variable "common_tags" { type = map(string) }

