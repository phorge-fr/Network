provider "routeros" {
  hosturl  = var.hosturl
  username = var.username
  password = var.password
  insecure = true # the router serves a self-signed certificate
}
