include "root" {
  path = find_in_parent_folders()
}

locals {
  vido = run_cmd("chmod +x ${get_terragrunt_dir()}/vido.sh && ${get_terragrunt_dir()}/vido.sh")
}
