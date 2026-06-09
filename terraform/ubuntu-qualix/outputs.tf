output "public_ip" {
  description = "Public IP of the Ubuntu instance"
  value       = aws_instance.ubuntu_instance.public_ip
}

output "qualix_link" {
  description = "QualiX SSH link (key-based auth)"
  value       = module.qualix_ubuntu_link.qualix_link
  sensitive   = true
}

output "private_key_pem" {
  description = "Generated SSH private key (PEM) — store securely"
  value       = tls_private_key.this.private_key_pem
  sensitive   = true
}
