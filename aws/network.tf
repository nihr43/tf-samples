resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "subnet-1a"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "subnet-1b"
  }
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "example-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "sub_1_route" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "sub_2_route" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "example" {
  vpc_id = aws_vpc.main.id

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
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-sg"
  }
}
