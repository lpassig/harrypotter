terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.23.1"
    }
  }
}

provider "hcp" {}

provider "aws" {
  region = "${var.AWS_REGION}"
  default_tags {
    tags = {
      owner               = "${var.NAME}"
      project             = "project-harry"
      packer              = "true"
      environment         = "dev"
    }
  }    
}