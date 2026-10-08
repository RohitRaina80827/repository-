variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "project" {
  type    = string
  default = "terraform-status-lab"
}

variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition     = var.environment == "dev"
    error_message = "Environment must be 'dev' for the dev Terraform root."
  }
}


variable "application_bucket_suffix" {
  description = "A stable unique suffix for the application bucket."
  type        = string
}

variable "enable_compute" {
  description = "Whether to create the EC2 compute resources."
  type        = bool
  default     = false
}

