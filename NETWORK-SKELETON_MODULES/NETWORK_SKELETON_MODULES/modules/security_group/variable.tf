variable "vpc_id" { type = string }
variable "create_sg" { type = bool }
variable "sg_names" { type = list(string) }
variable "security_groups_rule" {
  type = map(object({
    name          = string
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
variable "env" { type = string }
variable "common_tags" { type = map(string) }

