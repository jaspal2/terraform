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


module "terraform_SG_using_module" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "terraform_SG_using_module"
  description = "Security group using terraform module"
  vpc_id      = aws.aws_vpc.vpc_custom.id

  ingress_cidr_blocks      = ["10.10.0.0/16"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

resource "aws_vpc" "vpc_custom" {
  cidr_block  =     "10.0.0.0/24"
 
}


resource "aws_subnet" "subnet_custom1" {
  vpc_id  =   aws_vpc.vpc_custom.id
  cidr_block =    "10.0.0.0/25"
}

resource "aws_subnet" "subnet_custom2" {
  vpc_id  =   aws_vpc.vpc_custom.id
  cidr_block =    "10.0.0.128/25"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_custom.id

  tags = {
    Name = "GW from terraform"
  }
}

resource "aws_internet_gateway_attachment" "gw" {
  internet_gateway_id = aws_internet_gateway.gw.id
  vpc_id              = aws_vpc.vpc_custom.id
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.terraform_SG.id]
  subnet_id   =    aws_subnet.subnet_custom1.id
  
  tags = {
    Name = "Hello World"
  }
}

resource "aws_security_group" "terraform_SG"{
  name =   "terraform_SG"
  description   =   "SG for AWS instance"
  vpc_id  =  aws_vpc.vpc_custom.id
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


resource "aws_s3_bucket" "s3_bucket_terraform" {
  bucket = "jaspal-bucket-123"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

