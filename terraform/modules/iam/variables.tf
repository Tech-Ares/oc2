# terraform/modules/iam/variables.tf
# 此檔案定義了 IAM 模組接受的輸入變數。

variable "app_name" {
  description = "應用程式名稱，用於資源命名"
  type        = string
}

variable "aws_region" {
  description = "AWS 部署區域"
  type        = string
}

