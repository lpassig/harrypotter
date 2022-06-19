# Define policy ARNs as list
variable iam_policy_arn {
  description = "IAM Policy to be attached to role"
  type = list(string)
  default = [ "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3FullAccess"]
}

resource "aws_iam_instance_profile" "s3_ssm_profile" {
name = "ec2_profile"
role = aws_iam_role.s3_ssm_role.name
}

resource "aws_iam_role" "s3_ssm_role" {
name        = "ec2-s3-ssm-role"
description = "Connect to EC2 and let EC2 write to S3"
assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF

}

# Then parse through the list using count
resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  role       = aws_iam_role.s3_ssm_role.name
  count      = "${length(var.iam_policy_arn)}"
  policy_arn = "${var.iam_policy_arn[count.index]}"
}

# resource "aws_iam_role_policy_attachment" "ssm_policy" {
# role       = aws_iam_role.s3_ssm_role.name
# policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

#  resource "aws_iam_role_policy_attachment" "s3_policy" {
#  role       = aws_iam_role.s3_ssm_role.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# }