output "subnet_ids" {
  description = "The IDs of the created subnets."
  value       = [for s in aws_subnet.auto_generated : s.id]
}
