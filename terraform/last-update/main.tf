terraform {
  required_providers {
    time = {
      source = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

resource "time_rotating" "terraform_last_updated" {
  rotation_days = 0
}

output "last_applied_timestamp" {
  value = time_rotating.terraform_last_updated.id
}
