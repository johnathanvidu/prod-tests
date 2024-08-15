provider "null" {}

resource "null_resource" "print_env_vars" {
  provisioner "local-exec" {
    command = "printenv"
  }
}
