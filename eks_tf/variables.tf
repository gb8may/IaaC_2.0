variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "sabha-load-test"
}

variable "cluster_version" {
  default = "1.19"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "provider_env_roles" {
  type    = "map"
  default = {
    "devops"    = ""
    "prod"    = "arn:aws:iam::582282573443:role/terraform-eks"
  }
}
