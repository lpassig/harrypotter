packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "mongodb-ubuntu" {
  ami_name = "packer_AWS_{{timestamp}}"

  region         = "eu-west-1"
  source_ami     = "ami-63b0341a" // 16.04 Release 20171208
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false

}

build {
  hcp_packer_registry {
    bucket_name = "mongodb-ubuntu-eu-west-1"
    channel     = "dev"
    description = <<EOT
Some nice description about the image being published to HCP Packer Registry.
    EOT
    bucket_labels = {
      "version" = "0.0.1"
    }
  }
  provisioner "shell" {
    scripts = ["./scripts/install_aws_ssm.sh"]
  }
  provisioner "file" {
    destination = "/tmp/"
    source      = "./scripts"
  }
  sources = [
    "source.amazon-ebs.mongodb-ubuntu"
  ]
}
