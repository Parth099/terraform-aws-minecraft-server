# Configure the AWS Provider
provider "aws" {
  region                   = var.aws_primary_region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "personal-general"
}
