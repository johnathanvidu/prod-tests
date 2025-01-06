variable "name" {
  type    = string
  default = "MyTemplate"
}

variable "subject" {
  type    = string
  default = "Greetings, {{name}}!"
}

variable "html" {
  type    = string
  default = "<h1>Hello {{name}},</h1><p>Your favorite animal is {{favoriteanimal}}.</p>"
}

variable "text" {
  type    = string
  default = "Hello {{name}},\r\nYour favorite animal is {{favoriteanimal}}."
}

