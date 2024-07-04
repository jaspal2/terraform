data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}


 data "aws_vpc" "default" {
    default = true
  }




resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.terraform_SG.id]

  

  tags = {
    Name = "Hello World"
  }
}



resource "aws_security_group" "terraform_SG"{
  name =   "terraform_SG"
  vpc_id  =  data.aws_vpc.default.id
}

resource "aws_security_group_rule" "terraform_SG_ingress_https" {
  type              = "ingress"
  description       = "Security group for Ingress request"
  from_port         = 0
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraform_SG.id
}


resource "aws_security_group_rule" "terraform_SG_egress_https" {
  type              = "egress"
  description       = "Security group for egress request"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraform_SG.id
}

