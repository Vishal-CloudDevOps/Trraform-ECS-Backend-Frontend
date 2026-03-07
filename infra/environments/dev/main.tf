module "vpc" {
  source       = "../../modules/vpc"
  project_name = var.project_name
  aws_region   = var.aws_region
}

module "iam" {
  source = "../../modules/iam"
}

module "ecr" {
  source       = "../../modules/ecr"
  project_name = var.project_name
}

module "alb" {
  source       = "../../modules/alb"
  project_name = var.project_name
  subnets      = module.vpc.public_subnets
  vpc_id       = module.vpc.vpc_id
}

module "rds" {
  source            = "../../modules/rds"
  project_name      = var.project_name
  db_password       = var.db_password
  #master_password   = var.master_password
  db_user           = var.db_user
  subnets           = module.vpc.private_subnets
  vpc_id            = module.vpc.vpc_id
  ecs_security_group_id = module.ecs_backend.ecs_security_group_id

}

# 🔑 Backend Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn

  container_definitions = templatefile(
    "${path.module}/../../../backend/backend-task-def.json",
    {
      image       = "${module.ecr.backend_repo_url}:latest"
      db_host     = module.rds.db_endpoint
      db_user     = var.db_user
      db_password = var.db_password
      db_name     = var.db_name
      region      = var.aws_region
    }
  )
}

# 🔑 Frontend Task Definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
  

  container_definitions = templatefile(
    "${path.module}/../../../frontend/frontend-task-def.json",
    {
      image       = "${module.ecr.frontend_repo_url}:latest"
      backend_url = module.alb.backend_dns_name
      region      = var.aws_region
    }
  )
}

module "ecs_backend" {
  source               = "../../modules/ecs"
  project_name         = "${var.project_name}-backend"
  cluster_name         = "backend-cluster"
  vpc_id               = module.vpc.vpc_id
  subnets              = module.vpc.public_subnets
  alb_target_group_arn = module.alb.backend_tg_arn
  security_group_id    = module.alb.security_group_id
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
  task_definition_arn  = aws_ecs_task_definition.backend.arn
}

module "ecs_frontend" {
  source               = "../../modules/ecs"
  project_name         = "${var.project_name}-frontend"
  cluster_name         = "frontend-cluster"
  vpc_id               = module.vpc.vpc_id
  subnets              = module.vpc.public_subnets
  alb_target_group_arn = module.alb.frontend_tg_arn
  security_group_id    = module.alb.security_group_id
  execution_role_arn   = module.iam.ecs_task_execution_role_arn
  task_role_arn        = module.iam.ecs_task_role_arn
  task_definition_arn  = aws_ecs_task_definition.frontend.arn
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/demo-frontend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/demo-backend"
  retention_in_days = 7
}