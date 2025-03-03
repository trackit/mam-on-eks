locals {
  current_workspace = terraform.workspace
}

resource "null_resource" "check_workspace" {
  count = local.current_workspace != var.env ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      echo "Error: Current workspace (${local.current_workspace}) does not match expected environment name (${var.env}). Exiting...";
      exit 1
    EOT
  }
}
