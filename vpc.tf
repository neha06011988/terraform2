module "label_vpc" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "vpc"
  attributes = ["main"]
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = module.subnet_cidr.ipv4_subnet_cidrs[1]
  availability_zone = data.aws_availability_zones.available.names[0] # Dynamic AZ
  tags             = module.private_subnet.tags
}
