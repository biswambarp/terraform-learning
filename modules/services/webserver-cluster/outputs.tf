output "asg_name" {
  value = aws_autoscaling_group.example.name
}
output "alb_dns_name" {
  value = aws_alb.example.dns_name
}
output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "The id of the security group attached to the load balancer"
}