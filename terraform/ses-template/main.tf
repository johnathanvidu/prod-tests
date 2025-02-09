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
  html    = var.html
  text    = var.text
}