provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "erste_instanz" {
  count         = var.instance_count
  ami           = "ami-0303e2e4a29f041a3"
  instance_type = var.aws_instance_type
  key_name      = "25-09-key"
  tags = {
    Name = "Mein Webserver"
  }
}

