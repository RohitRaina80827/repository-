# Variable for ami-id
variable "ami_id" {
  default = "ami-0d27e0fb3bac4d724"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "release_id" {
  type = string
}
