packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "hcp-packer-iteration" "mongodb-ubuntu" {
  bucket_name = "mongodb-ubuntu"
  channel     = "dev"
}

data "hcp-packer-image" "mongodb-ubuntu" {
  bucket_name    = "mongodb-ubuntu-${var.AWS_REGION}"
  iteration_id   = data.hcp-packer-iteration.mongodb-ubuntu.id
  cloud_provider = "aws"
  region         = "${var.AWS_REGION}"
}

source "amazon-ebs" "mongodb-ubuntu" {
  ami_name = "packer_AWS_{{timestamp}}"

  region         = "${var.AWS_REGION}"
  source_ami     = "ami-0f29c8402f8cce65c"
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false

}

build {
  hcp_packer_registry {
    bucket_name = "mongodb-ubuntu-${var.AWS_REGION}"
    description = <<EOT
Some nice description about the image being published to HCP Packer Registry.
    EOT
    bucket_labels = {
      "version" = "0.0.1"
    }
  }
  provisioner "shell" {
     scripts=[
       "../scripts/install_aws_ssm.sh"]
  }
  provisioner "file" {
    destination = "/tmp/"
    source      = "../scripts"
  }
  sources = [
    "source.amazon-ebs.mongodb-ubuntu"
  ]
}
