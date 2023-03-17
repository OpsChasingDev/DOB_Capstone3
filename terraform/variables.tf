variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}
variable "subnet_cidr_block" {
  default = "10.0.10.0/24"
}
variable "avail_zone" {
  default = "us-east-1a"
}
variable "env_prefix" {
  default = "dev"
}
variable "my_ip" {
  default = "99.145.91.76/32"
}
variable "jenkins_ip" {
  default = "137.184.153.12/32"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "region" {
  default = "us-east-1"
}