variable "assume_role_policy" {
  description = "The assume role policy document"
  type        = string
  default     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "example" {
  name               = "example-role"
  assume_role_policy = var.assume_role_policy
}

output "role_arn" {
  value = aws_iam_role.example.arn
}
