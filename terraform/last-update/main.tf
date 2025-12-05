terraform {
  required_providers {
    time = {
      source = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

resource "time_static" "always_update" {
  triggers = {
    force_update = timestamp()
  }
}

output "last_applied_timestamp" {
  value = time_static.always_update.rfc3339 # or time_static.always_update.unix
}
