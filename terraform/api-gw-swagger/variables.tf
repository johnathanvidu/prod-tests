variable "api_name" {
  description = "Name of the REST API. Used to namespace the API Gateway and related resources."
  type        = string
}

variable "stage_name" {
  description = "Name of the deployment stage (e.g. 'api', 'v1')."
  type        = string
  default     = "api"
}

# --- Swagger / OpenAPI source (fetched from S3) ---

variable "swagger_bucket" {
  description = "Name of the S3 bucket that holds the OpenAPI/Swagger definition."
  type        = string
}

variable "swagger_key" {
  description = "Object key of the OpenAPI/Swagger file inside the bucket."
  type        = string
  default     = "openapi/swagger.json"
}

# --- Integration ---

variable "integration_type" {
  description = "Backend integration type the swagger routes are wired to (e.g. 'lambda', 'http')."
  type        = string
  default     = "lambda"
}

variable "lambda_functions_json" {
  description = <<-EOT
    JSON map of logical name -> Lambda function (name or invoke ARN) used for
    template injection into the swagger. Each key is exposed as an API Gateway
    stage variable so the OpenAPI document can reference it via
    $${stageVariables.<key>}. Defaults to an empty map.
  EOT
  type        = string
  default     = "{}"
}

# --- Endpoint / networking ---

variable "endpoint_type" {
  description = "API Gateway endpoint type: PRIVATE, REGIONAL or EDGE."
  type        = string
  default     = "PRIVATE"

  validation {
    condition     = contains(["PRIVATE", "REGIONAL", "EDGE"], var.endpoint_type)
    error_message = "endpoint_type must be one of PRIVATE, REGIONAL, EDGE."
  }
}

variable "vpc_endpoint_ids_csv" {
  description = "Comma-separated list of execute-api VPC endpoint IDs. Required when endpoint_type is PRIVATE."
  type        = string
  default     = ""
}

# --- Environment / tagging ---

variable "environment" {
  description = "Deployment environment label, applied as a tag."
  type        = string
  default     = "Development"
}

# --- Feature flags (parity with the api-gw blueprint interface) ---

variable "enable_access_logging" {
  description = "Emit API Gateway access logs to CloudWatch."
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Enable detailed CloudWatch metrics on the stage."
  type        = bool
  default     = true
}

variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray active tracing on the stage."
  type        = bool
  default     = false
}
