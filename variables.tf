variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}


variable "ami_name" {
    description      =      "AMI name for an instance"
    default       =      "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
}

variable "environment" {
    description    =        "Development Environment"
    type           =        object({
        name       =        string
        cidr_blocks        =       string    
        network_prefix =    string
    })

     default ={
        name    =       "vpc_from_variable"
        cidr_blocks = "10.0.0.0/24"
        network_prefix  =    "10.0"        
}



