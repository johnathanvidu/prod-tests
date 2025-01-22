provider "aws" {

}

variable "assume_role_policy" {
  type        = string
  description = "The assume role policy to be attached to a role"
}
resource "aws_iam_role" "iam_role" {
  name               = "vido"
  assume_role_policy = var.assume_role_policy
}
