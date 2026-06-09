variable "qualix_ip" {
  type = string
}

variable "protocol" {
  type    = string
  default = "ssh"
}

variable "connection_port" {
  type    = number
  default = 22
}

variable "target_ip_address" {
  type = string
}

variable "target_username" {
  type = string
}

variable "access_key" {
  type      = string
  sensitive = true
  description = "PEM private key content for SSH authentication"
}

resource "random_uuid" "resource_uuid" {
}

resource "time_static" "current_time_static" {
}

locals {
  guid            = random_uuid.resource_uuid.result
  guid_stripped   = replace(local.guid, "-", "")
  curr_time_secs  = time_static.current_time_static.unix
  qtoken_clean    = "${local.guid_stripped},${local.curr_time_secs * 10000000}"
  qtoken_encoded  = base64encode(local.qtoken_clean)
  qtoken_url_safe = replace(replace(replace(local.qtoken_encoded, "+", "-"), "/", "_"), "=", "~")

  # Encode PEM using the same URL-safe base64 convention as qtoken/password.
  # QualiConfiguration maps access-key → private-key for the SSH session.
  # NOTE: The server's ACCESS_KEY case must call DecryptString (like PASSWORD does)
  # to reverse this encoding — without that server-side fix the connection will fail.
  access_key_url_safe = replace(replace(replace(base64encode(var.access_key), "+", "-"), "/", "_"), "=", "~")
}

output "qualix_link" {
  sensitive = true
  value     = "https://${var.qualix_ip}/remote/#/client/c/${var.protocol}${local.guid_stripped}?qtoken=${local.qtoken_url_safe}&hostname=${var.target_ip_address}&protocol=${var.protocol}&port=${var.connection_port}&username=${var.target_username}&access-key=${local.access_key_url_safe}"
}
