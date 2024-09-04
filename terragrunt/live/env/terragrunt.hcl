include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/johnathanvidu/prod-tests.git//terragrunt/modules/hello-world-remote"
}