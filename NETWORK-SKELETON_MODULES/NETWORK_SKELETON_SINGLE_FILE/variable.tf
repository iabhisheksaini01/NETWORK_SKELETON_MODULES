
# ***************************************************************Provider & General***************************************************************

variable "region" {
  type        = string
  description = "AWS region where resources will be created"
}

variable "project_name" {
  type        = string
  description = "Project name used for resource naming and tagging"
}

variable "env" {
  type        = string
  description = "Environment Name"
}

variable "owner" {
  type        = string
  description = "Owner of the project"
}


# ***************************************************************VPC***************************************************************

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support for the VPC"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in the VPC"
}

variable "instance_tenancy" {
  type        = string
  description = "Instance tenancy option (default or dedicated)"
}


# ***************************************************************Public Subnets***************************************************************

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "public_subnet_azs" {
  type        = list(string)
  description = "Availability Zones for public subnets"
}


# ***************************************************************Private Subnets***************************************************************

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
}

variable "private_subnet_azs" {
  type        = list(string)
  description = "Availability Zones for private subnets"
}

# ***************************************************************Route Tables and Routes***************************************************************

variable "public_rt_cidr_block" {
  type        = string
  description = "Destination CIDR block for public route "
}

variable "private_rt_cidr_block" {
  type        = string
  description = "Destination CIDR block for private route"
}


# ***************************************************************NAT Gateway***************************************************************

variable "eip_domain" {
  type        = string
  default     = "vpc"
  description = "Domain for Elastic IP "
}


# ***************************************************************Security Groups***************************************************************

variable "create_sg" {
  type        = bool
  description = "Whether to create security groups"
}

variable "sg_names" {
  type        = list(string)
  description = "List of security group names to be created"
}

variable "security_groups_rule" {
  description = "Security group rules definition"
  type = map(object({
    ingress_rules = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      description     = string
      cidr_blocks     = optional(list(string))
      source_sg_names = optional(list(string))
    }))
    egress_rules = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      description     = string
      cidr_blocks     = optional(list(string))
      source_sg_names = optional(list(string))
    }))
  }))
}


#*************************************************************** Network ACLs***************************************************************

variable "create_nacl" {
  type        = bool
  description = "Whether to create Network ACLs"
}

variable "nacl_config" {
  description = "NACL configuration "
  type = map(object({
    ingress_rules = list(object({
      rule_no    = number
      protocol   = string
      action     = string
      cidr_block = string
      from_port  = number
      to_port    = number
    }))
    egress_rules = list(object({
      rule_no    = number
      protocol   = string
      action     = string
      cidr_block = string
      from_port  = number
      to_port    = number
    }))
  }))
  default = {}
}

variable "nacl_association_map" {
  description = "Mapping of NACL associations with subnets"
  type = map(object({
    nacl_name = string
    index     = number
  }))
  default = {}
}


# ***************************************************************Load Balancer***************************************************************

variable "create_alb" {
  type        = bool
  description = "Whether to create an Application Load Balancer"
}

variable "alb_name" {
  type        = string
  description = "Name of the ALB"
}

variable "lb_internal" {
  type        = bool
  description = "Whether the ALB is internal"
}

variable "lb_type" {
  type        = string
  description = "Type of Load Balancer (application or network)"
}

variable "lb_enable_deletion" {
  type        = bool
  description = "Enable or disable deletion protection for ALB"
}


# ***************************************************************Route 53***************************************************************

variable "create_route53_record" {
  type        = bool
  description = "Whether to create a Route53 record for ALB"
  default     = false
}

variable "domain_name" {
  type        = string
  description = "Domain name of the Route53 hosted zone"
  default     = null
}

variable "subdomain_name" {
  type        = string
  description = "Subdomain for the Route53 record"
  default     = null
}


# ***************************************************************VPC Peering***************************************************************

variable "enable_vpc_peering" {
  type        = bool
  description = "Enable VPC peering connection"
  default     = false
}

variable "peer_vpc_id" {
  type        = string
  description = "Peer VPC ID"
  default     = null
}

variable "peer_vpc_cidr" {
  type        = string
  description = "Peer VPC CIDR block"
  default     = null
}

variable "peer_route_table_ids" {
  type        = list(string)
  description = "List of route table IDs from peer VPC for return routes"
  default     = []
}


# ***************************************************************Tags***************************************************************

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}

