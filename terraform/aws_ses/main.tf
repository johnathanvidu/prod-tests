provider "aws" {
  region = "eu-west-1"
}

resource "aws_ses_template" "MyTemplate" {
  name    = var.name
  subject = var.subject
  html    = var.html
  text    = var.text
}
