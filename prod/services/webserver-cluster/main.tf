provider "aws" {
  region = "ap-south-1"
}

module "web-server-cluster" {
  source        = "../../../modules/services/webserver-cluster/"
  cluster_name  = "web-serve-prod"
  instance_type = "t2.micro"
  max_size      = 2
  min_size      = 1
}
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  autoscaling_group_name = module.web-server-cluster.asg_name
  scheduled_action_name  = "scale-out-during-business-hours"

  min_size         = 1
  max_size         = 2
  desired_capacity = 1
  recurrence       = "0 9 * * *"
}