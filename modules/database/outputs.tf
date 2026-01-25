output "db_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "RDS instance endpoint (hostname:port)"
}

output "db_address" {
  value       = aws_db_instance.postgres.address
  description = "RDS instance hostname"
}

output "db_port" {
  value       = aws_db_instance.postgres.port
  description = "RDS instance port"
}

output "db_name" {
  value       = aws_db_instance.postgres.db_name
  description = "Database name"
}

output "db_username" {
  value       = aws_db_instance.postgres.username
  description = "Master username"
  sensitive   = true
}

output "jdbc_connection_string" {
  value       = "jdbc:postgresql://${aws_db_instance.postgres.endpoint}/${aws_db_instance.postgres.db_name}"
  description = "JDBC connection string for Spring Boot"
}
