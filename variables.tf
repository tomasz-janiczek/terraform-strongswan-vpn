# EC2 configuration
variable "ami_name" {
  type = string
  default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" #Ubuntu
}

variable "ami_owner" {
  type = string
  default = "099720109477" # Canonical
}

variable "instance_size" {
  type = string
  default = "t2.micro"
}

# Networking
variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

# Security
variable "key_pair" {
  type = string
}

variable "private_key" {
  type = string
}

variable "username" {
  type = string
  default = "ubuntu"
}

# VPN endpoint(s) configuration
variable "client_ip" {
  type = string
}

variable "client_cidr" {
  type = string
}

# VPN security
variable "tunnel_psk" {
  type = string
}

# Other
variable "name" {
  type = string
  default = "strongSwan-based VPN instance"
}
