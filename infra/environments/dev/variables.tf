variable "project_name" { type = string }
variable "aws_region" { type = string }
variable "security_group_id" { type = string }
variable "db_user" {
  type        = string
  description = "Database username for backend app"
}

variable "db_name" {
  type        = string
  description = "Database name for backend app"
}


variable "db_password" {
  type        = string
  description = "App user password for demoapp DB"
  sensitive   = true
}
