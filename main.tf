provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "first_instance" {
  count         = var.instance_count
  ami           = "ami-0303e2e4a29f041a3"
  instance_type = var.aws_instance_type
  key_name      = "14_07_key"
  tags = {
    Name = "My Webserver"
  }
}

