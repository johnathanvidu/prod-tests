variable "bucket_prefix" {
  description = "Name prefix for the bucket, supplied by the caller (sourced from the Torque parameter store in the blueprint). Combined with bucket_base_name to form '<prefix>-<base>'."
  type        = string
}

variable "bucket_base_name" {
  description = "Static, fixed portion of the bucket name. Combined with the SSM prefix to form '<prefix>-<base>'."
  type        = string
  default     = "api-gw-swagger-defs"
}

variable "swagger_key" {
  description = "Object key under which swagger definitions are stored in the bucket."
  type        = string
  default     = "openapi/swagger.json"
}

variable "seed_default_swagger" {
  description = "Seed a minimal placeholder OpenAPI document so the API Gateway grain has a valid definition to import on first deploy."
  type        = bool
  default     = true
}

variable "environment" {
  description = "Deployment environment label, applied as a tag."
  type        = string
  default     = "Development"
}
