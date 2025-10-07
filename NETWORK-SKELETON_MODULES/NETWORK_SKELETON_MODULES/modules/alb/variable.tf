variable "create_alb" { 
  type = bool 
}

variable "alb_name" { 
  type = string 
}

variable "lb_internal" { 
  type = bool 
}

variable "lb_type" { 
  type = string 
}

variable "lb_enable_deletion" { 
  type = bool 
}

variable "alb_sg_ids" {
  type = list(string)
  description = "List of security group IDs for ALB"
}

variable "public_subnet_ids" { 
  type = list(string) 
}

variable "env" { 
  type = string 
}

variable "common_tags" { 
  type = map(string) 
}


