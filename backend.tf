terraform {
  backend "s3" {
    bucket = "mundose-pin-test1337"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
}