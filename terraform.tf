terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.15"

  backend "s3" {
    bucket = "task-microservices-app-remote-backend-bucket"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
