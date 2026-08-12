terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
provider "aws" {
  region = "eu-north-1"
}
data "http" "my_ip" {
url = "https://checkip.amazonaws.com"
}
resource "aws_iam_role" "shrik_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        }
      ]
    }
  )
}
resource "aws_iam_policy" "shrik_policy" {
  name = "my_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject","s3:ListBucket"]
         Resource = ["arn:aws:s3:::placeholder-bucket-name/*"]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach" {
  role = aws_iam_role.shrik_role.name
  policy_arn = aws_iam_policy.shrik_policy.arn
}
resource "aws_iam_instance_profile" "shrik_profile" {
  name = "myinstanceprofile"
  role = aws_iam_role.shrik_role.name
}

resource "aws_security_group" "shrik_sg" {
  description = "rules for allow ec2"
  name = "shrik_sg"
  
  ingress {
    description = "http"
    from_port=80
    to_port=80
     protocol="tcp"
    cidr_blocks=["${chomp(data.http.my_ip.response_body)}/32"]
   }
  ingress {
    description = "https"
     from_port = 443
     to_port = 443
     protocol = "tcp"
     cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }
   ingress {
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
   }
   egress {
    description = "only https allow"
   from_port = 0
   to_port =  0
   protocol = "-1"
   cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
   }
  } 



resource "aws_instance" "shrikant_server" {
ami           = "ami-05d62b9bc5a6ca605"
  instance_type = "t3.micro"
  key_name = "aws-ssh-key"
  tags = {
    Name = "shrik-server-1"
  }
  vpc_security_group_ids = [aws_security_group.shrik_sg.id]
monitoring = true
metadata_options {
  http_endpoint = "enabled"
  http_tokens = "required"
}
 root_block_device {
   volume_size = 20
   encrypted =  true
 }
ebs_optimized = true

iam_instance_profile = aws_iam_instance_profile.shrik_profile.name
}
