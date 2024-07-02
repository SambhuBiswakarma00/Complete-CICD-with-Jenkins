# Provider Section
provider "aws" {
    region = "us-east-1" 
}



# -----------------------------------This section is for network infra---------------------------------


# Creating vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
    tags = {
        Name = "my_vpc"
    }
}

# Creating public subnets
resource "aws_subnet" "my_public_subnet1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true     # Enable public IP association for instances in public subnet
  tags = {
        Name = "my_public_subnet_us_east_1a"
    }
}

resource "aws_subnet" "my_public_subnet2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true     # Enable public IP association for instances in public subnet
  tags = {
        Name = "my_public_subnet_us_east_1b"
    }
}

# Creating private subnets
resource "aws_subnet" "my_private_subnet1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false    # Disable public IP association for instances in private subnet
  tags = {
        Name = "my_private_subnet_us_east_1a"
    }
}


# Creating security group
resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "My security group"

  vpc_id = aws_vpc.my_vpc.id

  // Inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound SSH traffic"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound HTTP traffic"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound HTTPS traffic"
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound jenkins traffic"
  }
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound sonarqube traffic"
  }
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound nexus traffic"
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound prometheus traffic"
  }
  ingress {
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound loki traffic"
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound grafana traffic"
  }
  // Outbound rules
  egress {
    from_port   = 0  
    to_port     = 0  
    protocol    = "-1"  # All protocol

    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic to all destinations (Internet)
  }
  tags = {
        Name = "my_security_group"
    }
}

# Creating internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

# create nat gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.my_public_subnet1.id
}

# create elastic ip for nat gateway
resource "aws_eip" "my_eip" {
  domain   = "vpc"
}

# Creating route table
resource "aws_route_table" "my_route_table_public_subnet1" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyRouteTablePublicSubnet1"
  }
}

resource "aws_route_table" "my_route_table_public_subnet2" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyRouteTablePublicSubnet2"
  }
}

resource "aws_route_table" "my_route_table_private_subnet1" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyRouteTablePrivateSubnet1"
  }
}


# Creating route for igw
resource "aws_route" "route_for_public_subnet1" {
  route_table_id         = aws_route_table.my_route_table_public_subnet1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route" "route_for_public_subnet2" {
  route_table_id         = aws_route_table.my_route_table_public_subnet2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Creating route for nat gateway
resource "aws_route" "route_for_private_subnet1" {
  route_table_id         = aws_route_table.my_route_table_private_subnet1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
}


# Associating route table with publicsubnet 1
resource "aws_route_table_association" "route_table_associate_for_public_subnet1" {
  subnet_id      = aws_subnet.my_public_subnet1.id
  route_table_id = aws_route_table.my_route_table_public_subnet1.id
}
# Associating route table with publicsubnet 2
resource "aws_route_table_association" "route_table_associate_for_public_subnet2" {
  subnet_id      = aws_subnet.my_public_subnet2.id
  route_table_id = aws_route_table.my_route_table_public_subnet2.id
}

# Associating route table with privatesubnet 1
resource "aws_route_table_association" "route_table_associate_for_private_subnet1" {
  subnet_id      = aws_subnet.my_private_subnet1.id
  route_table_id = aws_route_table.my_route_table_private_subnet1.id
}





# -----------------------------------------This section is for EC2 instances-----------------------------------------------------------------------------------

# Instance for k8 cluster master node
resource "aws_instance" "kubeMaster" {
  ami = "ami-06aa3f7caf3a30282"
  count = 1
  instance_type = "t2.medium"
  subnet_id = aws_subnet.my_private_subnet1.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  key_name = "newkeypair"
  user_data = file("Installs/kube_and_java_install.sh")
  tags = {
     Name = "kube-master"
  }
  
}

# Instances for the k8 worker nodes
resource "aws_instance" "slave1" {
  ami = "ami-06aa3f7caf3a30282"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.my_private_subnet1.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  key_name = "newkeypair"
  user_data = file("Installs/kube_and_java_install.sh")
  tags = {
    Name = "kube-slave-1"
  }
  
}

resource "aws_instance" "slave2" {
  ami = "ami-06aa3f7caf3a30282"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.my_private_subnet1.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  key_name = "newkeypair"
  user_data = file("Installs/kube_and_java_install.sh")
  tags = {
    Name = "kube-slave-2"
  }
  
}


# Instance for the other tools required for the project like jenkins, sonarqube, trivy, prometheus, loki, grafana
resource "aws_instance" "tools" {
  ami = "ami-06aa3f7caf3a30282"
  instance_type = "t2.xlarge"
  subnet_id = aws_subnet.my_public_subnet1.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  key_name = "newkeypair"
  # user_data = file("Installs/tools_install.sh")
  tags = {
    Name = "tools"
  }
  user_data = <<-EOF
              #!/bin/bash
              echo "Setting up SSH authorized keys"
              echo "${file("/home/sambhu/.ssh/id_rsa.pub")}" >> /home/ubuntu/.ssh/authorized_keys
              chmod 600 /home/ubuntu/ansible_hosts
              chown ubuntu:ubuntu /home/ubuntu/ansible_hosts
              EOF
}


# ----------------------------------------This section is for the Ansible Dynamic host file creation----------------------------------------------------------

data "template_file" "ansible_hosts" {
  template = "${file("../Ansible/Hosts/ansible_hosts.tpl")}"
  
  vars = {
    public_ip = "${aws_instance.hello-virginia.public_ip}"
    private_ip = "${aws_instance.hello-virginia.private_ip}"
   # api_internal = "${aws_instance.dev-api-gateway-internal.private_ip}"
  }
}

resource "null_resource" "ansible_hosts" {
  triggers = {
    template_rendered = "${data.template_file.ansible_hosts.rendered}"
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.ansible_hosts.rendered}' > ../Ansible/Hosts/ansible_hosts"
  }
}

# -----------------------------------------This section is for ELB----------------------------------------------

# Create Elastic Load Balancer
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_security_group.id]
  subnets            = [aws_subnet.my_public_subnet1.id, aws_subnet.my_public_subnet2.id] #you need to provide atleast two public subnets for alb to get created.
}

# Create Target Groups
resource "aws_lb_target_group""webApp_tg" {
  name     = "slave-instances-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

# Create listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webApp_tg.arn
  }
}

# attach target group with actual target 1
resource "aws_lb_target_group_attachment" "slave1_tg_attachment" {
  target_group_arn = aws_lb_target_group.webApp_tg.arn
  target_id        = aws_instance.slave1.id
  port             = 80
}

# attach target group with actual target 2
resource "aws_lb_target_group_attachment" "slave2_tg_attachment" {
  target_group_arn = aws_lb_target_group.webApp_tg.arn
  target_id        = aws_instance.slave2.id
  port             = 80
}
