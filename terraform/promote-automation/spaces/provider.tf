terraform {
  required_providers {
    torque = {
      source = "QualiTorque/torque"
      version = "0.8.2"
    }
  }
}

provider "torque" {
}