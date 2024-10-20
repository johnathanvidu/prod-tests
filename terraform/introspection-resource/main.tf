terraform {
  required_providers {
    torque = {
      source = "QualiTorque/torque"
      version = "0.4.7"
    }
  }
}

provider "torque" {}

resource "torque_introspection_resource" "example" {
  display_name       = "vido"
  image              = "resource_image"
  introspection_data = {
    "data1" : "value1" 
    "data2" : "value2" 
    "data3" : "value3" 
  }
  # new button section
  links = [ {
      "icon" : "connect",
      "href" : "https://example1.com" 
    },
    {
      "icon" : "connect",
      "href" : "https://example2.com"
    }]
}
