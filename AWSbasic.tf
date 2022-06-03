provider "aws" {
    region = "us-east-1"
    access_key = ""
    secret_key = ""
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = ""
}

#tbd


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["1234"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"

  tags = {
    Name = "7dtdServer"
  }
}
}