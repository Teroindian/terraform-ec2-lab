variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "AZ for the VM (us-east-1a supports t3.micro)"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "my_ip_cidr" {
  description = "Your public IP as x.x.x.x/32. Only this IP may SSH in."
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0)) && endswith(var.my_ip_cidr, "/32")
    error_message = "my_ip_cidr must be one IP ending in /32, for example 203.0.113.10/32."
  }
}

variable "public_key_path" {
  description = "Path to your SSH public key (.pub)"
  type        = string
}