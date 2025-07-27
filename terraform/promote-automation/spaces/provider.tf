terraform {
  required_providers {
    torque = {
      source = "QualiTorque/torque"
      version = "0.8.4"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.0" # Use a compatible version
    }
  }
}

provider "torque" {
}