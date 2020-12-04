variable "region" {
  default = "us-east-1"
}
variable "AmiLinux" {
  default = {
    us-east-1 = "ami-04d29b6f966df1537"
  }
  description = "Host 1 - AMI Linux"
}
variable "Ubuntu" {
  default = {
    us-east-1 = "ami-0885b1f6bd170450c"
  }
  description = "Host 2 - Ubuntu"
}
