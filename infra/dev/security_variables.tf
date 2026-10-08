variable "artifact_prefix" {
  description = "Application prefix ending in /."
  type        = string
  default     = "artifacts/"

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9_/.-]*/$", var.artifact_prefix))
    error_message = "Use a nonempty prefix ending in / without wildcards."
  }
}

locals {
  security_name = "terraform-status-lab-dev"
}
