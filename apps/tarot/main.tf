provider "aws" {
  version = "~> 2.6.0"
  region  = "us-east-1"
}

terraform {
  required_version = ">= 0.11.10"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "mit-tfstates-state"
    key            = "apps/tarot.tfstate"
    dynamodb_table = "mit-tfstates-state-lock"
    encrypt        = true
  }
}

module "shared" {
  source = "git::https://github.com/mitlibraries/tf-mod-shared-provider?ref=master"
}
