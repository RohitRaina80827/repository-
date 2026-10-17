variable "region" {
  type    = string
  default = "us-east-1"
}

variable "account_id" {
  type    = string
  default = "980819806665"
}

variable "owner" {
  type    = string
  default = "rohit"
}

variable "availability_zones" {
  type = map(string)

  default = {
    a = "us-east-1a"
    b = "us-east-1b"
  }

  validation {
    condition     = length(distinct(values(var.availability_zones))) == 2
    error_message = "Exactly two distinct availability zones are required."
  }
}

variable "ami_id" {
  description = "Pinned Amazon Linux 2023 AMI ID for the production launch template."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for production application instances."
  type        = string
}

variable "release_id" {
  description = "Application release identifier displayed by the service."
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener."
  type        = string
}
