terraform {
  required_version = "~> 1.12"

  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "~> 1.98"
    }
  }
}

provider "routeros" {
  hosturl  = var.hosturl
  username = var.username
  password = var.password
  insecure = true # the router serves a self-signed certificate
}
