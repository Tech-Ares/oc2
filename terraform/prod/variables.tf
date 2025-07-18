# terraform/modules/network/variables.tf
# 此檔案定義了網路模組接受的輸入變數。

variable "app_name" {
  description = "應用程式名稱，用於資源命名"
  type        = string
}

variable "aws_region" {
  description = "AWS 部署區域"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC 的 CIDR 區塊"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_port" {
  description = "應用程式監聽的 Port"
  type        = number
  default     = 8080
}

