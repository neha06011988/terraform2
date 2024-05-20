module "base_label" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "ll"
}

module "subnet_cidr" {
  source          = "hashicorp/subnets/cidr"
  version         = "1.1.0"
  vpc_cidr_block  = var.vpc_cidr
  subnet_prefixes = ["24", "24"] # Two /24 subnets
}

module "public_subnet" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "public"
  attributes = ["main"]

  tags = {
    Name = module.base_label.name
  }
}

module "private_subnet" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "private"
  attributes = ["main"]

  tags = {
    Name = module.base_label.name
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = module.base_label.tags
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = module.subnet_cidr.ipv4_subnet_cidrs[0]
  availability_zone = data.aws_availability_zones.available.names[0] # Dynamic AZ
  map_public_ip_on_launch = true # Enable public IP assignment
  tags             = module.public_subnet.tags
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = module.subnet_cidr.ipv4_subnet_cidrs[1]
  availability_zone = data.aws_availability_zones.available.names[0] # Dynamic AZ
  tags             = module.private_subnet.tags
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = module.base_label.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = module.public_subnet.tags
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
