provider "aws" {
  region = "ap-south-1"
}

module "web-server-cluster" {
  source        = "../../../modules/services/webserver-cluster/"
  cluster_name  = "web-servers-stage"
  instance_type = "t2.micro"
  max_size      = 2
  min_size      = 1
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  autoscaling_group_name = module.web-server-cluster.asg_name
  scheduled_action_name  = "scale-in-at-night"

  min_size         = 1
  max_size         = 2
  desired_capacity = 1
  recurrence       = "0 17 * * *"
}
resource "aws_security_group_rule" "allow_testing_inbound_staging" {
  from_port         = 0
  protocol          = ""
  security_group_id = ""
  to_port           = 0
  type              = ""
}