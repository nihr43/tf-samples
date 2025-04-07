resource "aws_key_pair" "my_key" {
  key_name   = "my-ssh-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKL+1xp+nQIbu02D1NmU+4RTPGblUML21TSzF/Pxg5GM"
}

resource "aws_launch_template" "example" {
  name_prefix   = "example-template"
  image_id      = "ami-03420506796dd6873"
  instance_type = "t3a.nano"
  key_name      = aws_key_pair.my_key.key_name

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt update
    apt install nginx -y
    systemctl start nginx
    systemctl enable nginx
    echo "$(hostname)" >> /var/www/html/index.nginx-debian.html
EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.example.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "autoscaling-instance"
    }
  }
}


resource "aws_autoscaling_group" "example" {
  desired_capacity = 2
  min_size         = 1
  max_size         = 4

  vpc_zone_identifier = [
    aws_subnet.subnet_1.id,
    aws_subnet.subnet_2.id
  ]

  # Reference the launch template
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 30

  tag {
    key                 = "Name"
    value               = "autoscaling-group"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
}
