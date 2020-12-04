# Provider
 provider "aws" {
   access_key = "AWS_ACCESS_KEY_ID"
   secret_key = "AWS_SECRET_ACCESS_KEY"
   region = "us-east-1"
 }

resource "aws_iam_role" "ssh_access_role" {
  name = "ssh_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ssh_access" {
  name = "ssh_access"
  role = aws_iam_role.ssh_access_role.name
}

resource "aws_iam_policy" "ssh_access_policy" {
  name        = "ssh_access_policy"
  path        = "/"
  description = "SSH access policy for AWS EC2 Instance Connect"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2-instance-connect:SendSSHPublicKey"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssh_access" {
  role       = aws_iam_role.ssh_access_role.name
  policy_arn = aws_iam_policy.ssh_access_policy.arn
}

resource "aws_instance" "host1_AMI_Linux" {
  ami             = "${lookup(var.AmiLinux, var.region)}"
  instance_type   = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.ssh_access.name}"
  tags = {
    Name = "Host1_AMI_Linux"
  }
}

resource "aws_instance" "host2_Ubuntu" {
  ami             = "${lookup(var.Ubuntu, var.region)}"
  instance_type   = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.ssh_access.name}"
  tags = {
    Name = "Host2_Ubuntu"
  }
}
