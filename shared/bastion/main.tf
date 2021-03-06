provider "aws" {
  version = "~> 2.0"
  region  = var.aws_region
}

#Tell terraform to use the S3 bucket and DynamoDB we created
terraform {
  required_version = ">= 0.12"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "mit-tfstates-state"
    key            = "bastion/terraform.tfstate"
    dynamodb_table = "mit-tfstates-state-lock"
    encrypt        = true
  }
}

module "shared" {
  source = "github.com/mitlibraries/tf-mod-shared-provider?ref=0.12"
}
