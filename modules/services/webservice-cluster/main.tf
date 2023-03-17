resource "aws_launch_configuration" "example" {
  image_id        = "ami-0f8ca728008ff5af4"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance.id]
  user_data       = <<-EOF
                  #!/bin/bash
                  echo "Hello, World" > index.html
                  nohup busybox httpd -f -p ${var.server_port} &
                  EOF
  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
  ingress {
    from_port = 8080
    protocol  = local.tcp_protocol
    to_port   = 8080
  }
}

resource "aws_alb" "example" {
  name               = "terraform-alb-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]

}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.example.arn
  port              = local.http_port
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = "404"
    }
  }
}
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

output "alb_dns_name" {
  value = aws_alb.example.dns_name
}
resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"
  ingress {
    from_port   = local.http_port
    protocol    = local.tcp_protocol
    to_port     = local.http_port
    cidr_blocks = local.all_ips
  }
  egress {
    from_port   = local.any_port
    protocol    = local.any_protocol
    to_port     = local.any_port
    cidr_blocks = local.all_ips
  }
}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


variable "server_port" {
  default = 8080
  type    = number
}

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}


