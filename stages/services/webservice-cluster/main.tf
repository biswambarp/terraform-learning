provider "aws" {
  region = "ap-south-1"
}

module "web-server-cluster" {
  source = "../../../modules/services/webservice-cluster/"
  cluster_name = "web-servers-stage"
  instance_type = "t2.micro"
  max_size = 2
  min_size = 1
}