output "ecs_service" {
  description = "The ESC service outputs."
  value       = module.ecs_service
}

output "code_deploy" {
  description = "The code deploy outputs."
  value       = module.code_deploy
}
