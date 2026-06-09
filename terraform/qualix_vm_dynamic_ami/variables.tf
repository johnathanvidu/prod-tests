variable aws_region {
    description = "AWS Region in which to deploy" 
    type = string
    default = "eu-west-1"    
}

variable "app_subnet_id" {
    description = "The application subnet ID to deploy QualiX in"
    type = string
}

variable "env_id" {
    description = "Unique identifier for this environment, used for tagging and naming resources"
    type = string  
}