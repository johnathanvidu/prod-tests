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
  type        = string
  sensitive   = true
  description = "PEM private key content for SSH authentication"
}

variable "direct_link" {
  type        = bool
  default     = true
  description = <<-EOT
    true  (default) — direct qtoken URL via get_direct_link.py.
                      Re-authenticates on every click; link never expires.
                      Requires /disableValidateLink on the QualiX server.
    false           — token-based URL via get_token.py.
                      POSTs to /remote/api/tokens at apply time; expires
                      with the Guacamole session (~30 min inactivity).
                      Use "Update environment" in Torque to refresh.
  EOT
}

locals {
  # Shared query inputs for both data sources
  query = {
    qualix_ip  = var.qualix_ip
    hostname   = var.target_ip_address
    protocol   = var.protocol
    port       = tostring(var.connection_port)
    username   = var.target_username
    access_key = var.access_key
    _ts        = timestamp() # changes every plan → forces re-execution on every apply
  }
}

# ── Option A: direct URL (get_direct_link.py) ─────────────────────────────────
# Each browser click re-authenticates and registers the connection on-demand.
# The link itself never expires.
data "external" "qualix_direct" {
  count   = var.direct_link ? 1 : 0
  program = ["python3", "${path.module}/get_direct_link.py"]
  query   = local.query
}

# ── Option B: token-based URL (get_token.py) ──────────────────────────────────
# POSTs to /remote/api/tokens at apply time and embeds the session token.
# Expires when the Guacamole session times out (~30 min inactivity by default).
data "external" "qualix_token" {
  count   = var.direct_link ? 0 : 1
  program = ["python3", "${path.module}/get_token.py"]
  query   = local.query
}

output "qualix_link" {
  sensitive = true
  value = var.direct_link ? (
    data.external.qualix_direct[0].result.link
  ) : (
    "https://${var.qualix_ip}/remote/#/client/${data.external.qualix_token[0].result.qid}/?token=${data.external.qualix_token[0].result.auth_token}"
  )
}
