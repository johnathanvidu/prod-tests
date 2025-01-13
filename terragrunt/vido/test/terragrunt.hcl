include "root" {
  path = find_in_parent_folders()
}

locals {
  vido = run_cmd("${get_terragrunt_dir()}/vido.sh")
}
