output "db_endpoint" {
  description = "The RDS database endpoint"
  value       = aws_db_instance.this.address
}