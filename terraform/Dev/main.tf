# terraform/dev/main.tf
# 此檔案是 Dev 環境的根模組，它調用並組裝通用模組來構建 Dev 環境的基礎設施。

# 模組：網路基礎設施
module "network" {
  source     = "../modules/network" # 相對路徑引用模組
  app_name   = var.app_name_prefix
  aws_region = var.aws_region
  app_port   = var.app_port
}

# 模組：IAM 角色
module "iam" {
  source     = "../modules/iam" # 相對路徑引用模組
  app_name   = var.app_name_prefix
  aws_region = var.aws_region
}

# 模組：ECS 應用程式服務
module "ecs_app" {
  source                      = "../modules/ecs_app" # 相對路徑引用模組
  app_name                    = var.app_name_prefix
  aws_region                  = var.aws_region
  ami_id                      = var.ami_id # 從環境變數獲取 AMI ID
  instance_type               = var.instance_type
  public_subnet_id            = module.network.public_subnet_id # 從 network 模組獲取輸出
  app_security_group_id       = module.network.app_security_group_id
  ecs_instance_profile_name   = module.iam.ecs_instance_profile_name # 從 iam 模組獲取輸出
  ecr_repo_name               = var.ecr_repo_name
  image_tag                   = var.image_tag
  cpu                         = var.cpu
  memory                      = var.memory
  app_port                    = var.app_port
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  desired_count               = var.desired_count
}

