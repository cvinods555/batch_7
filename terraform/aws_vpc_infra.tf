
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/24"
  tags = {
    Name = "TERRAFORM_VPC"
}
}

resource "aws_internet_gateway" "i-gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
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

data "aws_route_table" "default" {
  vpc_id = aws_vpc.main.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}

resource "aws_route" "default_route" {
  route_table_id         = data.aws_route_table.default.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.i-gw.id
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
    from_port        = 8080
    to_port          = 8080
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
  public_key = file("./my-ssh-key.pub")
}

#AWS instance
resource "aws_instance" "web" {
  ami = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.main.id
  security_groups = [aws_security_group.my-sg.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.deployer.key_name
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

output "ec2_info" {
  value = <<EOF
EC2 public IP: ${aws_instance.web.public_ip},
Key used: ${aws_instance.web.key_name}
EOF
}
