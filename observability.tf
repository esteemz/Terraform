terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = "us-west-2"
  access_key = "REDACTED"
  secret_key = "REDACTED"
}

resource "aws_vpc" "observability_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "observability-vpc"
  }
}

resource "aws_subnet" "observability_subnet" {
  vpc_id                  = aws_vpc.observability_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2"
  map_public_ip_on_launch = true
  tags = {
    Name = "observability-subnet"
  }
}

resource "aws_security_group" "elastic" {
  name        = "elastic"
  description = "Elasticsearch security group"
  vpc_id      = aws_vpc.observability_vpc.id
}

resource "aws_security_group" "kibana" {
  name        = "kibana"
  description = "Kibana security group"
  vpc_id      = aws_vpc.observability_vpc.id
}

resource "aws_security_group" "prometheus" {
  name        = "prometheus"
  description = "Prometheus security group"
  vpc_id      = aws_vpc.observability_vpc.id
}

resource "aws_security_group" "grafana" {
  name        = "grafana"
  description = "Grafana security group"
  vpc_id      = aws_vpc.observability_vpc.id
}

resource "aws_elasticsearch_domain" "example" {
  domain_name           = "example"
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type = "t2.small.elasticsearch"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  vpc_options {
    subnet_ids = [aws_subnet.observability_subnet.id]
  }

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "es:*"
        Effect = "Allow"
        Principal = "*"
        Resource = "arn:aws:es:${data.aws_caller_identity.current.account_id}:domain/example/*"
      }
    ]
  })

  tags = {
    Domain = "Elasticsearch"
  }
}

module "kibana" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name                 = "kibana"
  ami                  = "ami-07cd5ed44d1274962"
  instance_type        = "t2.micro"
  key_name             = "your_key_pair_name"
  monitoring           = true
  vpc_security_group_ids = [aws_security_group.kibana.id]
  subnet_id            = aws_subnet.observability_subnet.id
}

module "prometheus" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name                 = "prometheus"
  ami                  = "ami-0e6a2f943ebecf88b"
  instance_type        = "t2.micro"
  key_name             = "your_key_pair_name"
  monitoring           = true
  vpc_security_group_ids = [aws_security_group.prometheus.id]
  subnet_id            = aws_subnet.observability_subnet.id
}