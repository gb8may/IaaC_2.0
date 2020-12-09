variable "region" {
  default = "us-east-1"
}
variable "AmiLinux" {
  default = {
    us-east-1 = "ami-04d29b6f966df1537"
  }
  description = "Amazon Linux 2 AMI (HVM), SSD Volume Type"
}
variable "Ubuntu20" {
  default = {
    us-east-1 = "ami-0885b1f6bd170450c"
  }
  description = "Ubuntu Server 20.04 LTS (HVM), SSD Volume Type"
} 
variable "Ubuntu18" {
  default = {
    us-east-1 = "ami-00ddb0e5626798373"
  }
  description = "Ubuntu Server 18.04 LTS (HVM), SSD Volume Type"
}
variable "puppet_master" {
  default = "puppetmaster"
}
variable "puppet_agent" {
  default = "puppetagent"
}
variable "puppet_master_ip" {
  default = "172.31.92.200"
}
variable "puppet_agent_ip" {
  default = "172.31.86.107"
}
