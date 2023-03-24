provider "aws" {
  region = "us-west-2" # Replace with your desired AWS region
}

# Create a VPC
resource "aws_vpc" "Wordpress" {
  cidr_block = "10.0.0.0/16"
}

# Create a public subnet for the ELB
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.Wordpress.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Create a private subnet for the EC2 instances and RDS
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.Wordpress.id
  cidr_block = "10.0.2.0/24"
}

# Create a security group for the ELB
resource "aws_security_group" "elb" {
  name_prefix = "Wordpress-elb"
  vpc_id      = aws_vpc.Wordpress.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a security group for the EC2 instances
resource "aws_security_group" "ec2" {
  name_prefix = "Wordpress-ec2"
  vpc_id      = aws_vpc.Wordpress.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [aws_security_group.elb.id]
  }
}

# Create an RDS instance
resource "aws_db_instance" "Wordpress-db" {
  engine           = "mysql"
  instance_class   = "db.t2.micro"
  allocated_storage = 5
  storage_type     = "gp2"
  username         = "admin"
  password         = "password" # Change before Deployment
  db_name          = "Wordpress-db"
  multi_az         = false # Multi_az set to false for cost savings in testbed. Enable before production for high-availability
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_group_name = aws_db_subnet_group.Wordpress-db.name
}

# Create an RDS subnet group
resource "aws_db_subnet_group" "Wordpress-db" {
  name = "Wordpress-subnet-group"
  subnet_ids = [aws_subnet.private.id]
}

# Create an Elastic Beanstalk environment
resource "aws_elastic_beanstalk_environment" "Wordpress" {
  name                = "Wordpress"
  application         = "Wordpress"
  solution_stack_name = "64bit Amazon Linux 2 v5.4.0 running PHP 7.4"
  cname_prefix        =