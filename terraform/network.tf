resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = merge(local.tags, {
    Name = "vpc-brbarme"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.tags, {
    Name = "igw-brbarme"
  })

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
  tags = merge(local.tags, {
    Name = "pub-brbarme1a"
  })
}

resource "aws_subnet" "pvt_subnet_az_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "sa-east-1a"
  depends_on              = [aws_vpc.vpc]
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = "pvt-brbarme1a"
  })
}

resource "aws_route_table" "pub_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.tags, {
    Name = "pub-brbarme"
  })

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
  tags = merge(local.tags, {
    Name = "pvt-brbarme"
  })

  depends_on = [
    aws_vpc.vpc,
    aws_subnet.pvt_subnet_az_1a,
  ]
}

resource "aws_route_table_association" "pvt_route_table_association_subnet1a" {
  route_table_id = aws_route_table.pvt_route_table.id
  subnet_id      = aws_subnet.pvt_subnet_az_1a.id
}

resource "aws_security_group" "pub-sg-brbarme" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "pub-sg-brbarme"
  })
}

resource "aws_security_group" "pvt-sg-brbarme" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "pvt-sg-brbarme"
  })
}