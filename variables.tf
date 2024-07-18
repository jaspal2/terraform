variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}


variable "ami_name" {
    description      =      "AMI name for an instance"
    default       =      "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
}



