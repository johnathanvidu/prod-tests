# Define the input variable
variable "in" {
  description = "A complex configuration mapping deployment environments to network structures"
  type = map(object({
    Vido           = string
    Hello = optional(bool, true)
    
    # Nested map of objects defining subnets within this environment
    MyName = map(object({
      Is = string
      Vido       = string 
    }))
  }))
}
# Output the value of the input variable
output "out" {
  value = merge([
    for env_key, env_val in var.in : {
      for myname_key, myname_val in env_val.MyName : 
        "${env_key}.${myname_key}" => myname_val.Vido
    }
  ]...) # The ... is an expansion operator that merges the list of maps into one flat map
}