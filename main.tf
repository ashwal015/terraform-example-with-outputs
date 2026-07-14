provider "aws" {
  region = "eu-central-1"
}
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow SSH and HTTP"

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
}

resource "aws_instance" "first_instance" {
  count         = var.instance_count
  ami           = "ami-0303e2e4a29f041a3"
  instance_type = var.aws_instance_type
  key_name      = "14_07_key"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = {
    Name = "My Webserver"
  }
}

