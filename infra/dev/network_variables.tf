variable "availability_zones" {
  description = "Two distinct available zones in the provider region."

  type = object({
    a = string
    b = string
  })

  validation {
    condition = (
      var.availability_zones.a != var.availability_zones.b
    )

    error_message = "Choose two different availability zones."
  }
}

variable "owner" {
  description = "Person or team responsible for this lab."
  type        = string
}
