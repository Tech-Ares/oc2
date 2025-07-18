# terraform/modules/ecs_app/variables.tf
# 此檔案定義了 ECS 應用程式模組接受的輸入變數。

variable "app_name" {
  description = "應用程式名稱，用於資源命名"
  type        = string
}

variable "aws_region" {
  description = "AWS 部署區域"
  type        = string
}

variable "ami_id" {
  description = "ECS 容器實例使用的 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "ECS 容器實例的 EC2 實例類型"
  type        = string
}

variable "public_subnet_id" {
  description = "公有子網 ID，用於部署 EC2 容器實例"
  type        = string
}

variable "app_security_group_id" {
  description = "應用程式安全組 ID"
  type        = string
}

variable "ecs_instance_profile_name" {
  description = "ECS 容器實例的 IAM 實例設定檔名稱"
  type        = string
}

variable "ecr_repo_name" {
  description = "ECR 儲存庫名稱"
  type        = string
}

variable "image_tag" {
  description = "要部署的 Docker 映像檔標籤 (例如 Git SHA)"
  type        = string
}

variable "cpu" {
  description = "ECS 任務定義中容器的 CPU 限制 (單位：CPU 單元)"
  type        = number
}

variable "memory" {
  description = "ECS 任務定義中容器的記憶體限制 (單位：MB)"
  type        = number
}

variable "app_port" {
  description = "應用程式監聽的 Port"
  type        = number
}

variable "ecs_task_execution_role_arn" {
  description = "ECS 任務執行角色 ARN"
  type        = string
}

variable "desired_count" {
  description = "ECS 服務期望運行的任務數量"
  type        = number
}

