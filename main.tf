# Look up existing things (data sources read, they never create)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default_az" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.availability_zone
  default_for_az    = true
}

# Latest Amazon Linux 2023 image ID, published by AWS in Parameter Store
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Upload your PUBLIC key so AWS can put it on the VM
resource "aws_key_pair" "lab" {
  key_name   = "tf-lab-key"
  public_key = file(pathexpand(var.public_key_path))
}

# Security group with one way in: SSH from your IP
resource "aws_security_group" "ssh" {
  name        = "tf-lab-ssh"
  description = "SSH from my IP only"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "tf-lab-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_from_me" {
  security_group_id = aws_security_group.ssh.id
  description       = "SSH from my IP"
  cidr_ipv4         = var.my_ip_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

# Terraform removes AWS's default allow-all outbound rule, so add it back explicitly
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.ssh.id
  description       = "All outbound (updates, package installs)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "lab" {
  ami                         = data.aws_ssm_parameter.al2023.insecure_value
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.default_az.id
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  key_name                    = aws_key_pair.lab.key_name
  associate_public_ip_address = true

  metadata_options {
    http_tokens = "required" # IMDSv2 only (security best practice)
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "tf-lab-vm"
  }

  # A newer AMI next month should not silently replace this VM
  lifecycle {
    ignore_changes = [ami]
  }
}