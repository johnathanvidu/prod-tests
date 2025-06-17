variable "list_strings" {
  type        = list(string)
}

variable "map_bool" {
  description = "Optional map of lowercase unprefixed name => boolean, defaults to false."
  type        = map(bool)
  default     = {}
}

variable "map_list_string" {
  description = "Map of lowercase unprefixed name => list of top level folder objects."
  type        = map(list(string))
  default     = {}
}

variable "complex" {
  type = map(set(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                        = optional(number)
      send_age_if_zero           = optional(bool)
    })
  })))
  default     = {}
}
