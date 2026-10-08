variable "enable_compute" {
  type = bool
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "release_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "artifact_key" {
  type = string
}
