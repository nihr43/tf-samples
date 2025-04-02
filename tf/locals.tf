locals {
  instances = {
    "instance1" = {
      hostname = "a"
      image = "images:alpine/3.21"
    }
    "instance2" = {
      hostname = "b"
      image = "images:alpine/edge"
    }
    "instance3" = {
      hostname = "c"
      image = "images:alpine/3.20"
    }
  }
}
