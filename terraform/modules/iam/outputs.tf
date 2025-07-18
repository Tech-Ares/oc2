# terraform/modules/iam/outputs.tf
# 此檔案定義了 IAM 模組輸出的值。

output "ecs_instance_profile_name" {
  description = "ECS 容器實例的 IAM 實例設定檔名稱"
  value       = aws_iam_instance_profile.ecs_instance_profile.name
}

output "ecs_task_execution_role_arn" {
  description = "ECS 任務執行角色 ARN"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

