provider "aws" {
  region = var.region
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}
variable "subnet_cidr_block" {
  default = "10.0.10.0/24"
}
variable "avail_zone" {
  default = "us-east-1a"
}
variable "env_prefix" {
  default = "dev"
}
variable "my_ip" {
  default = "99.145.91.76/32"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "region" {
  default = "us-east-1"
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-myapp-vpc"
  }
}

resource "aws_subnet" "myapp-subnet" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name : "${var.env_prefix}-myapp-subnet"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name : "${var.env_prefix}-myapp-igw"
  }
}

resource "aws_route_table" "myapp-rt" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name : "${var.env_prefix}-myapp-rt"
  }
}

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name : "${var.env_prefix}-default-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
}

resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.myapp-subnet.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true
  key_name                    = "myapp-key-pair" // key was created manually in ec2

  user_data = file("entry-script.sh")

  tags = {
    Name : "${var.env_prefix}-myapp-server"
  }
}