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


module "vpc_custom" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/24"

  azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  private_subnets = ["10.0.0.0/28", "10.0.0.16/28", "10.0.0.32/28"]
  public_subnets  = ["10.0.0.48/28", "10.0.0.64/28", "10.0.0.80/28"]
  
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false  


  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


module "public_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "public_sg"
  description = "Security group for Https and https"
  vpc_id      = module.vpc_custom.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["https-443-tcp", "http-80-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}


module "private_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "private_sg"
  description = "Security group for Https and https"
  vpc_id      = module.vpc_custom.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["https-443-tcp", "http-80-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "User-service ports"
      security_groups = "module.public_sg.security_group_id"
    },

    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "public_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [module.public_sg.security_group_id]

  subnet_id     =  module.vpc_custom.public_subnets[0]

  associate_public_ip_address   =   true

  key_name = "aws"

  tags = {
    Name = "Public instance"
  }
}


resource "aws_instance" "private_instance" {
  ami           = data.aws_ami.app_ami.id

  instance_type = "t3.micro"

  vpc_security_group_ids = [module.private_sg.security_group_id]

  key_name = "aws"

  subnet_id     =  module.vpc_custom.private_subnets[0]


  tags = {

    Name = "Private instance"

  }
}



