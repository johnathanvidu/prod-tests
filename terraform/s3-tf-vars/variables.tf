variable "name" {
    description = "Name of S3 bucket"
    type = string
}

variable "region" {
    description = "Region where to create resources" 
    type = string
    default = "eu-west-1"
}

variable "user" {
    description = "Username to assign permissions for S3 bucket to. If left blank, will not create permissions."
    default = "none"
}
