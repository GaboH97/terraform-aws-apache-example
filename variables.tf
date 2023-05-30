variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "my_ip" {
  description = "My public IP address"
  type        = string
}

variable "public_key" {
  type = string
}

variable "server_name" {
  type    = string
  default = "Apache Server"
}