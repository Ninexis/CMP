terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.96"
        }
    }
}

provider "aws" {
  region = "eu-north-1"
}
