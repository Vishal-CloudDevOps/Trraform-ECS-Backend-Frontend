variable "project_name" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "ecs_security_group_id" {
  type        = string
  description = "Security group ID of ECS tasks that should be allowed to connect to RDS"
}

variable "subnets" {
  type        = list(string)
  description = "Private subnets for RDS"
}

variable "db_user" {
  type        = string
  description = "Database username for backend app"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where RDS will be deployed"
}
