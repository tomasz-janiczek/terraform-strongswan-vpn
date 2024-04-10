# EC2 configuration
variable "ami_name" {
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" #Ubuntu
  description = "The base AWS AMI image to use for the EC2 instance"
}

variable "ami_owner" {
  type        = string
  default     = "099720109477" # Canonical
  description = "The owner of the base AWS AMI image"
}

variable "instance_size" {
  type        = string
  default     = "t2.micro"
  description = "The instance type to be used (most of the time a t2.micro is enough)"
}

# Networking
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the instance will be located"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where the instance will be located"
}

# Security
variable "key_pair" {
  type        = string
  description = "The name of the key pair that will be used while provisioning the new EC2 instance (needed for Ansible provisioning)"
}

variable "private_key" {
  type        = string
  description = "The private key to use when connecting to the EC2 instance (see: key_pair)"
}

variable "username" {
  type        = string
  default     = "ubuntu"
  description = "The user to use when connecting to the EC2 instance (Ansible provisioning)"
}

variable "sg_id" {
  type        = string
  description = "The ID of the sg applied to the instance"
}

# VPN endpoint(s) configuration
variable "client_ip" {
  type        = string
  description = "The IP address of the client VPN endpoint"
}

variable "client_cidr" {
  type        = string
  description = "The CIDR on the client side"
}

# VPN security
variable "tunnel_psk" {
  type        = string
  description = "Tunnel pre-shared key"
}

# Other
variable "name" {
  type        = string
  default     = "strongSwan-based VPN instance"
  description = "The name for the new EC2 instance / VPN (can be anything)"
}
