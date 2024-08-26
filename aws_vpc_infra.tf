
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/24"
  tags = {
    Name = "TERRAFORM_VPC"
}
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.0.0/26"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Terraform_subnet_1_64_59"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.0.64/27"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Terraform_subnet_2_32_27"
  }
}

resource "aws_security_group" "my-sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_tls" 
}

#ingress for ssh
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}
#ingress for http
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}
#ingress for https
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}

#outbound rules for all trffic 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "terragen-key"
  public_key = file("~/.ssh/myssh-key.pub")
}

#AWS instance
resource "aws_instance" "web" {
  ami = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.main.id
  security_groups = [aws_security_group.my-sg.id]
  associate_public_ip_address = true
  user_data = file("./userdata.bash")
  tags = {
    Name = "Terra-ec2"
  }
}


output "instance_details"{
  value = {
    ec2_public_ip = aws_instance.web.public_ip
    ec2_private_ip = aws_instance.web.private_ip
}
}

