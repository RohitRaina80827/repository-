terraform {
  required_version = ">= 1.10, < 2.0"
}

resource "terraform_data" "pause" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
}
