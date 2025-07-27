variable "project_name" {
  type      = string
  default   = "dev"
}

variable "icon" {
  type      = string
  default   = "star" # star, face, cloud, re, puzzle, uploadIcon, server, flow, pen, screen, suitcase, shovel
}

variable "agent_name" {
  type      = string
}

variable "aws_accounts" {
  type = map(object({
    account_name = string
    account_id   = string
  }))

  validation {
    condition = (
      length(keys(var.aws_accounts)) == 3 && # Enforce exactly 3 values
      contains(keys(var.aws_accounts), "dev") && # Enforce 'dev' key
      contains(keys(var.aws_accounts), "stage") && # Enforce 'stage' key
      contains(keys(var.aws_accounts), "prod")    # Enforce 'prod' key
    )
    error_message = "The 'aws_accounts' map must contain exactly three keys: 'dev', 'stage', and 'prod'"
  }
}