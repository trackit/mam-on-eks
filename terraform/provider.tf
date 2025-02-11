provider "aws" {
  region  = var.aws_region
  profile = var.profile

  default_tags {
    tags = {
      Environment = var.env
      Owner       = var.owner
      Project     = var.project
    }
  }
}