output "public_ips" {
  value = aws_instance.first_instance.*.public_ip
}

output "private_ips" {
  value = aws_instance.first_instance.*.private_ip
}