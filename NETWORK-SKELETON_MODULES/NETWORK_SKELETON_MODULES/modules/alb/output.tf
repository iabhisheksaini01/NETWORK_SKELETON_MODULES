output "alb_arn" {
  value       = var.create_alb ? aws_lb.alb[0].arn : null
  description = "ARN of the ALB"
}

output "alb_dns" {
  value       = var.create_alb ? aws_lb.alb[0].dns_name : null
  description = "DNS name of the ALB"
}

output "alb_zone_id" {
  value       = var.create_alb ? aws_lb.alb[0].zone_id : null
  description = "Zone ID of the ALB"
}

