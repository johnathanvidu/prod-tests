terraform {
  required_providers {
    torque = {
      source = "QualiTorque/torque"
    }
  }
}

provider "torque" {}

resource "torque_introspection_resource" "example" {
    display_name = "Vido Resource"
    image = "https://cdn-icons-png.flaticon.com/512/882/882730.png"
    introspection_data = {kind = "vido resource", ip = "192.168.0.22", pwd = "*****"}
}

resource "torque_introspection_resource" "example2" {
    display_name = "no image icon provided"
    # image = "https://www.svgrepo.com/show/533037/balloon.svg"

    introspection_data = {size = "xlarge", mode = "party"}
}

resource "torque_introspection_resource" "example3" {
    display_name = "image from cloudfront"
    image = "https://d3c8ee44fl0bya.cloudfront.net/blueprint_icons/94f5cf27-a703-4488-8107-2d4117b27e67"
    introspection_data = {size = "xlarge", mode = "party"}
}
