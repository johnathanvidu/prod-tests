# Define the input variable
variable "in" {
  description = "The value to be output"
  type        = string
}

# Output the value of the input variable
output "out" {
  value = var.input_value
}
