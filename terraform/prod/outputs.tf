# terraform/modules/network/outputs.tf
# 此檔案定義了網路模組輸出的值。

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.app_vpc.id
}

output "public_subnet_id" {
  description = "公有子網 ID"
  value       = aws_subnet.public_subnet.id
}

output "app_security_group_id" {
  description = "應用程式安全組 ID"
  value       = aws_security_group.app_sg.id
}

