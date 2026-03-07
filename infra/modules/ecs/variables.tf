variable "project_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "alb_target_group_arn" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

# 🔑 New variable to accept task definition ARN from environment
variable "task_definition_arn" {
  type = string
}