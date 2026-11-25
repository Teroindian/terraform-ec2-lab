output "instance_id" {
  value = aws_instance.lab.id
}

output "public_ip" {
  value = aws_instance.lab.public_ip
}

output "ssh_command" {
  description = "Paste into PowerShell to connect"
  value       = "ssh -i $HOME\\.ssh\\tf-lab ec2-user@${aws_instance.lab.public_ip}"
}