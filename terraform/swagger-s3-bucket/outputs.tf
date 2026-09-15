output "bucket_name" {
  description = "Name of the swagger definitions bucket."
  value       = aws_s3_bucket.swagger.id
}

output "bucket_arn" {
  description = "ARN of the swagger definitions bucket."
  value       = aws_s3_bucket.swagger.arn
}

output "swagger_key" {
  description = "Object key where the swagger definition is stored."
  value       = var.swagger_key
}

output "swagger_s3_uri" {
  description = "Full s3:// URI of the swagger object."
  value       = "s3://${aws_s3_bucket.swagger.id}/${var.swagger_key}"
}
