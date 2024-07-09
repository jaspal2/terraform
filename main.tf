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
  public_subnets  = ["10.0.0.48/28", "10.0.0.64.28", "10.0.0.80/28"]

  
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


module "terraform_sg_custom" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "terraform_sg_custom"
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
  ],

  {
      from_port   = 443
      to_port     = 65535
      protocol    = "tcp"
      description = "specific port"
      cidr_blocks = "10.0.0.0/16"
    }

}



resource "aws_instance" "custom_instance" {

  resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [module.terraform_sg_custom]
  subnet_id   =    module.vpc_custom.public_subnets[0]
  
  tags = {
    Name = "Hello World"
  }
}

}