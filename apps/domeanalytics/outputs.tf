output "ec2_private_address" {
  value       = aws_instance.default.private_ip
  description = "Private IP of the EC2 instance"
}

output "efs_mount_address" {
  value       = aws_efs_file_system.default.dns_name
  description = "EFS mount point DNS address"
}

output "eip_public_address" {
  value       = aws_eip.default.public_ip
  description = "Elastic IP address"
}
