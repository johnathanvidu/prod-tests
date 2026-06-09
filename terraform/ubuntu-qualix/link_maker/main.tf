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
  guid           = random_uuid.resource_uuid.result
  guid_stripped  = replace(local.guid, "-", "")
  curr_time_secs = time_static.current_time_static.unix

  qtoken_clean   = "${local.guid_stripped},${local.curr_time_secs * 10000000}"
  qtoken_encoded = base64encode(local.qtoken_clean)
  qtoken_url_safe = replace(replace(replace(local.qtoken_encoded, "+", "-"), "/", "_"), "=", "~")

  # 5-char connection ID that QualiX registers when the "qualix" param is present.
  # Matches what QxController puts in the final client URL.
  qid = substr("${var.protocol}${local.guid_stripped}", 0, 5)
}

# POST to /remote/api/tokens — registers the connection and returns a session token.
# Python3 is required on the Torque agent (standard on all Linux runners).
data "external" "qualix_token" {
  program = ["python3", "${path.module}/get_token.py"]

  query = {
    qualix_ip  = var.qualix_ip
    qtoken     = local.qtoken_url_safe
    hostname   = var.target_ip_address
    protocol   = var.protocol
    port       = tostring(var.connection_port)
    username   = var.target_username
    access_key = var.access_key
  }
}

output "qualix_link" {
  sensitive = true
  value     = "https://${var.qualix_ip}/remote/#/client/${local.qid}/?token=${data.external.qualix_token.result.auth_token}"
}
