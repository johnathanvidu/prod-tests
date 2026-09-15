output "rest_api_id" {
  description = "ID of the REST API."
  value       = aws_api_gateway_rest_api.this.id
}

output "rest_api_arn" {
  description = "ARN of the REST API."
  value       = aws_api_gateway_rest_api.this.arn
}

output "execution_arn" {
  description = "Execution ARN used to grant Lambda invoke permissions to the API."
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "stage_invoke_url" {
  description = "Invoke URL of the deployed stage."
  value       = aws_api_gateway_stage.this.invoke_url
}

output "vpc_endpoint_id" {
  description = "First execute-api VPC endpoint id bound to the API (empty for non-private endpoints)."
  value       = local.is_private ? try(local.vpc_endpoint_ids[0], "") : ""
}

output "swagger_hash" {
  description = "Fingerprint of the swagger definition currently deployed. Changes when the S3 object changes."
  value       = local.swagger_hash
}
