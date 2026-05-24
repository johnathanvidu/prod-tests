output "endpoint" {
  description = "OpenSearch domain endpoint"
  value       = "https://${aws_opensearch_domain.this.endpoint}"
}

output "dashboard_endpoint" {
  description = "OpenSearch Dashboards endpoint"
  value       = "https://${aws_opensearch_domain.this.dashboard_endpoint}"
}

output "domain_arn" {
  description = "ARN of the OpenSearch domain"
  value       = aws_opensearch_domain.this.arn
}

output "domain_id" {
  description = "Unique identifier for the domain"
  value       = aws_opensearch_domain.this.domain_id
}
