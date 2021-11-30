output "target_group_blue" {
  description = "The outputs of the blue target group."
  value       = aws_lb_target_group.main["blue"]
}

output "target_group_green" {
  description = "The outputs of the green target group."
  value       = aws_lb_target_group.main["green"]
}
