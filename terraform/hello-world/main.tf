terraform {
  required_version = ">= 0.12.26"
}

# resource "time_sleep" "wait_30_seconds" {
#   create_duration = "120s"
# }

variable "vido2" {
  type = string
}

# website::tag::1:: The simplest possible Terraform module: it just outputs "Hello, World!"
output "hello_world" {
  value = "Hello, World!"
}
