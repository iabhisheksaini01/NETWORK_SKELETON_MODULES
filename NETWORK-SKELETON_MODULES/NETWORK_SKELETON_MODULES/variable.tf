
# **********************************************VPC Variables**********************************************

variable "vpc_cidr" { type = string }
variable "enable_dns_support" { type = bool }
variable "enable_dns_hostnames" { type = bool }
variable "instance_tenancy" { type = string }
variable "region" { type = string }
variable "project_name" { type = string }
variable "env" { type = string }
variable "owner" { type = string }


# **********************************************Subnet Variables**********************************************

variable "public_subnet_names" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "public_subnet_azs"   { type = list(string) }

variable "private_subnet_names" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "private_subnet_azs"   { type = list(string) }


# **********************************************Route Table Variables**********************************************

# Note: Route table names are auto-generated based on env and project_name
# CIDR blocks are hardcoded to 0.0.0.0/0 in route_table module


# **********************************************NACL Variables**********************************************

variable "create_nacl" { type = bool }
variable "nacl_names" { type = list(string) }
variable "nacl_rules" { type = map(any) }


# **********************************************Security Group Variables**********************************************

variable "create_sg" { type = bool }
variable "sg_names" { type = list(string) }
variable "security_groups_rule" {
  type = map(object({
    name          = string
    ingress_rules = list(object({
      protocol         = string
      from_port        = number
      to_port          = number
      cidr_blocks      = optional(list(string))
      source_sg_names  = optional(list(string))
      description      = string
    }))
    egress_rules = list(object({
      protocol         = string
      from_port        = number
      to_port          = number
      cidr_blocks      = optional(list(string))
      source_sg_names  = optional(list(string))
      description      = string
    }))
  }))
}


# *************************************************ALB Variables*************************************************

variable "create_alb" { type = bool }
variable "alb_name" { type = string }
variable "lb_internal" { type = bool }
variable "lb_type" { type = string }
variable "lb_enable_deletion" { type = bool }


# *************************************************Route53 Variables*************************************************

variable "create_route53_record" { type = bool }
variable "domain_name" { type = string }
variable "subdomain_name" { type = string }


# *************************************************VPC Peering Variables*************************************************

variable "enable_vpc_peering" { type = bool }
variable "peer_vpc_id" { type = string }
variable "peer_vpc_cidr" { type = string }
variable "peer_route_table_ids" { type = list(string) }


# *************************************************Common Tags*************************************************

variable "common_tags" { type = map(string) }


# *************************************************NAT Gateway / EIP Variables*************************************************

variable "eip_domain" { type = string }



