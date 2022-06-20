# Get HCP generated AMI 
data "hcp_packer_iteration" "mongodb-ubuntu" {
  bucket_name = "mongodb-ubuntu-eu-west-1"
  channel     = "dev"
}

data "hcp_packer_image" "mongodb-ubuntu" {
  bucket_name    = data.hcp_packer_iteration.mongodb-ubuntu.bucket_name
  iteration_id   = data.hcp_packer_iteration.mongodb-ubuntu.ulid
  cloud_provider = "aws"
  region         = "${var.AWS_REGION}"
}

data "tfe_outputs" "outputs" {
  organization = "propassig"
  workspace = "hogwarts"
}

module "s3-bucket" {
  source  = "app.terraform.io/propassig/s3-bucket/aws"
  version = "3.3.0"
 

  bucket               = "${var.NAME}-mongodb-backup-s3"
  attach_public_policy = true
  acl                  = "public-read"

}

output "lol" {

  value = nonsensitive(data.tfe_outputs.outputs.values.availability_zone)
  
}

module "ec2-instance" {
  source  = "app.terraform.io/propassig/ec2-instance/aws"
  version = "4.0.0"

  name = "${var.NAME}-instance"
                              
  ami                         = data.hcp_packer_image.mongodb-ubuntu.cloud_image_id // packer image
  instance_type               = "t2.micro"
  availability_zone           = data.tfe_outputs.outputs.values.availability_zone
  monitoring                  = true
  vpc_security_group_ids      = data.tfe_outputs.outputs.values.vpc_security_group_ids
  subnet_id                   = data.tfe_outputs.outputs.values.subnet_id
  associate_public_ip_address = true
  iam_instance_profile        = data.tfe_outputs.outputs.values.instance_profile

  user_data = file("cloud-init/start-db.yaml")
}

#
##
### EKS
##
#
# data "aws_eks_cluster" "eks-cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "eks-cluster" {
#   name = module.eks.cluster_id
# }

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"

#   cluster_name    = "${var.NAME}-eks"
#   cluster_version = "1.18"
#   subnets         = module.vpc.private_subnets

#   vpc_id = module.vpc.vpc_id

#   node_groups = {
#     alpha = {
#       desired_capacity = 1
#       max_capacity     = 3
#       min_capacity     = 1
#       disk_size        = var.wn-disk-size
#       instance_types   = var.wn-instance-types[var.stage]
#       subnets          = [module.vpc.private_subnets[0]]
#     }

#     beta = {
#       desired_capacity = 1
#       max_capacity     = 3
#       min_capacity     = 1
#       disk_size        = var.wn-disk-size
#       instance_types   = var.wn-instance-types[var.stage]
#       subnets          = [module.vpc.private_subnets[1]]
#     }

#     gamma = {
#       desired_capacity = 1
#       max_capacity     = 3
#       min_capacity     = 1
#       disk_size        = var.wn-disk-size
#       instance_types   = var.wn-instance-types[var.stage]
#       subnets          = [module.vpc.private_subnets[2]]
#     }
#   }
#   workers_additional_policies = ["arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"]

#   write_kubeconfig   = true
#   config_output_path = "./"
# }