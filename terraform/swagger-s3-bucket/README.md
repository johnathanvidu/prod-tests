# swagger-s3-bucket

Creates the dedicated S3 bucket that holds the OpenAPI / Swagger definitions
consumed by the `api-gw-swagger` grain.

- **Static name** — the bucket name is fixed (`<prefix>-<bucket_base_name>`).
- **Prefix from the Torque parameter store** — the leading portion of the name
  is passed in as `bucket_prefix`; the blueprint sources it from a Torque
  parameter (`{{ .params.<name> }}`), so the same blueprint produces the right
  per-account/per-space name without editing the module.
- **Versioning enabled** — every swagger upload is a new object version.
- **Seeds a placeholder swagger** so the API Gateway grain has a valid document
  to import on first deploy; day-2 uploads overwrite it (`ignore_changes` keeps
  Terraform from reverting the body).

> Note: the bucket name is intentionally static (per request). Uniqueness comes
> from the SSM-sourced prefix rather than the Torque environment id.

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `bucket_prefix` | Name prefix (blueprint feeds it from a Torque parameter) | _required_ |
| `bucket_base_name` | Static portion of the bucket name | `api-gw-swagger-defs` |
| `swagger_key` | Object key for the swagger file | `openapi/swagger.json` |
| `seed_default_swagger` | Seed a placeholder OpenAPI doc on first deploy | `true` |
| `environment` | Environment tag | `Development` |

## Outputs

`bucket_name`, `bucket_arn`, `swagger_key`, `swagger_s3_uri`.
