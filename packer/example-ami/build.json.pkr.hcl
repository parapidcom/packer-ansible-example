# See https://www.packer.io/docs/templates/hcl_templates/blocks/packer for more info
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

variable "region" {}
variable "instance_type" {}
variable "owners" {}
variable "stage" {}
variable "subnet_id" {}

# Read the documentation for the Amazon AMI Data Source here:
# https://www.packer.io/plugins/datasources/amazon/ami
data "amazon-ami" "autogenerated_1" {
  filters = {
    architecture                       = "x86_64"
    "block-device-mapping.volume-type" = "gp2"
    name                               = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    root-device-type                   = "ebs"
    virtualization-type                = "hvm"
  }
  most_recent = true
  owners      = ["${var.owners}"]
  region      = "${var.region}"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
# could not parse template for following block: "template: hcl2_upgrade:2: bad character U+0060 '`'"

source "amazon-ebs" "example_ami" {
  ami_description = "example ami for ${var.stage} built on Ubuntu 22.04."
  ami_name        = "example-ami-${var.stage}-ubuntu22-{{isotime \"02-Jan-06-03-04-05\"}}"
  instance_type   = var.instance_type
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 40
    volume_type           = "gp2"
  }
  region          = var.region
  run_tags = {
    stage = var.stage
  }
  source_ami   = data.amazon-ami.autogenerated_1.id
  ssh_username = "ubuntu"
   subnet_id    = var.subnet_id
  tags = {
    stage = var.stage
  }
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.amazon-ebs.example_ami"]

  provisioner "ansible" {
    ansible_env_vars = ["ANSIBLE_SSH_ARGS=-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o AddKeysToAgent=no -o IdentitiesOnly=yes -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa"]
    extra_arguments  = ["--scp-extra-args", "'-O'"]
    playbook_file    = "./packer.yml"
    user             = "ubuntu"
  }

  # This is how one can run shell command directly on the target machine
  # Check https://developer.hashicorp.com/packer/docs/provisioners/shell#script for more info
  # provisioner "shell" {
  #   inline = ["echo foo"]
  # }

}
