terraform {
  required_version = "~> 1.12"

  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "~> 1.98"
    }
  }
}
