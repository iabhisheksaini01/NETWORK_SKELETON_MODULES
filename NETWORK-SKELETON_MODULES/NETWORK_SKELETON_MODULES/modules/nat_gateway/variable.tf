variable "public_subnet_ids" {
  type = list(string)
  description = "List of public subnet IDs"
}

variable "eip_domain" {
  type        = string
  description = "Domain for EIP (usually 'vpc')"
}

variable "igw_id" {
  type        = string
  description = "Internet Gateway ID for dependency"
}

variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

