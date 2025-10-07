variable "vpc_id" { type = string }
variable "create_nacl" { type = bool }

variable "nacl_config" { 
  type = map(object({
    subnet_indexes = list(number)
    ingress_rules  = list(object({
      protocol   = string
      rule_no    = number
      action     = string
      cidr_block = string
      from_port  = number
      to_port    = number
    }))
    egress_rules  = list(object({
      protocol   = string
      rule_no    = number
      action     = string
      cidr_block = string
      from_port  = number
      to_port    = number
    }))
    subnet_type = string  # "public" or "private"
  }))
}

variable "nacl_assoc_map" { 
  type = map(object({
    nacl_name   = string
    index       = number
    subnet_type = string
  }))
}

variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "common_tags" { type = map(string) }

