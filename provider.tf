terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
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
      terraform           = "true"
      environment         = "dev"
    }
  }    
}