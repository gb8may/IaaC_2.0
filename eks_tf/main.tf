provider "aws" {
  version = "~> 2.0"
  region = var.region
  assume_role {
    role_arn = "${var.provider_env_roles[terraform.workspace]}"
  }
}

resource "aws_iam_policy" "assume-role-terraform-eks" {
  name        = "Assume-Role-terraform-eks"
  description = "Allow assuming Terraform EKS role on prod account"
  policy      = <<EOP
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::582282573443:role/terraform-eks"
    }
  ]
}
EOP
}

# Attach the policy to the group your user is in
resource "aws_iam_group_policy_attachment" "assume-role-terraform-eks" {
  group      = "${aws_iam_group.groups["terraform-eks"].name}"
  policy_arn = "${aws_iam_policy.assume-role-terraform-eks.arn}"
}

terraform {
  backend "s3" {
    bucket = "terraform-rep0"
    key    = "tfstate_files/eks.tfstate"
    region = "us-east-1"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

data "aws_availability_zones" "azs" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.47.0"

  name                 = "sabha-load-test-vpc"
  cidr                 = "172.16.0.0/16"
  azs                  = data.aws_availability_zones.azs.names
  private_subnets      = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets       = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "12.2.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnets         = module.vpc.private_subnets
  vpc_id 	  = module.vpc.vpc_id
  
  tags = {
    Environment = "load-test"
    Name  = "sabha"
  }

  worker_groups = [
    {
      asg_desired_capacity = 1
      asg_max_capacity     = 3
      asg_min_capacity     = 1
      instance_type    = var.instance_type
      image_id         = "ami-06f995c5e133ad46c"
      name             = "worker-nodes"
    },    
  ]  

write_kubeconfig   = true
config_output_path = "./"
}

output "Endpoint" {
  value = ["${data.aws_eks_cluster.cluster.endpoint}"]
}
