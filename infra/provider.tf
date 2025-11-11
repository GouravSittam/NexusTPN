terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region     = var.aws_region
  # NOTE: these are read from variables; avoid committing real credentials to VCS
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
