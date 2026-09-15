data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------
# Fetch the OpenAPI / Swagger definition from S3.
#
# This data source is re-read on every plan/apply. When the object in S3
# changes, its `etag` and `body` change too, which flows into the REST API
# `body` below and forces API Gateway to re-import the definition — i.e. the
# routes are recreated from the new file on each apply.
# ---------------------------------------------------------------------------
data "aws_s3_object" "swagger" {
  bucket = var.swagger_bucket
  key    = var.swagger_key
}

locals {
  # Logical-name -> lambda map injected as stage variables so the OpenAPI
  # document can reference backends via ${stageVariables.<key>}.
  lambda_functions = jsondecode(var.lambda_functions_json)

  # The raw swagger document fetched from S3.
  swagger_body = data.aws_s3_object.swagger.body

  # Stable fingerprint of the definition. Changes whenever the S3 object
  # changes (etag) or its content changes (body hash). Used to drive
  # redeployment so the stage always serves the latest routes.
  swagger_hash = sha1("${data.aws_s3_object.swagger.etag}:${local.swagger_body}")

  is_private = var.endpoint_type == "PRIVATE"

  vpc_endpoint_ids = compact(split(",", var.vpc_endpoint_ids_csv))

  common_tags = {
    Environment = var.environment
    ManagedBy   = "torque"
    Api         = var.api_name
  }
}

# Resource policy that restricts a PRIVATE API to the supplied VPC endpoints.
data "aws_iam_policy_document" "private_access" {
  count = local.is_private ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["execute-api:Invoke"]
    resources = ["execute-api:/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpce"
      values   = local.vpc_endpoint_ids
    }
  }
}

resource "aws_api_gateway_rest_api" "this" {
  name = var.api_name

  # The swagger body IS the route definition. Changing the file in S3 changes
  # this body, which makes API Gateway re-import and recreate the routes.
  body = local.swagger_body

  policy = local.is_private ? data.aws_iam_policy_document.private_access[0].json : null

  endpoint_configuration {
    types            = [var.endpoint_type]
    vpc_endpoint_ids = local.is_private ? local.vpc_endpoint_ids : null
  }

  tags = local.common_tags
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  # Redeploy whenever the swagger definition changes so the stage picks up the
  # recreated routes.
  triggers = {
    redeployment = local.swagger_hash
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "access" {
  count             = var.enable_access_logging ? 1 : 0
  name              = "/aws/apigateway/${var.api_name}/${var.stage_name}"
  retention_in_days = 14
  tags              = local.common_tags
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.stage_name

  xray_tracing_enabled = var.enable_xray_tracing

  # Expose injected lambda backends to the OpenAPI document as stage variables.
  variables = local.lambda_functions

  dynamic "access_log_settings" {
    for_each = var.enable_access_logging ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.access[0].arn
      format = jsonencode({
        requestId      = "$context.requestId"
        ip             = "$context.identity.sourceIp"
        requestTime    = "$context.requestTime"
        httpMethod     = "$context.httpMethod"
        resourcePath   = "$context.resourcePath"
        status         = "$context.status"
        responseLength = "$context.responseLength"
      })
    }
  }

  tags = local.common_tags
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = var.enable_metrics
  }
}
