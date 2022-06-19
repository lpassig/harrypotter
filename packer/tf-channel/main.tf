data "hcp_packer_iteration" "mongodb-ubuntu" {
  bucket_name = "mongodb-ubuntu-eu-west-1"
  channel     = "dev"
}

data "hcp_packer_image" "mongodb-ubuntu" {
  bucket_name    = data.hcp_packer_iteration.mongodb-ubuntu.bucket_name
  iteration_id   = data.hcp_packer_iteration.mongodb-ubuntu.id
  cloud_provider = "aws"
  region         = "${var.AWS_REGION}"
}

resource "aws_instance" "mongodb-ubuntu" {
  ami           = data.hcp_packer_image.mongodb-ubuntu.cloud_image_id
  instance_type = "t2.micro"
  
}
