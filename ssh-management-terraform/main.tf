# Provider
 provider "aws" {
   access_key = ""
   secret_key = ""
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

resource "aws_iam_instance_profile" "ssh_access_profile" {
  name = "ssh_access_profile"
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

resource "aws_iam_role_policy_attachment" "ssh_access_profile" {
  role       = aws_iam_role.ssh_access_role.name
  policy_arn = aws_iam_policy.ssh_access_policy.arn
}

resource "aws_iam_user" "gb8may" {
  name = "gb8may"
}

resource "aws_iam_user_policy_attachment" "ssh-access-user-attachment" {
  user       = aws_iam_user.gb8may.name
  policy_arn = aws_iam_policy.ssh_access_policy.arn
}

resource "aws_instance" "host1_AMI_Linux" {
  ami             = "${lookup(var.AmiLinux, var.region)}"
  instance_type   = "t2.micro"
  key_name        = "New_Pair_Mac"
  iam_instance_profile = "${aws_iam_instance_profile.ssh_access_profile.name}"
  tags = {
    Name = "Host1_AMI_Linux"
  }
}

resource "aws_instance" "host2_Ubuntu" {
  ami             = "${lookup(var.Ubuntu, var.region)}"
  instance_type   = "t2.micro"
  key_name        = "New_Pair_Mac"
  iam_instance_profile = "${aws_iam_instance_profile.ssh_access_profile.name}"
  tags = {
    Name = "Host2_Ubuntu"
  }
}
