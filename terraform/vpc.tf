# vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.base_name
  }
}

# public subnet
resource "aws_subnet" "public-subnet-a" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "${var.base_name}-vpc-public-subnet-a"
  }
}

# private subnet
resource "aws_subnet" "private-subnet-a" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "${var.base_name}-vpc-private-subnet-a"
  }
}

resource "aws_subnet" "private-db-subnet-a" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "${var.base_name}-vpc-private-db-subnet-a"
  }
}

resource "aws_subnet" "public-subnet-c" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "${var.base_name}-vpc-public-subnet-c"
  }
}

resource "aws_subnet" "private-subnet-c" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "${var.base_name}-vpc-private-subnet-c"
  }
}

resource "aws_subnet" "private-db-subnet-c" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "${var.base_name}-vpc-private-db-subnet-c"
  }
}

# internet gateway
resource "aws_internet_gateway" "vpc-igw" {
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    Name = "${var.base_name}-vpc-igw"
  }
}

# public routing
resource "aws_route_table" "vpc-public-rt" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-igw.id
  }

  tags = {
    Name = "${var.base_name}-vpc-public-rt"
  }
}

# private routing
resource "aws_route_table" "vpc-private-rt" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.base_name}-vpc-private-rt"
  }
}

# public route table association
resource "aws_route_table_association" "vpc-rta-1" {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.vpc-public-rt.id
}

# private route table association
resource "aws_route_table_association" "vpc-rta-2" {
  subnet_id      = aws_subnet.private-subnet-a.id
  route_table_id = aws_route_table.vpc-private-rt.id
}

resource "aws_route_table_association" "vpc-rta-3" {
  subnet_id      = aws_subnet.public-subnet-c.id
  route_table_id = aws_route_table.vpc-public-rt.id
}

resource "aws_route_table_association" "vpc-rta-4" {
  subnet_id      = aws_subnet.private-subnet-c.id
  route_table_id = aws_route_table.vpc-private-rt.id
}

# lb security group
resource "aws_security_group" "lb" {
  name   = "${var.base_name}-lb"
  vpc_id = aws_vpc.prod-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.base_name}-lb"
  }
}

# api security group
resource "aws_security_group" "api" {
  name   = "${var.base_name}-api"
  vpc_id = aws_vpc.prod-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.base_name}-api"
  }
}

# nat eip
resource "aws_eip" "nat" {
  vpc = true
}

# nat gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet-a.id
}
