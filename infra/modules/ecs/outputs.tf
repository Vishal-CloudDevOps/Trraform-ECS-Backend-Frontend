output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "ecs_task_definition_arn" {
  value = var.task_definition_arn
}


output "ecs_security_group_id" {
  description = "The security group ID used by ECS tasks/services"
  value       = var.security_group_id
}