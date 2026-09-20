provider "routeros" {
  hosturl        = var.hosturl
  username       = var.username
  password       = var.password
  ca_certificate = var.insecure_tls ? null : "${path.module}/certs/router-ca.pem"
  insecure       = var.insecure_tls
}
