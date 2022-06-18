provider "hcp" {}

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

resource "aws_instance" "mongodb-ubuntu" {
  ami           = data.hcp-packer.image.mongodb-ubuntu.cloud_image_id
  instance_type = "t2.micro"
  
}
