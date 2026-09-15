locals {
  # Prefix is supplied by the caller (the blueprint sources it from the Torque
  # parameter store); the rest of the name is static: "<prefix>-<base>".
  prefix      = trimspace(var.bucket_prefix)
  bucket_name = "${local.prefix}-${var.bucket_base_name}"

  common_tags = {
    Environment = var.environment
    ManagedBy   = "torque"
    Purpose     = "api-gw-swagger-definitions"
  }
}

resource "aws_s3_bucket" "swagger" {
  bucket        = local.bucket_name
  force_destroy = true
  tags          = local.common_tags
}

# Versioning lets the API Gateway grain (and humans) track swagger revisions.
resource "aws_s3_bucket_versioning" "swagger" {
  bucket = aws_s3_bucket.swagger.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "swagger" {
  bucket                  = aws_s3_bucket.swagger.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Minimal valid OpenAPI doc so the API Gateway grain can import on first deploy.
# The workflow / day-2 upload overwrites this object with the real definition.
resource "aws_s3_object" "default_swagger" {
  count        = var.seed_default_swagger ? 1 : 0
  bucket       = aws_s3_bucket.swagger.id
  key          = var.swagger_key
  content_type = "application/json"
  content = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "placeholder-api"
      version = "1.0.0"
    }
    paths = {
      "/health" = {
        get = {
          responses = {
            "200" = { description = "ok" }
          }
          "x-amazon-apigateway-integration" = {
            type                = "mock"
            requestTemplates    = { "application/json" = "{\"statusCode\": 200}" }
            passthroughBehavior = "when_no_match"
            responses           = { default = { statusCode = "200" } }
          }
        }
      }
    }
  })

  # Let day-2 uploads replace the body without Terraform reverting it.
  lifecycle {
    ignore_changes = [content, content_type]
  }

  tags = local.common_tags
}
