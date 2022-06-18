module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.NAME}-vpc"
  cidr = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  azs             = ["${var.AWS_REGION}a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

}

module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.NAME}-sg"
  description = "Security group for EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]

}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket               = "${var.NAME}-mongodb-backup-s3"
  attach_public_policy = true
  acl                  = "public-read"

}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.NAME}-instance"

  ami                         = "ami-0b2734aa66fc72ed2" // packer image
  instance_type               = "t2.micro"
  availability_zone           = element(module.vpc.azs, 0)
  monitoring                  = true
  vpc_security_group_ids      = [module.security_group.security_group_id]
  subnet_id                   = element(module.vpc.public_subnets, 0)
  associate_public_ip_address = true


  user_data = file("cloud-init/start-db.yaml")
}

resource "aws_iam_role" "SSM_role" {
  name = "SSM_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
    "Effect": "Allow",
    "Principal": {"Service": "ssm.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.SSM_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_ssm_activation" "foo" {
  name               = "ssm_activation"
  description        = "SSM_role to activate"
  iam_role           = aws_iam_role.SSM_role.id
  registration_limit = "5"
  depends_on         = [aws_iam_role_policy_attachment.attach]
}

output "public_ip" {
  value = module.ec2_instance.public_ip
}

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 18.0"

#   cluster_name    = "${var.NAME}-cluster"
#   cluster_version = "1.21"

#   cluster_endpoint_private_access = true
#   cluster_endpoint_public_access  = true

#   cluster_addons = {
#     coredns = {
#       resolve_conflicts = "OVERWRITE"
#     }
#     kube-proxy = {}
#     vpc-cni = {
#       resolve_conflicts = "OVERWRITE"
#     }
#   }

#   cluster_encryption_config = [{
#     provider_key_arn = "ac01234b-00d9-40f6-ac95-e42345f78b00"
#     resources        = ["secrets"]
#   }]

#   vpc_id     = "vpc-1234556abcdef"
#   subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

#   # Self Managed Node Group(s)
#   self_managed_node_group_defaults = {
#     instance_type                          = "m6i.large"
#     update_launch_template_default_version = true
#     iam_role_additional_policies = [
#       "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#     ]
#   }

#   self_managed_node_groups = {
#     one = {
#       name         = "mixed-1"
#       max_size     = 5
#       desired_size = 2

#       use_mixed_instances_policy = true
#       mixed_instances_policy = {
#         instances_distribution = {
#           on_demand_base_capacity                  = 0
#           on_demand_percentage_above_base_capacity = 10
#           spot_allocation_strategy                 = "capacity-optimized"
#         }

#         override = [
#           {
#             instance_type     = "m5.large"
#             weighted_capacity = "1"
#           },
#           {
#             instance_type     = "m6i.large"
#             weighted_capacity = "2"
#           },
#         ]
#       }
#     }
#   }

#   # EKS Managed Node Group(s)
#   eks_managed_node_group_defaults = {
#     disk_size      = 50
#     instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
#   }

#   eks_managed_node_groups = {
#     blue = {}
#     green = {
#       min_size     = 1
#       max_size     = 10
#       desired_size = 1

#       instance_types = ["t3.large"]
#       capacity_type  = "SPOT"
#     }
#   }

#   # Fargate Profile(s)
#   fargate_profiles = {
#     default = {
#       name = "default"
#       selectors = [
#         {
#           namespace = "default"
#         }
#       ]
#     }
#   }

#   # aws-auth configmap
#   manage_aws_auth_configmap = true

#   aws_auth_roles = [
#     {
#       rolearn  = "arn:aws:iam::66666666666:role/role1"
#       username = "role1"
#       groups   = ["system:masters"]
#     },
#   ]

#   aws_auth_users = [
#     {
#       userarn  = "arn:aws:iam::66666666666:user/user1"
#       username = "user1"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws:iam::66666666666:user/user2"
#       username = "user2"
#       groups   = ["system:masters"]
#     },
#   ]

#   aws_auth_accounts = [
#     "777777777777",
#     "888888888888",
#   ]
# }
