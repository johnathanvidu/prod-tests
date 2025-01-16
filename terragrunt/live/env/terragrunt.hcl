include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::ssh://cs18@vs-ssh.visualstudio.com/v3/cs18/Torque/veracyte-demo//terragrunt/modules/hello-world-remote"
}

#vido
