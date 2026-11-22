terraform {
  required_version = ">= 1.9.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region              = var.region
  allowed_account_ids = [var.host_account_id]

  default_tags {
    tags = {
      Project     = "PANIC"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
