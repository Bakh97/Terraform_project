provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "T_vpc"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "T_sub1"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "T_sub2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "T_igw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "T_rt"
  }
}
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  name        = "T_sg"
  vpc_id      = aws_vpc.my_vpc.id
  description = "security group"

  ingress {
    description = "http from vpc"
    protocol    = "tcp"
    to_port     = 80
    from_port   = 80
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "ssh from vpc"
    protocol    = "tcp"
    to_port     = 22
    from_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "T_sg"
  }
}

# resource "aws_s3_bucket" "T_bucket" {
#   bucket = "deep09bucket"

# }

resource "aws_instance" "ec2_1" {
  ami                    = "ami-064519b8c76274859"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data              = base64encode(file("userdata.sh"))
}


resource "aws_instance" "ec2_2" {
  ami                    = "ami-064519b8c76274859"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = base64encode(file("userdata1.sh"))
}

