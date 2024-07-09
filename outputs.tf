output "instance_ami" {
  value = aws_instance.public_instance.ami
}

output "instance_arn" {
  value = aws_instance.private_instance.arn
}
