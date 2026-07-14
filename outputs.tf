output "public_ips" {
  value = aws_instance.erste_instanz.*.public_ip
}
output "private_ips" {
  value = aws_instance.erste_instanz.*.private_ip
}