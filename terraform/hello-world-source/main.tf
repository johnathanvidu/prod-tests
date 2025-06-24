terraform {
  required_version = ">= 1.4.0"
}

module "vido" {
    source = "./modules"
}

# website::tag::1:: The simplest possible Terraform module: it just outputs "Hello, World!"
output "hello_world" {
  value = "Hello, World!"
}

# vido
