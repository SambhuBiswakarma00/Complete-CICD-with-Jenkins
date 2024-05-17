#For N.Virginia(us-east-1) Region
provider "aws" {
    region = "us-east-1" 
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
    tags = {
        Name = "my_vpc"
    }
}
resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
        Name = "my_subnet"
    }
}
resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "My security group"

  vpc_id = aws_vpc.my_vpc.id

  // Inbound rule allowing SSH access from a specific IP
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
    cidr_blocks = ["0.0.0.0/0"]  # Replace with the desired source IP range (allowing from anywhere for demonstration)
    description = "Allow inbound HTTP traffic"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound HTTPS traffic"
  }
  egress {
    from_port   = 0  # Port range start (0 indicates all ports)
    to_port     = 0  # Port range end (0 indicates all ports)
    protocol    = "-1"  # All protocols

    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic to all destinations (Internet)
  }
  tags = {
        Name = "my_security_group"
    }
}
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyRouteTable"
  }
}
resource "aws_route" "route_to_igw" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}
resource "aws_route_table_association" "my_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}
resource "aws_instance" "kube-master" {
  ami = "ami-06aa3f7caf3a30282"
  count = 1
  instance_type = "t2.medium"
  subnet_id = aws_subnet.my_subnet.id
  key_name = "newkeypair"
  tags = {
     Name = "kube-master"
  }
}
resource "aws_instance" "slave-1" {
  ami = "ami-06aa3f7caf3a30282"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.my_subnet.id
  key_name = "newkeypair"
  tags = {
    Name = "kube-slave-1"
  }
}
resource "aws_instance" "slave-2" {
  ami = "ami-06aa3f7caf3a30282"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.my_subnet.id
  key_name = "newkeypair"
  tags = {
    Name = "kube-slave-2"
  }
}