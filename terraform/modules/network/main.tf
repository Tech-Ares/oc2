# terraform/modules/network/main.tf
# 此模組定義了 VPC、子網、網際網路閘道、路由表、NAT 閘道和應用程式安全組。

# 數據源：獲取可用區列表
data "aws_availability_zones" "available" {
  state = "available"
}

# 資源：虛擬私有雲 (VPC)
resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.app_name}-vpc-${var.aws_region}"
  }
}

# 資源：公有子網 (用於 NAT Gateway 和可能的 ALB)
# 這裡使用單一公有子網，因為 EC2 實例將部署在單一 AZ 的公有子網中
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.app_vpc.cidr_block, 8, 0) # 例如 10.0.0.0/24
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true # 允許自動分配公有 IP
  tags = {
    Name = "${var.app_name}-public-subnet-${var.aws_region}"
  }
}

# 資源：網際網路閘道 (Internet Gateway)
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "${var.app_name}-igw-${var.aws_region}"
  }
}

# 資源：公有路由表 (將公有子網流量導向 IGW)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
  tags = {
    Name = "${var.app_name}-public-route-table-${var.aws_region}"
  }
}

# 資源：路由表關聯 (將公有子網與公有路由表關聯)
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# 資源：安全組 (Security Group，控制進出 EC2 實例和 ECS 任務的流量)
resource "aws_security_group" "app_sg" {
  name        = "${var.app_name}-security-group-${var.aws_region}"
  description = "Allow inbound traffic to ECS EC2 instances"
  vpc_id      = aws_vpc.app_vpc.id

  # 允許來自任何地方的應用程式 Port 入站流量
  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 根據你的需求限制來源 IP 範圍
    description = "Allow HTTP traffic on port ${var.app_port}"
  }

  # 允許所有出站流量
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-sg-${var.aws_region}"
  }
}

