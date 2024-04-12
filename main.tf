# We are using a simple Ubuntu-based box
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_owner]
}

# The selected VPC
data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_key_pair" "vpn" {
  key_name = var.key_pair
}

# The VPN EC2 instance itself

resource "aws_instance" "vpn_server" {
  # These should not be needed to be changed, nevertheless it's possible
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_size

  # FIXME: a public IP is fine for testing, but an ElasticIP is needed for production use!
  # We don't want the tunnel endpoint IP address to change (ever)
  associate_public_ip_address = true

  # See the variables descriptions for more info/details
  key_name = var.key_pair

  # Where to set up the instance?
  subnet_id = var.subnet_id

  # This needs to be off or the instance won't work as a router
  source_dest_check = false

  vpc_security_group_ids = [var.sg_id]

  tags = {
    Name = var.name
  }
}

# This is being used to install and configure strongSwan / IPSec properly
#
# !!! NOTE !!!
# As we are using an EC2 instance which has both a public and a private IP address, we need to force strongSwan to use 
# the PUBLIC IP ADDRESS (not the private IP!) as the IPSec IKEv1 ID, as some proprietary solutions will expect it to be
# this way and won't establish a connection otherwise.
#
# *** By default strongSwan would use the private IP address as this ID ***
#
# More can be found in the details of the IPSec protocol (and IKEv1 in particular)
#
# Links
# https://wiki.strongswan.org/projects/strongswan/wiki/connsection
# https://www.cisco.com/c/en/us/support/docs/ip/internet-key-exchange-ike/117258-config-l2l.html
#

locals {
  host_ip = var.ssh_public == true ? aws_instance.vpn_server.public_ip : aws_instance.vpn_server.private_ip
}
module "ansible_provisioner" {
  source = "github.com/cloudposse/tf_ansible"

  arguments = ["--ssh-common-args='-o StrictHostKeyChecking=no' --user=${var.username} --private-key ${var.private_key}"]
  envs = [
    "host=${local.host_ip}",
    "module_path=${path.module}",
    "client_ip=${var.client_ip}",
    "client_cidr=${var.client_cidr}",
    "local_cidr=${data.aws_vpc.selected.cidr_block}",
    "local_private_ip=${aws_instance.vpn_server.private_ip}",
    "local_public_ip=${aws_instance.vpn_server.public_ip}", # <--- This will be the IKE ID, see ipsec.conf for more info
    "tunnel_psk=${var.tunnel_psk}"
  ]

  playbook = "${path.module}/ansible/strongswan-install.yml"
  dry_run  = false
}

