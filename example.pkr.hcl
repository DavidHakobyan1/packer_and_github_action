packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "amazon-ami" "example" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
    root-device-type    = "ebs"
  }
  owners      = ["099720109477"]
  most_recent = true
  region      = "us-east-1"
}

source "amazon-ebs" "ssm-example" {
  ami_name             = "packer_AWS {{timestamp}}"
  instance_type        = "t2.micro"
  region               = "us-east-1"
  source_ami           = data.amazon-ami.example.id
  ssh_username         = "ubuntu"
  ssh_interface        = "session_manager"
  communicator         = "ssh"
  iam_instance_profile = "SSMInstanceProfile"
}

build {
  sources = ["source.amazon-ebs.ssm-example"]

  provisioner "shell" {
    inline = ["echo Connected via SSM at '${build.User}@${build.Host}:${build.Port}'"]
  }
}
