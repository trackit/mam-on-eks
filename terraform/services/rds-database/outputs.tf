output "rds_address" {
  description = "RDS instance address"
  value       = aws_db_instance.database.address
}
