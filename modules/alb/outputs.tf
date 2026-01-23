output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "DNS name of the ALB"
}

output "target_group_arn" {
  value       = aws_lb_target_group.backend.arn
  description = "ARN of target group for ASG attachment"
}