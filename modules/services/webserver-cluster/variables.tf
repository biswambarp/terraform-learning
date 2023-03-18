variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}
variable "instance_type" {
  description = "The type of Ec2 to run"
  type = string
}
variable "min_size" {
  description = "The minimum number of EC2 Instances in ASG"
  type = number
}
variable "max_size" {
  description = "The maximum number of EC2 instances in ASG"
}