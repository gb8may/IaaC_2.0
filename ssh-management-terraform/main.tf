#####################
# AWS WITH TERRAFORM
####################

# Provider
 provider "aws" {
   access_key = "AKIAJMAQJGXCGKEXYX2Q"
   secret_key = "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"
   region = "us-east-1"
 }

# ROLE

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

# PROFILE

resource "aws_iam_instance_profile" "ssh_access_profile" {
  name = "ssh_access_profile"
  role = aws_iam_role.ssh_access_role.name
}

# POLICY

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

# POLICY ATTACHMENT

resource "aws_iam_role_policy_attachment" "ssh_access_profile" {
  role       = aws_iam_role.ssh_access_role.name
  policy_arn = aws_iam_policy.ssh_access_policy.arn
}

# USER

resource "aws_iam_user" "gb8may" {
  name = "gb8may"
}

# POLICY ATACHMENT

resource "aws_iam_user_policy_attachment" "ssh-access-user-attachment" {
  user       = aws_iam_user.gb8may.name
  policy_arn = aws_iam_policy.ssh_access_policy.arn
}

# NETWORK INTERFACE

resource "aws_network_interface" "master_network_interface" {
  subnet_id       = "subnet-5102ff70"
  private_ips = ["${var.puppet_master_ip}"]
  security_groups = ["sg-09aaa34add79f3a93"]
}

resource "aws_network_interface" "agent_network_interface" {
  subnet_id       = "subnet-5102ff70"
  private_ips = ["${var.puppet_agent_ip}"]
  security_groups = ["sg-09aaa34add79f3a93"]
}

# INSTANCE = PUPPET MASTER

resource "aws_instance" "puppetmaster" {
  ami             = "${lookup(var.Ubuntu18, var.region)}"
  instance_type   = "t2.small"
  key_name        = "New_Pair_Mac"
  network_interface {
  network_interface_id = "${aws_network_interface.master_network_interface.id}"
  device_index = 0
  }
  iam_instance_profile = "${aws_iam_instance_profile.ssh_access_profile.name}"
  tags = {
    Name = "Puppet_Master"
  }
}
resource "null_resource" "set_master_hostname" {
  connection {
  type = "ssh"
  user = "ubuntu"
  host = "${var.puppet_master_ip}"
  private_key = "${file("New_Pair_Mac.pem")}"
 }
  provisioner "file" {
    source      = "puppet_master_install.sh"
    destination = "/tmp/puppet_master_install.sh"
  }
  provisioner "file" {
    source      = "puppetserver"
    destination = "/tmp/puppetserver"
  }
  provisioner "remote-exec" {
    inline = [
      "echo '127.0.0.1 ${var.puppet_master}' | sudo tee -a /etc/hosts",
      "echo '${var.puppet_master_ip} puppetmaster' | sudo tee -a /etc/hosts",
      "echo '${var.puppet_master_ip} puppet' | sudo tee -a /etc/hosts",
      "echo '${var.puppet_master_ip} puppetmaster.ec2instance.com' | sudo tee -a /etc/hosts",
      "echo '${var.puppet_master_ip} puppet.ec2instance.com' | sudo tee -a /etc/hosts",
      "echo '${var.puppet_agent_ip} puppetclient' | sudo tee -a /etc/hosts",
      "sudo hostnamectl set-hostname ${var.puppet_master}",
      "cd /tmp && bash puppet_master_install.sh",
    ]
   }
}

# INSTANCE = PUPPET AGENT

resource "aws_instance" "puppetagent" {
  ami             = "${lookup(var.Ubuntu18, var.region)}"
  instance_type   = "t2.micro"
  key_name        = "New_Pair_Mac"
  network_interface {
  network_interface_id = "${aws_network_interface.agent_network_interface.id}"
  device_index = 0
  }
  iam_instance_profile = "${aws_iam_instance_profile.ssh_access_profile.name}"
  tags = {
    Name = "Puppet_Agent"
  }
}
resource "null_resource" "set_agent_hostname" {
  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.puppet_agent_ip}"
    private_key = "${file("New_Pair_Mac.pem")}"
  }
  provisioner "file" {
    source      = "puppetagent.conf"
    destination = "/tmp/puppetagent.conf"
  }
  provisioner "file" {
    source      = "puppet_agent_install.sh"
    destination = "/tmp/puppet_agent_install.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "echo '127.0.0.1 ${var.puppet_agent}' | sudo tee -a /etc/hosts",
      "echo '${var.puppet_master_ip} puppetmaster' | sudo tee -a /etc/hosts",
      "echo '${var.puppet_master_ip} puppet' | sudo tee -a /etc/hosts",
      "echo '${var.puppet_master_ip} puppetmaster.ec2instance.com' | sudo tee -a /etc/hosts",
      "echo '${var.puppet_agent_ip} puppet.ec2instance.com' | sudo tee -a /etc/hosts",
      "sudo hostnamectl set-hostname ${var.puppet_agent}",
      "cd /tmp && bash puppet_agent_install.sh",
    ]
  }
}

