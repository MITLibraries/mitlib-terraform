provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

provider "template" {
  version = "~> 2.2"
}

# Tell terraform to use the S3 bucket and DynamoDB we created
terraform {
  required_version = ">= 0.12"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "mit-tfstates-state"
    key            = "apps/libraries-assets.tfstate"
    dynamodb_table = "mit-tfstates-state-lock"
    encrypt        = true
  }
}
