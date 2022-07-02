terraform {
  cloud {
    organization = "propassig"
    workspaces {
      name = "Project_Draco_Azure_LandingZone"
    }
  }
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
      project             = "project-${var.NAME}"
      terraform           = "true"
      environment         = "dev"
    }
  }    
}