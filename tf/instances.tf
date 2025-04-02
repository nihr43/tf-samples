resource "incus_instance" "instance" {
  for_each = local.instances
  name     = "alpine-${each.value.hostname}"
  image    = each.value.image

  config = {
    "boot.autostart" = true
    "limits.cpu"     = 2
  }

  wait_for {
    type = "ipv4"
  }

  provisioner "local-exec" {
    command = <<EOF
incus exec ${self.name} -- apk add nginx
incus exec ${self.name} -- rc-update add nginx
incus exec ${self.name} -- rc-service nginx start
EOF
  }
}
