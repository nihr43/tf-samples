locals {
  hosts = toset(split("\n", trimspace(file("hosts.txt"))))
}

resource "incus_instance" "instance" {
  for_each = local.hosts
  name     = "alpine-${each.value}"
  image    = "images:alpine/3.21"

  config = {
    "boot.autostart" = true
    "limits.cpu"     = 2
  }
}
