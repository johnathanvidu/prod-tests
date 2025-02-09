terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.86.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

resource "aws_ses_template" "MyTemplate" {
  name    = "MyTemplate"
  subject = "Greetings, {{name}}!"
  html    = "<h1>Hello {{name}},</h1><p>Your favorite animal is {{favoriteanimal}}.</p>"
  text    = "Hello {{name}},\r\nYour favorite animal is {{favoriteanimal}}."
}