/**
 * This module sets up the scheduled tasks to run carbon for both the HR
 * and the AA feeds. The tasks are scheduled by Cloudwatch and run on
 * Fargate.
 **/

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "mit-tfstates-state"
    key            = "apps/carbon.tfstate"
    dynamodb_table = "mit-tfstates-state-lock"
    encrypt        = true
  }
}

data "aws_subnet" "mit_net" {
  id = "subnet-0744a5c9beeb49a20"
}

data "aws_vpc" "mit_net_vpc" {
  id = "vpc-0ef9d327814ed449d"
}

module "shared" {
  source = "github.com/mitlibraries/tf-mod-shared-provider?ref=0.12"
}
