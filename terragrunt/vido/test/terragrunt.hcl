include "root" {
  path = find_in_parent_folders()
}

locals {
  vido = run_cmd("./vido.sh")
}
