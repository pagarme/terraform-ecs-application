output "lb_dns_name" {
  value = aws_lb.main.dns_name
}

output "blue_target_group" {
  value = module.ecs-service.blue_target_group
}

output "green_target_group" {
  value = module.ecs-service.blue_target_group
}
