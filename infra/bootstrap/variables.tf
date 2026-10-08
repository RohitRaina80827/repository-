variable "region" {
  type = string
}

variable "account_id" {
  type = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "Enter the expected 12-digit AWS account ID."
  }
}

variable "state_bucket_name" {
  type = string
}

variable "approved_role_arns" {
  type = list(string)

  validation {
    condition     = length(var.approved_role_arns) > 0
    error_message = "Supply at least one approved IAM role ARN."
  }
}
