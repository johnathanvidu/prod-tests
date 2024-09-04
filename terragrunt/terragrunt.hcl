// locals {
//   uid = run_cmd("echo",  uuid())
// }

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "vidos-amazing-bucket2"
    // bucket = "vidos-amazing-bucket-${local.uid}"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = false
  }
}