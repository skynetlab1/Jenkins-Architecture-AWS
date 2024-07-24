terraform {
  required_providers {
    aws = {
      version = "= 3.3.0"
    }
  }
}

# azcoops aliases for AWS regions
provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"
}
provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}
