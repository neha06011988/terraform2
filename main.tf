module "base_label" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "ll"
}

module "subnet_cidr" {
  source   = "hashicorp/subnets/cidr"
  version  = "1.0.0"
  
  base_cidr_block = var.vpc_cidr
  networks = [
    {
      name = "public"
    },
    {
      name = "private"
    }
  ]
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
