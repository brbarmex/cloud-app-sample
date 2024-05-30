resource "aws_vpc" "vpc" {
  tags       = local.tags
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags

  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_subnet" "pub_subnet_az_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "sa-east-1a"
  depends_on              = [aws_vpc.vpc]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pvt_subnet_az_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "sa-east-1a"
  depends_on              = [aws_vpc.vpc]
  map_public_ip_on_launch = false
}

resource "aws_subnet" "pvt_subnet_az_1b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "sa-east-1b"
  depends_on              = [aws_vpc.vpc]
  map_public_ip_on_launch = false
}

resource "aws_route_table" "pub_route_table" {

  vpc_id = aws_vpc.vpc.id
  tags   = local.tags

  depends_on = [
    aws_vpc.vpc,
    aws_subnet.pub_subnet_az_1a,
  ]
}

resource "aws_route_table_association" "pub_route_table_associatio_igw" {
  route_table_id = aws_route_table.pub_route_table.id
  subnet_id      = aws_subnet.pub_subnet_az_1a.id
}

resource "aws_route" "pub_route" {
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.pub_route_table.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "pvt_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags

  depends_on = [
    aws_vpc.vpc,
    aws_subnet.pvt_subnet_az_1a,
    aws_subnet.pvt_subnet_az_1b,
  ]
}

resource "aws_route_table_association" "pvt_route_table_association_subnet1a" {
  route_table_id = aws_route_table.pvt_route_table.id
  subnet_id      = aws_subnet.pvt_subnet_az_1a.id
}

resource "aws_route_table_association" "pvt_route_table_association_subnet1b" {
  route_table_id = aws_route_table.pvt_route_table.id
  subnet_id      = aws_subnet.pvt_subnet_az_1b.id
}