
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

resource "aws_iam_role_policy_attachment" "ssm_policy" {
role       = aws_iam_role.s3_ssm_role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# resource "aws_iam_role_policy_attachment" "s3_policy" {
# role       = aws_iam_role.s3_ssm_role.name
# policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# }