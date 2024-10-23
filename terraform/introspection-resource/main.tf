terraform {
  required_providers {
    torque = {
      source = "QualiTorque/torque"
      version = "0.4.7"
    }
  }
}

provider "torque" {
  host  = "https://portal.qtorque.io/"
  space = "Vido"
  token = "0TfedDYM6g5mVzye-b7CVy-zkcXI8mDjJy9G-WKPQJ4"
}

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
      "href" : "https://example1.com",
      "label" : "first ever tooltip"
    },
    {
      "icon" : "connect",
      "href" : "https://example2.com",
      "label" : "second tooltip is cool",
      "color" : "#ff0000" # this link will be colored red
    }]
}
