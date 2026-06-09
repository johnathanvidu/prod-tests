output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the created VPC"
}

output "subnet_id" {
  value       = var.create_subnet ? aws_subnet.main[0].id : null
  description = "ID of the created public subnet, or null if create_subnet is false"
}
