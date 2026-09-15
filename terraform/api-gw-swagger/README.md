# api-gw-swagger

Builds an AWS REST API Gateway **from an OpenAPI / Swagger document stored in S3**.

The swagger object is read with a data source on every `terraform apply`. Because
the REST API `body` is the swagger document, any change to the file in S3 is
detected (via the object `etag` + content hash) and API Gateway **re-imports and
recreates the routes**. A redeployment is triggered automatically so the stage
serves the new routes.

This is the building block referenced as `api-gw-swagger` by the API Gateway
blueprints.

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `api_name` | Name of the REST API | _required_ |
| `stage_name` | Deployment stage name | `api` |
| `swagger_bucket` | S3 bucket holding the swagger file | _required_ |
| `swagger_key` | Object key of the swagger file | `openapi/swagger.json` |
| `integration_type` | Backend integration type (`lambda`, `http`) | `lambda` |
| `lambda_functions_json` | JSON map injected as stage variables for `${stageVariables.*}` references | `{}` |
| `endpoint_type` | `PRIVATE`, `REGIONAL` or `EDGE` | `PRIVATE` |
| `vpc_endpoint_ids_csv` | Comma-separated execute-api VPC endpoint IDs (required for PRIVATE) | `""` |
| `environment` | Environment tag | `Development` |
| `enable_access_logging` | Stage access logging to CloudWatch | `true` |
| `enable_metrics` | Detailed CloudWatch metrics | `true` |
| `enable_xray_tracing` | X-Ray active tracing | `false` |

## Outputs

`rest_api_id`, `rest_api_arn`, `execution_arn`, `stage_invoke_url`,
`vpc_endpoint_id`, `swagger_hash`.

## How route recreation works

1. `data.aws_s3_object.swagger` reads the file each apply.
2. `aws_api_gateway_rest_api.body` is set to that content → API Gateway re-imports.
3. `aws_api_gateway_deployment.triggers.redeployment` is keyed on a hash of the
   object etag + body → a fresh deployment is rolled out whenever the file changes.

Upload a new swagger file to the bucket and re-apply (or redeploy the grain) to
roll out the new routes — no Terraform code change required.

## Example (Torque blueprint grain)

```yaml
api_gw_swagger:
  kind: terraform
  spec:
    source:
      store: Infrastructure
      path: terraform/api-gw-swagger
    inputs:
      - api_name: '{{ .inputs.["API Name"] }}'
      - swagger_bucket: '{{ .grains.swagger_bucket.outputs.bucket_name }}'
      - swagger_key: openapi/swagger.json
      - endpoint_type: '{{ .inputs.["Endpoint Type"] }}'
      - vpc_endpoint_ids_csv: '{{ .grains.fetch_vpc_endpoint.outputs.vpc_endpoint_id }}'
    outputs:
      - rest_api_id
      - stage_invoke_url
```
