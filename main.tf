terraform {
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "0.3.0"
    }
  }
}

provider "incus" {
  generate_client_certificates = true
  accept_remote_certificate    = true

  remote {
    name    = "local"
    scheme  = "unix"
    address = ""
    default = true
  }
}
