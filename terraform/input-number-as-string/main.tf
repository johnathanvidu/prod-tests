variable "number" {
   type = string
}

variable "number2" {
   type = string
}

output "output" {
  value = var.number
}

output "output2" {
  value = var.number2
}
