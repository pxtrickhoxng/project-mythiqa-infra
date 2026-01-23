
output "vpc_id" {
  value       = aws_vpc.mythiqa_vpc.id
  description = "VPC ID"
}

output "alb_subnet_ids" {
  value       = [aws_subnet.alb_public_az1.id, aws_subnet.alb_public_az2.id]
  description = "Public subnet IDs for ALB (multi-AZ)"
}

output "backend_subnet_ids" {
  value       = [aws_subnet.private_backend_az1.id, aws_subnet.private_backend_az2.id]
  description = "Private subnet IDs for backend instances"
}

output "rds_subnet_ids" {
  value       = [aws_subnet.private_rds_az1.id, aws_subnet.private_rds_az2.id]
  description = "Private subnet IDs for RDS"
}

output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "Security group ID for ALB"
}

output "backend_sg_id" {
  value       = aws_security_group.backend_sg.id
  description = "Security group ID for backend instances"
}

output "rds_sg_id" {
  value       = aws_security_group.rds_sg.id
  description = "Security group ID for RDS"
}