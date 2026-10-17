variable "availability_zones" {
  type = map(string)
}

variable "owner" {
  type = string
}

variable "network_name" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.30.0.0/16"
}
