output "lb_dns_name" {
  value = aws_lb.main.dns_name
}

output "blue_target_group" {
  description = "blue target group arn"
  value       = module.ecs-service.blue_target_group
}

output "green_target_group" {
  description = "green target group arn"
  value       = module.ecs-service.blue_target_group
}
