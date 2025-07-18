# terraform/modules/ecs_app/main.tf
# 此模組定義了 ECS 應用程式的核心組件：ECR、ECS 叢集、EC2 實例、任務定義、服務和 CloudWatch 日誌組。

# 資源：ECR 儲存庫 (用於存放 Docker 映像檔)
resource "aws_ecr_repository" "app_ecr" {
  name                 = var.ecr_repo_name # ECR 儲存庫名稱通常跨環境相同
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "${var.app_name}-ecr-repository-${var.aws_region}"
  }
}

# 資源：CloudWatch 日誌組 (用於收集 ECS 任務日誌)
resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/ecs/${var.app_name}-${var.aws_region}"
  retention_in_days = 7
  tags = {
    Name = "${var.app_name}-log-group"
  }
}

# 資源：ECS 叢集 (用於 EC2 啟動類型)
resource "aws_ecs_cluster" "my_ec2_cluster" {
  name = "${var.app_name}-ec2-ecs-cluster-${var.aws_region}"
  tags = {
    Name = "${var.app_name}-ec2-ecs-cluster"
  }
}

# 資源：EC2 容器實例 (將運行 Docker 容器的 EC2 虛擬機)
resource "aws_instance" "ecs_container_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [var.app_security_group_id]
  iam_instance_profile   = var.ecs_instance_profile_name

  associate_public_ip_address = true # 讓 EC2 實例自動獲取公有 IP

  # User Data 腳本：在 EC2 啟動時安裝 Docker 並配置 ECS 代理
  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.my_ec2_cluster.name} >> /etc/ecs/ecs.config
              sudo yum update -y
              sudo amazon-linux-extras install -y docker
              sudo systemctl enable docker --now
              sudo usermod -a -G docker ec2-user
              sudo systemctl enable ecs --now
              EOF

  tags = {
    Name = "${var.app_name}-Container-Instance-${var.aws_region}"
  }
}

# 資源：ECS 任務定義 (Task Definition，Docker 容器的藍圖)
resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.app_name}-task-definition-${var.aws_region}"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name  = "${var.app_name}-container"
      image = "${aws_ecr_repository.app_ecr.repository_url}:${var.image_tag}"
      cpu    = var.cpu
      memory = var.memory
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
        }
      ]
      environment = [
        # 可選：定義環境變數
        # { name = "APP_ENV", value = "production" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      # 健康檢查 (可選)
      # healthCheck = {
      #   command = ["CMD-SHELL", "curl -f http://localhost:${var.app_port}/health || exit 1"]
      #   interval = 30
      #   timeout = 5
      #   retries = 3
      #   startPeriod = 60
      # }
    }
  ])

  execution_role_arn = var.ecs_task_execution_role_arn
  tags = {
    Name = "${var.app_name}-task-definition"
  }
}

# 資源：ECS 服務 (Service，確保任務持續運行)
resource "aws_ecs_service" "app_service" {
  name            = "${var.app_name}-ecs-service-${var.aws_region}"
  cluster         = aws_ecs_cluster.my_ec2_cluster.arn
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = var.desired_count

  launch_type = "EC2"

  network_configuration {
    subnets         = [var.public_subnet_id]
    security_groups = [var.app_security_group_id]
    # assign_public_ip = true # 此參數不支援 EC2 啟動類型與 awsvpc 網路模式組合
  }

  deployment_controller {
    type = "ECS"
  }

  tags = {
    Name = "${var.app_name}-ecs-service"
  }
}

