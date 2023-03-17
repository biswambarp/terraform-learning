provider "aws" {
  region = "ap-south-1"
}
resource "aws_db_instance" "my-sql-instance" {
  identifier_prefix = "terraform-up-and-running"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  skip_final_snapshot = true
  db_name = "example_database"

  username = var.db_username
  password = var.db_password

}
variable "db_username" {
  description = "Master Username for mysql"
  type = string
  sensitive = true
  default = "dude"
}

variable "db_password" {
  description = "Master password for mysql"
  type = string
  sensitive = true
  default = "password"
}

output "my-sql-address" {
  value = aws_db_instance.my-sql-instance.address
}
output "mysql-port" {
  value = aws_db_instance.my-sql-instance.port
}